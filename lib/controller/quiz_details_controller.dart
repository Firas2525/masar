import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class QuizDetailsController extends GetxController {
  Future<String?> uploadImageAndGetUrl(XFile picked) async {
    try {
      final cloudName = "ddpk9jmfc";
      final uploadPreset = "firas_image";
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', picked.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final resData = await http.Response.fromStream(response);
        final data = jsonDecode(resData.body);
        return data['secure_url'];
      } else {
        print("❌ فشل الرفع: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
  final String quizId;
  QuizDetailsController(this.quizId);

  final isLoading = false.obs;
  final questions = <Map<String, dynamic>>[].obs;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection('quizes').doc(quizId).get();
      final data = doc.data();
      if (data != null && data['questions'] != null) {
        questions.value = List<Map<String, dynamic>>.from(data['questions']);
      } else {
        questions.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addQuestion(Map<String, dynamic> question) async {
    questions.add(question);
    await _firestore.collection('quizes').doc(quizId).update({
      'questions': questions,
    });
    await fetchQuestions();
  }

  Future<void> deleteQuestion(int index) async {
    questions.removeAt(index);
    await _firestore.collection('quizes').doc(quizId).update({
      'questions': questions,
    });
    await fetchQuestions();
  }
}
