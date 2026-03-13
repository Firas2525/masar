import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'class_day_subjects_page.dart';
import '../../color.dart';

class ProgramDaysPage extends StatefulWidget {
  @override
  State<ProgramDaysPage> createState() => _ProgramDaysPageState();
}

class _ProgramDaysPageState extends State<ProgramDaysPage> {
  final days = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];
  Map<String, List<Map<String, dynamic>>> daySubjects = {};
  bool loading = true;
  String? classId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('classId')) {
      classId = args['classId'] as String?;
      fetchAllSubjects();
    }
  }

  Future<void> fetchAllSubjects() async {
    setState(() {
      loading = true;
    });
    if (classId == null) return;
    final programSnap = await FirebaseFirestore.instance
        .collection('programs')
        .where('classId', isEqualTo: classId)
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
    Map<String, List<Map<String, dynamic>>> tempDaySubjects = {};
    for (var day in days) {
      final daySchedule = weeklySchedule.firstWhere(
        (d) => d['dayName'] == day,
        orElse: () => null,
      );
      final subjectIds = daySchedule != null
          ? List<String>.from(daySchedule['subjectIds'] ?? [])
          : [];
      if (subjectIds.isEmpty) {
        tempDaySubjects[day] = [];
        continue;
      }
      final subjectsSnap = await FirebaseFirestore.instance
          .collection('subjects')
          .where(FieldPath.documentId, whereIn: subjectIds)
          .get();
      tempDaySubjects[day] = subjectsSnap.docs
          .map((doc) => doc.data()..['id'] = doc.id)
          .toList();
    }
    setState(() {
      daySubjects = tempDaySubjects;
      loading = false;
    });
  }

  Future<void> removeSubjectFromDay(String dayName, String subjectId) async {
    if (classId == null) return;
    final programSnap = await FirebaseFirestore.instance
        .collection('programs')
        .where('classId', isEqualTo: classId)
        .limit(1)
        .get();
    if (programSnap.docs.isEmpty) return;
    final programDoc = programSnap.docs.first;
    final programData = programDoc.data();
    final weeklySchedule = List<Map<String, dynamic>>.from(
      programData['weeklySchedule'] ?? [],
    );
    final dayIndex = weeklySchedule.indexWhere((d) => d['dayName'] == dayName);
    if (dayIndex == -1) return;
    List subjectIds = List<String>.from(
      weeklySchedule[dayIndex]['subjectIds'] ?? [],
    );
    subjectIds.remove(subjectId);
    weeklySchedule[dayIndex]['subjectIds'] = subjectIds;
    await programDoc.reference.update({'weeklySchedule': weeklySchedule});
    await fetchAllSubjects();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حذف المادة من يوم $dayName',
          style: TextStyle(color: primaryWhite),
        ),
        backgroundColor: primaryblue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('برنامج الأسبوع'),
        backgroundColor: primaryblue,
        elevation: 2,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryblue))
          : Container(
              color: primaryWhite,
              child: ListView.builder(
                itemCount: days.length,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                itemBuilder: (context, i) {
                  final subjects = daySubjects[days[i]] ?? [];
                  return Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryblue,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 50.0),
                        child: Center(
                          child: Text(
                            days[i],
                            style: TextStyle(
                              color: primaryBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      subtitle: subjects.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6.0,left: 55),
                              child: Center(
                                child: Text(
                                  'عطلة',
                                  style: TextStyle(
                                    color: primaryPink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 6),
                                ...subjects.map(
                                  (s) => Row(
                                    children: [
                                      Expanded(
                                        child: Chip(
                                          label: Text(
                                            s['name'] ?? '',
                                            style: TextStyle(
                                              color: primaryblue,
                                            ),
                                          ),
                                          backgroundColor: primaryblue
                                              .withOpacity(0.1),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: primaryPink,
                                        ),
                                        tooltip: 'حذف المادة',
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('تأكيد الحذف'),
                                              content: Text(
                                                'هل تريد حذف المادة "${s['name']}" من يوم ${days[i]}؟',
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('تراجع'),
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
                                                ),
                                                ElevatedButton(
                                                  child: Text('موافق'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            primaryPink,
                                                      ),
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await removeSubjectFromDay(
                                              days[i],
                                              s['id'],
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      trailing: null,
                      onTap: null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
