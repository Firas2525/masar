import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../color.dart';

class ClassDaySubjectsPage extends StatefulWidget {
  final String dayName;
  final String classId;
  const ClassDaySubjectsPage({required this.dayName, required this.classId});

  @override
  State<ClassDaySubjectsPage> createState() => _ClassDaySubjectsPageState();
}

class _ClassDaySubjectsPageState extends State<ClassDaySubjectsPage> {
  List<Map<String, dynamic>> subjects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final programSnap = await FirebaseFirestore.instance
        .collection('programs')
        .where('classId', isEqualTo: widget.classId)
        .limit(1)
        .get();
    if (programSnap.docs.isEmpty) {
      setState(() {
        loading = false;
      });
      return;
    }
    final program = programSnap.docs.first.data();
    final weeklySchedule = program['weeklySchedule'] ?? [];
    final daySchedule = weeklySchedule.firstWhere(
      (d) => d['dayName'] == widget.dayName,
      orElse: () => null,
    );
    if (daySchedule == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    final subjectIds = List<String>.from(daySchedule['subjectIds'] ?? []);
    if (subjectIds.isEmpty) {
      setState(() {
        loading = false;
      });
      return;
    }
    final subjectsSnap = await FirebaseFirestore.instance
        .collection('subjects')
        .where(FieldPath.documentId, whereIn: subjectIds)
        .get();
    setState(() {
      subjects = subjectsSnap.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مواد يوم ${widget.dayName}'),
        backgroundColor: primaryblue,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryblue))
          : subjects.isEmpty
              ? Center(child: Text('لا توجد مواد لهذا اليوم', style: TextStyle(color: primaryblue, fontSize: 18)))
              : Container(
                  color: primaryWhite,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    itemCount: subjects.length,
                    itemBuilder: (context, i) {
                      final subject = subjects[i];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryblue,
                            child: Text('${i + 1}', style: TextStyle(color: Colors.white)),
                          ),
                          title: Text(
                            subject['name'] ?? '',
                            style: TextStyle(
                              color: primaryBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            subject['description'] ?? '',
                            style: TextStyle(color: primaryblue, fontSize: 15),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
