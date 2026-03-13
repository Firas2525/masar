import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/home_model.dart';
import 'secure_storage_service.dart';

/// =======================
/// API KEYS & MODELS
/// =======================

const String COHERE_API_KEY = '';
const String COHERE_MODEL = 'command-a-03-2025';

const String HUGGING_FACE_API_KEY = '';
const String HUGGING_FACE_MODEL = 'tiiuae/falcon-7b-instruct';

/// =======================
/// AI SERVICE
/// =======================

class AIService {
  /// Last error message from the last API attempt, if any.
  static String? lastError;

  /// Ask the AI about the given car and user question.
  static Future<String> ask(Car car, String question) async {
    lastError = null;
    final prompt = _buildPrompt(car, question);

    try {
      /// =======================
      /// 1️⃣ Try Cohere (chat) first
      /// =======================
      final _storedCohere = await SecureStorageService.getCohereApiKey();
      final cohereKey = _storedCohere.trim().isNotEmpty
          ? _storedCohere.trim()
          : COHERE_API_KEY.trim();

      if (cohereKey.isNotEmpty) {
        final url = Uri.parse('https://api.cohere.ai/v1/chat');

        try {
          final res = await http
              .post(
                url,
                headers: {
                  'Authorization': 'Bearer $cohereKey',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'model': COHERE_MODEL,
                  'message': question,
                  'temperature': 0.7,
                  'chat_history': [
                    {
                      'role': 'SYSTEM',
                      'message':
                          'أنت مساعد ذكي تجيب باللغة العربية فقط وباختصار',
                    },
                  ],
                }),
              )
              .timeout(const Duration(seconds: 30));

          if (res.statusCode == 200) {
            final decoded = jsonDecode(res.body);

            // Try to extract response text from a few possible shapes
            String? text;
            if (decoded is Map<String, dynamic>) {
              if (decoded['text'] is String) {
                text = decoded['text'];
              } else if (decoded['response'] is String) {
                text = decoded['response'];
              } else if (decoded['output'] != null) {
                final out = decoded['output'];
                if (out is String) text = out;
                if (out is List && out.isNotEmpty && out[0]['content'] != null)
                  text = out[0]['content'].toString();
                if (out is Map && out['content'] != null)
                  text = out['content'].toString();
              } else if (decoded['generations'] is List &&
                  decoded['generations'].isNotEmpty) {
                final gens = decoded['generations'];
                if (gens[0]['text'] != null) text = gens[0]['text'].toString();
              }
            }

            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }

            return decoded.toString();
          } else {
            lastError =
                'خطأ في Cohere (رمز ${res.statusCode})، سيتم استخدام التشخيص المحلي.';
            return '$lastError\n\n${_localDiagnosis(car, question)}';
          }
        } catch (e) {
          lastError = 'فشل الاتصال بـ Cohere: $e';
          return '$lastError\n\n${_localDiagnosis(car, question)}';
        }
      }

      final _storedHf = await SecureStorageService.getHfApiKey();
      final hfKey = _storedHf.trim().isNotEmpty
          ? _storedHf.trim()
          : HUGGING_FACE_API_KEY.trim();

      /// =======================
      /// 2️⃣ Hugging Face fallback
      /// =======================
      if (hfKey.isNotEmpty) {
        final url = Uri.parse(
          'https://api-inference.huggingface.co/models/$HUGGING_FACE_MODEL',
        );

        final res = await http
            .post(
              url,
              headers: {
                'Authorization': 'Bearer $hfKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'inputs': prompt,
                'parameters': {'max_new_tokens': 300, 'temperature': 0.7},
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded is List &&
              decoded.isNotEmpty &&
              decoded[0]['generated_text'] != null) {
            return decoded[0]['generated_text'];
          }
          return res.body;
        } else {
          lastError =
              'خطأ في HuggingFace (رمز ${res.statusCode})، سيتم استخدام التشخيص المحلي.';
          return '$lastError\n\n${_localDiagnosis(car, question)}';
        }
      }

      /// =======================
      /// 3️⃣ Local fallback
      /// =======================
      return _localDiagnosis(car, question);
    } catch (e) {
      lastError = 'خطأ غير متوقع: $e';
      return '$lastError\n\n${_localDiagnosis(car, question)}';
    }
  }

  /// =======================
  /// Prompt Builder
  /// =======================
  static String _buildPrompt(Car car, String question) {
    final buffer = StringBuffer();
    buffer.writeln('أنت خبير تشخيص سيارات وتجيب باللغة العربية فقط.');
    buffer.writeln('معلومات السيارة:');
    buffer.writeln('- العلامة: ${car.brand}');
    buffer.writeln('- الطراز: ${car.title}');
    buffer.writeln('- المسافة المقطوعة: ${car.mileageKill} كم');
    buffer.writeln('- ناقل الحركة: ${car.trans}');
    if (car.desc.isNotEmpty) {
      buffer.writeln('- ملاحظات إضافية: ${car.desc}');
    }
    buffer.writeln('سؤال المستخدم: $question');
    buffer.writeln(
      'اذكر الأسباب المحتملة مرتبة من الأكثر شيوعًا إلى الأقل، مع خطوات فحص عملية.',
    );
    buffer.writeln('أجب بإيجاز وبدون ذكر أنك ذكاء اصطناعي.');
    return buffer.toString();
  }

  /// =======================
  /// Local Rule-based Diagnosis
  /// =======================
  static String _localDiagnosis(Car car, String question) {
    final q = question.toLowerCase().trim();
    final suggestions = <String>[];

    final mileage = int.tryParse(car.mileageKill) ?? 0;

    if (mileage > 150000) {
      suggestions.add(
        'المسافة المقطوعة عالية: افحص المحرك، شمعات الإشعال، ضغط الزيت، وفلتر الوقود.',
      );
    } else if (mileage > 100000) {
      suggestions.add(
        'المسافة المقطوعة متوسطة: راجع نظام التزييت، التبريد، وسير الكاتينة.',
      );
    }

    if (q.contains('صوت') || q.contains('طرق') || q.contains('طرقعة')) {
      suggestions.add(
        'وجود صوت غير طبيعي: افحص نظام العادم، التعليق، والمحامل.',
      );
    }

    if (q.contains('حرارة') || q.contains('سخونة')) {
      suggestions.add(
        'ارتفاع الحرارة: تحقق من سائل التبريد، المروحة، الثرموستات، وطرمبة المياه.',
      );
    }

    if (q.contains('لا يعمل') || q.contains('لا يبدأ') || q.contains('يدور')) {
      suggestions.add(
        'مشكلة تشغيل: افحص البطارية، الدينامو، مضخة الوقود، وشرارة الإشعال.',
      );
    }

    if (q.contains('زيت') || q.contains('تسريب')) {
      suggestions.add('تسريب سوائل: افحص خراطيم الزيت، كرتير الزيت، والوصلات.');
    }

    if (q.contains('اهتزاز') || q.contains('رجفة')) {
      suggestions.add(
        'اهتزاز السيارة: قد يكون من توازن الإطارات، الفرامل، أو قواعد المحرك.',
      );
    }

    if (suggestions.isEmpty) {
      return 'لا يمكن تحديد المشكلة بدقة من المعطيات الحالية. '
          'يفضّل فحص السوائل، البطارية، نظام التبريد، وشمعات الإشعال، '
          'أو تزويدنا بأعراض أوضح.';
    }

    return suggestions.join('\n');
  }
}

/// =======================
/// Example Car Model
/// =======================
