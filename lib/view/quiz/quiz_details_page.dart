import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/color.dart';
import '../../model/home_model.dart';
import '../../controller/quiz_details_controller.dart';
import '../quiz/answers_page.dart';
import 'package:image_picker/image_picker.dart';

class QuizDetailsPage extends StatelessWidget {
  final Quiz quiz;
  QuizDetailsPage({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final controller = Get.put(QuizDetailsController(quiz.id));
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الاختبار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: w * 0.055)),
        backgroundColor: primaryblue,
        elevation: 4,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      backgroundColor: Color(0xFFF7F9FC),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: primaryblue));
        }
        if (controller.questions.isEmpty) {
          return Center(child: Text('لا توجد أسئلة بعد', style: TextStyle(color: Colors.grey, fontSize: w * 0.045)));
        }
        return ListView.builder(
          padding: EdgeInsets.all(w * 0.04),
          itemCount: controller.questions.length,
          itemBuilder: (context, index) {
            final question = controller.questions[index];
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Get.to(() => AnswersPage(
                  quizId: quiz.id,
                  questionIndex: index,
                  question: question,
                ));
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: EdgeInsets.only(bottom: h * 0.02),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سؤال رقم ${index + 1}', style: TextStyle(color: primaryblue, fontWeight: FontWeight.bold, fontSize: w * 0.04)),
                      SizedBox(height: h * 0.01),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: question['text'] != null && question['text'].toString().isNotEmpty
                                ? Image.network(
                                    question['text'],
                                    width: double.infinity,
                                    height: h * 0.25,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, error, stack) => Container(
                                      height: h * 0.25,
                                      color: Colors.grey[200],
                                      child: Center(child: Text('تعذر تحميل الصورة', style: TextStyle(color: Colors.red))),
                                    ),
                                  )
                                : Container(
                                    height: h * 0.25,
                                    color: Colors.grey[200],
                                    child: Center(child: Text('لا يوجد صورة لهذا السؤال', style: TextStyle(color: Colors.grey))),
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _showDeleteQuestionDialog(context, controller, index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                  ),
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.delete, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddQuestionDialog(context, controller),
        child: Icon(Icons.add_a_photo, color: Colors.white),
        backgroundColor: primaryblue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, QuizDetailsController controller) async {
    String? imageUrl;
    final picker = ImagePicker();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('إضافة سؤال بصورة', style: TextStyle(color: primaryblue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.image),
                label: Text('رفع صورة السؤال'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryblue),
                onPressed: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    imageUrl = await controller.uploadImageAndGetUrl(picked);
                    setState(() {});
                  }
                },
              ),
              if (imageUrl != null)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Image.network(imageUrl!, height: 120),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (imageUrl != null) {
                  await controller.addQuestion({'text': imageUrl!});
                  Navigator.pop(ctx);
                }
              },
              child: Text('إضافة'),
              style: ElevatedButton.styleFrom(backgroundColor: primaryblue),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteQuestionDialog(BuildContext context, QuizDetailsController controller, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف السؤال', style: TextStyle(color: Colors.red)),
        content: Text('هل تريد حذف هذا السؤال؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteQuestion(index);
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
