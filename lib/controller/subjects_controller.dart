import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/home_model.dart';

class SubjectsController extends GetxController {
  Future<void> editSubject(String id, String name, String teacher, int index) async {
    try {
      isLoading.value = true;
      await _firestore.collection('subjects').doc(id).update({
        'name': name,
        'teacher': teacher,
        'index': index,
      });
      await fetchSubjects();
    } finally {
      isLoading.value = false;
    }
  }
  final String classId;

  SubjectsController(this.classId);

  final isLoading = false.obs;
  final subjects = <Subject>[].obs;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    try {
      isLoading.value = true;
      final query = await _firestore
          .collection('subjects')
          .where('classId', isEqualTo: classId)
          .get();
      final loaded = query.docs
          .map((doc) => Subject.fromFirestore(doc.data(), doc.id))
          .toList();
      subjects.value = loaded;
      print(subjects);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubject(String name, String teacher) async {
    try {
      isLoading.value = true;
      await _firestore.collection('subjects').add({
        'name': name,
        'teacher': teacher,
        'classId': classId,
        'index': 0,
        'timeline': [],
      });
      await fetchSubjects();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('subjects').doc(id).delete();
      await fetchSubjects();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSubjectToProgram(String subjectId, String dayName) async {
    try {
      isLoading.value = true;
      final programsRef = _firestore.collection('programs');
      final query = await programsRef.where('classId', isEqualTo: classId).limit(1).get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        List<dynamic> weeklySchedule = doc['weeklySchedule'] ?? [];
        bool updated = false;
        bool foundDay = false;
        for (var day in weeklySchedule) {
          if (day['dayName'] == dayName) {
            foundDay = true;
            if (true) {
              day['subjectIds'].add(subjectId);
              updated = true;
              print('تمت إضافة المادة لليوم $dayName');
            } else {
              print('المادة موجودة بالفعل في اليوم $dayName');
            }
          }
        }
        if (!foundDay) {
          weeklySchedule.add({
            'dayName': dayName,
            'subjectIds': [subjectId],
          });
          updated = true;
          print('تم إنشاء يوم جديد وإضافة المادة لليوم $dayName');
        }
        if (updated) {
          await programsRef.doc(doc.id).update({'weeklySchedule': weeklySchedule});
          print('تم تحديث البرنامج بنجاح');
        }
      } else {
        // إذا لم يوجد مستند للبرنامج لهذا الصف، أنشئ واحد جديد
        final newSchedule = [{
          'dayName': dayName,
          'subjectIds': [subjectId],
        }];
        await programsRef.add({
          'classId': classId,
          'weeklySchedule': newSchedule,
        });
        print('تم إنشاء برنامج جديد وإضافة المادة لليوم $dayName');
      }
    } catch (e) {
      print('خطأ أثناء إضافة المادة للبرنامج: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class TimelineController extends GetxController {
  final Subject subject;

  TimelineController(this.subject);

  final isLoading = false.obs;
  final timeline = <Map<String, dynamic>>[].obs;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    timeline.assignAll(
      subject.timeline.map(
        (e) => {'name': e.name, 'description': e.description},
      ),
    );
  }

  Future<void> addLesson(String name, String description) async {
    timeline.add({'name': name, 'description': description});
    await _updateTimeline();
  }

  Future<void> deleteLesson(int index) async {
    timeline.removeAt(index);
    await _updateTimeline();
  }

  Future<void> reorderTimeline(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final item = timeline.removeAt(oldIndex);
    timeline.insert(newIndex, item);
    await _updateTimeline();
  }

  Future<void> _updateTimeline() async {
    await _firestore.collection('subjects').doc(subject.id).update({
      'timeline': timeline,
    });
  }
}
