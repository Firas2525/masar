import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../color.dart';
import '../../model/home_model.dart';
import '../../model/home_model.dart' show Quiz;
import '../../controller/quiz_controller.dart';
import 'quiz_details_page.dart';
import 'quiz_students_page.dart';

class QuizPage extends StatelessWidget {
  final Subject subject;
  QuizPage({required this.subject});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double h = MediaQuery.of(context).size.height;
    final controller = Get.put(QuizController(subject.id));
    return Scaffold(
      appBar: AppBar(
        title: Text('الاختبارات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: w * 0.055, letterSpacing: 0.5)),
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
        if (controller.quizes.isEmpty) {
          return Center(child: Text('لا يوجد اختبارات لهذه المادة'));
        }
        return ListView.builder(
          padding: EdgeInsets.all(w * 0.04),
          itemCount: controller.quizes.length,
          itemBuilder: (context, index) {
            final quiz = controller.quizes[index];
            return Card(
              margin: EdgeInsets.only(bottom: h * 0.02),
              child: ListTile(
                title: Text(quiz.quizName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المادة: ${quiz.subjectName}'),
                    Text('الصف: ${quiz.className}'),
                    Text('درجة النجاح: ${quiz.quizSuccessMark}'),
                    Text('الدرجة الكاملة: ${quiz.quizFullMark}'),
                    Text('عدد الأسئلة: ${quiz.questions.length}'),
                    Text('عدد الطلاب: ${quiz.studentsMarks.length}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: primaryPink),
                      tooltip: 'حذف الاختبار',
                      onPressed: () => _showDeleteQuizDialog(context, controller, quiz),
                    ),
                    IconButton(
                      icon: Icon(Icons.people_alt, color: primaryblue),
                      tooltip: 'الطلاب المتقدمين',
                      onPressed: () {
                        Get.to(() => QuizStudentsPage(quiz: quiz));
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Get.to(() => QuizDetailsPage(quiz: quiz));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddQuizDialog(context, controller),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: primaryblue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),
    );
  }

  void _showQuizDetailsDialog(BuildContext context, Quiz quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تفاصيل الاختبار'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اسم الاختبار: ${quiz.quizName}'),
              Text('المادة: ${quiz.subjectName}'),
              Text('الصف: ${quiz.className}'),
              Text('درجة النجاح: ${quiz.quizSuccessMark}'),
              Text('الدرجة الكاملة: ${quiz.quizFullMark}'),
              Text('عدد الأسئلة: ${quiz.questions.length}'),
              SizedBox(height: 8),
              Text('علامات الطلاب:'),
              ...quiz.studentsMarks
                  .map(
                    (m) => Text('ID: ${m['childId']} - العلامة: ${m['mark']}'),
                  )
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إغلاق')),
        ],
      ),
    );
  }

  void _showAddQuizDialog(BuildContext context, QuizController controller) {
    final quizNameController = TextEditingController();
    final quizSuccessMarkController = TextEditingController();
    final quizFullMarkController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة اختبار جديد', style: TextStyle(color:primaryblue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: quizNameController, decoration: InputDecoration(labelText: 'اسم الاختبار')),
            TextField(controller: quizSuccessMarkController, decoration: InputDecoration(labelText: 'درجة النجاح'), keyboardType: TextInputType.number),
            TextField(controller: quizFullMarkController, decoration: InputDecoration(labelText: 'الدرجة الكاملة'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final quizName = quizNameController.text.trim();
              final quizSuccessMark = int.tryParse(quizSuccessMarkController.text.trim()) ?? 0;
              final quizFullMark = int.tryParse(quizFullMarkController.text.trim()) ?? 0;
              await controller.addQuiz(
                subjectId: subject.id,
                subjectName: subject.name,
                quizName: quizName,
                quizSuccessMark: quizSuccessMark,
                quizFullMark: quizFullMark,
                className:  '',
              );
              Navigator.pop(ctx);
            },
            child: Text('إضافة'),
            style: ElevatedButton.styleFrom(backgroundColor:primaryblue),
          ),
        ],
      ),
    );
  }

  void _showDeleteQuizDialog(
    BuildContext context,
    QuizController controller,
    Quiz quiz,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف الاختبار', style: TextStyle(color: primaryPink)),
        content: Text('هل تريد حذف الاختبار ${quiz.quizName}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteQuiz(quiz.id);
              Navigator.pop(ctx);
            },
            child: Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryPink),
          ),
        ],
      ),
    );
  }
}
