import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../model/home_model.dart';

class TestsController extends GetxController {
  final String className;
  TestsController(this.className);
  bool isManager=false;
  final isLoading = false.obs;
  final subjects = <Subject>[].obs;
  final quizesBySubject = <String, List<Quiz>>{}.obs;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchSubjectsAndQuizesByClassName();
  }

  Future<void> fetchSubjectsAndQuizesByClassName() async {
    try {
      isLoading.value = true;
       isManager = await sharePref?.getBool("isManager") ?? false;
       update();
       print(isManager);
       print(3332433333);
      final classQuery = await _firestore.collection('class').where('name', isEqualTo: className).limit(1).get();
      if (classQuery.docs.isEmpty) {
        subjects.value = [];
        quizesBySubject.value = {};
        return;
      }
      final classId = classQuery.docs.first.id;
      final query = await _firestore.collection('subjects').where('classId', isEqualTo: classId).get();
      final loadedSubjects = query.docs.map((doc) => Subject.fromFirestore(doc.data(), doc.id)).toList();
      subjects.value = loadedSubjects;
      // جلب جميع الاختبارات لكل مادة
      final Map<String, List<Quiz>> quizesMap = {};
      for (final subject in loadedSubjects) {
        final quizesQuery = await _firestore.collection('quizes').where('subjectId', isEqualTo: subject.id).get();
        final loadedQuizes = quizesQuery.docs.map((doc) => Quiz.fromFirestore(doc.data(), doc.id)).toList();
        quizesMap[subject.id] = loadedQuizes;
      }
      quizesBySubject.value = quizesMap;
    } finally {
      isLoading.value = false;
    }
  }
}
