import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/answers_controller.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AnswersPage extends StatelessWidget {
  Future<String?> _uploadImageAndGetUrl(XFile picked) async {
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
  final int questionIndex;
  final Map<String, dynamic> question;
  AnswersPage({required this.quizId, required this.questionIndex, required this.question});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnswersController(quizId, questionIndex));
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('إجابات السؤال', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: w * 0.055)),
        backgroundColor: Color(0xFF38B6FF),
        elevation: 4,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      backgroundColor: Color(0xFFF7F9FC),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: Color(0xFF38B6FF)));
        }
        return ListView.builder(
          padding: EdgeInsets.all(w * 0.04),
          itemCount: controller.answers.length,
          itemBuilder: (context, index) {
            final answer = controller.answers[index];
            return Card(
              margin: EdgeInsets.only(bottom: h * 0.02),
              child: Padding(
                padding: EdgeInsets.all(w * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إجابة رقم ${index + 1}', style: TextStyle(color: Color(0xFF38B6FF), fontWeight: FontWeight.bold, fontSize: w * 0.04)),
                    SizedBox(height: h * 0.01),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: answer['text'] != null && answer['text'].toString().isNotEmpty
                        ? Image.network(
                            answer['text'],
                            width: double.infinity,
                            height: h * 0.18,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, stack) => Container(
                              height: h * 0.18,
                              color: Colors.grey[200],
                              child: Center(child: Text('تعذر تحميل الصورة', style: TextStyle(color: Colors.red))),
                            ),
                          )
                        : Container(
                            height: h * 0.18,
                            color: Colors.grey[200],
                            child: Center(child: Text('لا يوجد صورة لهذه الإجابة', style: TextStyle(color: Colors.grey))),
                          ),
                    ),
                    SizedBox(height: h * 0.01),
                    Text(answer['isCorrect'] == true ? 'إجابة صحيحة' : 'إجابة خاطئة', style: TextStyle(color: answer['isCorrect'] == true ? Colors.green : Colors.red)),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'حذف الإجابة',
                        onPressed: () => _showDeleteAnswerDialog(context, controller, index),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: Obx(() => FloatingActionButton(
        onPressed: controller.answers.length >= 4 ? null : () => _showAddAnswerDialog(context, controller),
        backgroundColor: Color(0xFF38B6FF),
        child: Icon(Icons.add_a_photo, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      )),
    );
  }

  void _showAddAnswerDialog(BuildContext context, AnswersController controller) {
    String? imageUrl;
    bool isCorrect = false;
    final picker = ImagePicker();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          bool dialogMounted = true;
          return AlertDialog(
            title: Text('إضافة إجابة بصورة', style: TextStyle(color: Color(0xFF38B6FF))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('رفع صورة الإجابة'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF38B6FF)),
                  onPressed: () async {
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      imageUrl = await this._uploadImageAndGetUrl(picked);
                      if (dialogMounted) setState(() {});
                    }
                  },
                ),
                if (imageUrl != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Image.network(imageUrl!, height: 120),
                  ),
                Row(
                  children: [
                    Checkbox(value: isCorrect, onChanged: (val) => setState(() => isCorrect = val ?? false)),
                    Text('هل الإجابة صحيحة؟'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () { dialogMounted = false; Navigator.pop(ctx); }, child: Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (imageUrl != null) {
                    await controller.addAnswer({'text': imageUrl!, 'isCorrect': isCorrect});
                    dialogMounted = false;
                    Navigator.pop(ctx);
                  }
                },
                child: Text('إضافة'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF38B6FF)),
              ),
            ],
          );
        },
      ),
    );
  Future<String?> _uploadImageAndGetUrl(picked) async {
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
  }

  void _showDeleteAnswerDialog(BuildContext context, AnswersController controller, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف الإجابة', style: TextStyle(color: Colors.red)),
        content: Text('هل تريد حذف هذه الإجابة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteAnswer(index);
              Navigator.pop(ctx);
            },
            child: Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
