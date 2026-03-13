import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnswersController extends GetxController {
  final String quizId;
  final int questionIndex;
  AnswersController(this.quizId, this.questionIndex);

  final isLoading = false.obs;
  final answers = <Map<String, dynamic>>[].obs;
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchAnswers();
  }

  Future<void> fetchAnswers() async {
    try {
      isLoading.value = true;
      final doc = await _firestore.collection('quizes').doc(quizId).get();
      final data = doc.data();
      if (data != null && data['questions'] != null && data['questions'].length > questionIndex) {
        answers.value = List<Map<String, dynamic>>.from(data['questions'][questionIndex]['answers'] ?? []);
      } else {
        answers.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAnswer(Map<String, dynamic> answer) async {
    if (answers.length >= 4) return;
    answers.add(answer);
    final doc = await _firestore.collection('quizes').doc(quizId).get();
    final data = doc.data();
    if (data != null && data['questions'] != null && data['questions'].length > questionIndex) {
      List questions = List.from(data['questions']);
      questions[questionIndex]['answers'] = answers;
      await _firestore.collection('quizes').doc(quizId).update({'questions': questions});
    }
    await fetchAnswers();
  }

  Future<void> deleteAnswer(int index) async {
    answers.removeAt(index);
    final doc = await _firestore.collection('quizes').doc(quizId).get();
    final data = doc.data();
    if (data != null && data['questions'] != null && data['questions'].length > questionIndex) {
      List questions = List.from(data['questions']);
      questions[questionIndex]['answers'] = answers;
      await _firestore.collection('quizes').doc(quizId).update({'questions': questions});
    }
    await fetchAnswers();
  }
}
