import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/home_model.dart';

class QuizController extends GetxController {
  final String subjectId;
  QuizController(this.subjectId);

  final isLoading = false.obs;
  final quizes = <Quiz>[].obs;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchQuizes();
  }

  Future<void> fetchQuizes() async {
    try {
      isLoading.value = true;
      final query = await _firestore
          .collection('quizes')
          .where('subjectId', isEqualTo: subjectId)
          .get();
      final loaded = query.docs
          .map((doc) => Quiz.fromFirestore(doc.data(), doc.id))
          .toList();
      quizes.value = loaded;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addQuiz({
    required String subjectId,
    required String subjectName,
    required String quizName,
    required int quizSuccessMark,
    required int quizFullMark,
    required String className,
  }) async {
    try {
      isLoading.value = true;
      await _firestore.collection('quizes').add({
        'subjectId': subjectId,
        'subjectName': subjectName,
        'quizName': quizName,
        'quizSuccessMark': quizSuccessMark,
        'quizFullMark': quizFullMark,
        'className': className,
        'questions': [],
        'studentsMarks': [],
      });
      await fetchQuizes();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteQuiz(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('quizes').doc(id).delete();
      await fetchQuizes();
    } finally {
      isLoading.value = false;
    }
  }
}
