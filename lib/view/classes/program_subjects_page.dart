import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramSubjectsPage extends StatelessWidget {
  final String dayName;
  final String programId;
  const ProgramSubjectsPage({required this.dayName, required this.programId});

  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final programDoc = await FirebaseFirestore.instance.collection('programs').doc(programId).get();
    final weeklySchedule = programDoc.data()?['weeklySchedule'] ?? [];
    final daySchedule = weeklySchedule.firstWhere(
      (d) => d['dayName'] == dayName,
      orElse: () => null,
    );
    if (daySchedule == null) return [];
    final subjectIds = List<String>.from(daySchedule['subjectIds'] ?? []);
    if (subjectIds.isEmpty) return [];
    final subjectsSnap = await FirebaseFirestore.instance
        .collection('subjects')
        .where(FieldPath.documentId, whereIn: subjectIds)
        .get();
    return subjectsSnap.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مواد يوم $dayName')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSubjects(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد مواد لهذا اليوم'));
          }
          final subjects = snapshot.data!;
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, i) {
              final subject = subjects[i];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(subject['name'] ?? ''),
                  subtitle: Text(subject['description'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
