import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../color.dart';
import '../../constants.dart';
import '../../model/home_model.dart';
import '../../services/ai_service.dart' hide HUGGING_FACE_API_KEY, COHERE_API_KEY;
import '../../services/secure_storage_service.dart';


class AiCarChatPage extends StatefulWidget {
  final Car car;
  const AiCarChatPage({Key? key, required this.car}) : super(key: key);

  @override
  State<AiCarChatPage> createState() => _AiCarChatPageState();
}

class _AiCarChatPageState extends State<AiCarChatPage> {
  final TextEditingController _ctrl = TextEditingController();
  String? _lastQuestion;
  String? _lastAnswer;
  bool _isSending = false;
  String? _lastError;

  final List<String> _suggested = [
    'هل السيارة تستحق الشراء؟',
    'ما هي نقاط القوة الضعف لهذه السيارة؟',
    'ما الأعطال الشائعة لسيارة بهذه المواصفات؟'
  ];

  @override
  void initState() {
    super.initState();
    // keep key checks internal but do not surface provider information in the UI
    SecureStorageService.ensureKeysFromConstants();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _buildContextSuffix() {
    final c = widget.car;
    final parts = <String>[];
    if (c.brand.isNotEmpty) parts.add('النوع: ${c.brand}');
    if (c.title.isNotEmpty) parts.add('الموديل: ${c.title}');
    if (c.mileageKill.isNotEmpty) parts.add('عدد الكيلومترات: ${c.mileageKill}');
    if (c.color.isNotEmpty) parts.add('اللون: ${c.color}');
    if (c.address.isNotEmpty) parts.add('الموقع: ${c.address}');
    if (c.price!=null) parts.add('السعر: ${c.price}');

    final suffix = parts.isNotEmpty ? 'ملاحظة: نحن نتحدث عن سيارة بـ${parts.join('، ')}.' : '';
    return suffix + ' الرجاء الإجابة في سياق السيارة.';
  }

  Future<void> _send([String? prefilled]) async {
    final raw = (prefilled ?? _ctrl.text).trim();
    if (raw.isEmpty) return;
    final prompt = '$raw\n\n${_buildContextSuffix()}';

    setState(() {
      _isSending = true;
      _lastError = null;
      _lastQuestion = raw;
      _lastAnswer = null; // remove previous answer from view
      _ctrl.clear();
    });

    try {
      final response = await AIService.ask(widget.car, prompt);
      setState(() {
        _lastAnswer = response;
        _isSending = false;
        _lastError = AIService.lastError;
      });
    } catch (e) {
      setState(() {
        _lastAnswer = null;
        _isSending = false;
        _lastError = e.toString();
      });
    }

    // silently refresh any keys if user changed settings elsewhere
    SecureStorageService.ensureKeysFromConstants();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.car;
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          // hero with image + overlay + back button
          Stack(
            children: [
              Container(
                height: h * 0.28,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: c.image.isNotEmpty ? DecorationImage(image: CachedNetworkImageProvider(c.image), fit: BoxFit.cover) : null,
                ),
                child: c.image.isEmpty ? Center(child: Icon(Icons.directions_car, size: 100, color: primaryblue)) : null,
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 12,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.arrow_back, color: primaryBlack),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.title.isNotEmpty ? c.title : c.brand,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (c.price!=null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                        child: Text('السعر: ${c.price}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // summary & suggested chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${c.brand} • ${c.mileageKill} كلم • ${c.trans}', style: textStyleBody)),
                    SizedBox(width: 8),
                    Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Text(c.color.isNotEmpty ? c.color : '---'))
                  ],
                ),
                SizedBox(height: 6),

                // compact horizontal suggestions
                Row(
                  children: [
                    Text('اقتراحات:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 13)),
                    SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _suggested.map((s) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Material(
                                color: Colors.grey[100],
                                elevation: 1,
                                borderRadius: BorderRadius.circular(18),
                                child: InkWell(
                                  onTap: () => _send(s),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Text(
                                      s,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // answer area (single card, not chat bubbles)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: _lastAnswer == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.question_answer, size: 56, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text('اسأل أي شيء عن هذه السيارة', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                          SizedBox(height: 8),
                          Text('مثال: "هل السيارة تستحق الشراء؟" أو اختَر سؤالاً من الاقتراحات أعلاه.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_lastQuestion != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('سؤالك: "${_lastQuestion!}"', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                            ),

                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(_lastAnswer ?? '', style: TextStyle(fontSize: 16, height: 1.5)),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(onPressed: () => setState(() { _lastQuestion = null; _lastAnswer = null; }), child: Text('مسح')),
                                      SizedBox(width: 8),
                                      TextButton(onPressed: () => _send(_lastQuestion), child: Text('إعادة')),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // input area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _ctrl,
                        decoration: InputDecoration(hintText: 'اكتب سؤالك هنا...', border: InputBorder.none),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  _isSending
                      ? SizedBox(width: 44, height: 44, child: Center(child: CircularProgressIndicator()))
                      : Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          color: primaryPurble,
                          child: InkWell(
                            onTap: () => _send(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 44,
                              width: 44,
                              child: Icon(Icons.send, color: Colors.white),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
