import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindergarten_user/color.dart';
import '../../controller/program_controller.dart';
import '../../model/home_model.dart' hide TimelineItem;
import '../../model/program_model.dart';
import 'timeline_page.dart';

const Color backgroundColor = Color(0xFFF7F9FC);

// التدرجات اللونية
final LinearGradient primaryGradient = LinearGradient(
  colors: [primaryblue, primaryblue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient accentGradient = LinearGradient(
  colors: [Color(0xFFFF6B6B), Color(0xFFFF9F9F)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ProgramPage extends StatelessWidget {
  final Child child;

  const ProgramPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProgramController());
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;

    // تحميل البرامج للطفل المحدد
    controller.loadProgramsForChild(child);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'جدول الطفل',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.055),
        ),
        backgroundColor: primaryblue,
        elevation: 4,
        shadowColor: primaryblue.withOpacity(0.18),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.event_note, color: Colors.white, size: w * 0.07),
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية زخرفية عصرية مثل صفحة الاختبارات
          Positioned(
            top:  h * 0.3,
            right: -w * 0.12,
            child: Container(
              width: w * 0.7,
              height: w * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryPink, primaryPink],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryblue.withOpacity(0.12),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: h * 0.1,
            left: -w * 0.25,
            child: Container(
              width: w * 0.5,
              height: w * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryblue, primaryblue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.08),
                    blurRadius: 80,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: h * 0.75,
            left: -w * 0.1,
            child: Container(
              width: w * 0.5,
              height: w * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryPurble, primaryPurble],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.08),
                    blurRadius: 80,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: primaryblue,));
              }
              if (controller.programs.isEmpty) {
                return Center(
                  child: Text(
                    'لا يوجد برنامج لهذا الطفل',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              final program = controller.programs[0];
              return ListView.builder(
                padding: EdgeInsets.all(18),
                itemCount: program.weeklySchedule.length,
                itemBuilder: (context, index) {
                  final day = program.weeklySchedule[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: primaryblue,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                day.dayName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryblue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: day.subjects.map((subject) {
                              return GestureDetector(
                                onTap: () {
                                  // ابحث عن المادة من قائمة subjects
                                  final subjectsList = controller.subjects;
                                  final foundSubject = subjectsList.firstWhere(
                                    (s) => s['name'] == subject.name,
                                    orElse: () => {},
                                  );
                                  if (foundSubject.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TimelinePage(subject: foundSubject),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('لم يتم العثور على المادة!')),
                                    );
                                  }
                                },
                                child: Chip(
                                  label: Text(
                                    subject.name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: primaryblue,
                                  avatar: Icon(
                                    Icons.book,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
