import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/home_model.dart';
import '../../controller/quiz_controller.dart';

class QuizStudentsPage extends StatelessWidget {
  final Quiz quiz;
  const QuizStudentsPage({Key? key, required this.quiz}) : super(key: key);

  Future<Child?> fetchChildById(String childId) async {
    // جلب بيانات الطالب من فايربيز
    final snapshot = await FirebaseFirestore.instance.collection('children').doc(childId).get();
    if (!snapshot.exists) return null;
    return Child.fromFirestore(snapshot.data()!, childId);
  }

  Future<List<Map<String, dynamic>>> fetchStudentsWithMarks() async {
    List<Map<String, dynamic>> result = [];
    for (var mark in quiz.studentsMarks) {
      final child = await fetchChildById(mark['childId']);
      if (child != null) {
        result.add({
          'name': child.name,
          'mark': mark['mark'],
          'success': mark['mark'] >= quiz.quizSuccessMark,
        });
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الطلاب المنجزون'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchStudentsWithMarks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!;
          if (students.isEmpty) {
            return Center(child: Text('لا يوجد طلاب أنجزوا الاختبار'));
          }
          return ListView.builder(
            padding: EdgeInsets.all(18),
            itemCount: students.length,
            itemBuilder: (context, i) {
              final student = students[i];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    student['success'] ? Icons.check_circle : Icons.cancel,
                    color: student['success'] ? Colors.green : Colors.red,
                  ),
                  title: Text(student['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('العلامة: ${student['mark']}'),
                  trailing: Text(
                    student['success'] ? 'ناجح' : 'راسب',
                    style: TextStyle(
                      color: student['success'] ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
