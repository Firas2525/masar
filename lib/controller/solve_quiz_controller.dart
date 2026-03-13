import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/home_model.dart';

class SolveQuizController extends GetxController {
  final Quiz quiz;
  final String childId;
  SolveQuizController(this.quiz, this.childId);

  final currentQuestionIndex = 0.obs;
  final selectedAnswers = <int>[].obs; // index of selected answer for each question
  final isFinished = false.obs;
  final correctAnswersCount = 0.obs;
  final mark = 0.0.obs;
  final isSuccess = false.obs;

  void selectAnswer(int answerIndex) {
    if (isFinished.value) return;
    if (selectedAnswers.length > currentQuestionIndex.value) {
      selectedAnswers[currentQuestionIndex.value] = answerIndex;
    } else {
      selectedAnswers.add(answerIndex);
    }
    // تحقق من صحة الإجابة
    final q = quiz.questions[currentQuestionIndex.value];
    final answers = (q['answers'] ?? []) as List<dynamic>;
    final isCorrect = answers.isNotEmpty && answers[answerIndex]['isCorrect'] == true;
    if (!isCorrect) {
      // أظهر الإجابة الصحيحة بطريقة ظريفة
      Get.snackbar(
        'إجابة خاطئة',
        'الإجابة الصحيحة هي رقم: ${(answers.indexWhere((a) => a['isCorrect'] == true) + 1)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.2),
        colorText: Get.theme.colorScheme.onError,
        duration: Duration(seconds: 2),
      );
    }
    Future.delayed(Duration(seconds: isCorrect ? 0 : 2), () {
      if (currentQuestionIndex.value < quiz.questions.length - 1) {
        currentQuestionIndex.value++;
      } else {
        finishQuiz();
      }
    });
  }

  void finishQuiz() async {
    isFinished.value = true;
    int correct = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      final answers = (q['answers'] ?? []) as List<dynamic>;
      final selected = selectedAnswers.length > i ? selectedAnswers[i] : -1;
      if (selected != -1 && answers.isNotEmpty && answers[selected]['isCorrect'] == true) {
        correct++;
      }
    }
    correctAnswersCount.value = correct;
    double percent = quiz.questions.isEmpty ? 0 : correct / quiz.questions.length;
    mark.value = (percent * quiz.quizFullMark).roundToDouble();
    isSuccess.value = mark.value >= quiz.quizSuccessMark;
    // حفظ العلامة في فايربيز
    await FirebaseFirestore.instance.collection('quizes').doc(quiz.id).update({
      'studentsMarks': FieldValue.arrayUnion([
        {'childId': childId, 'mark': mark.value}
      ])
    });
  }
}
