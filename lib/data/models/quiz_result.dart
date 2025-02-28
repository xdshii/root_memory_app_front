class QuizResult {
  final String id;
  final String quizId;
  final String userId;
  final String levelId;
  final int score;
  final int correctCount;
  final int totalCount;
  final DateTime completedAt;
  final List<QuestionResult> questionResults;
  final bool passed;
  
  QuizResult({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.levelId,
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.completedAt,
    required this.questionResults,
    required this.passed,
  });
}

class QuestionResult {
  final String questionId;
  final String wordId;
  final bool correct;
  final String? selectedOptionId;
  
  QuestionResult({
    required this.questionId,
    required this.wordId,
    required this.correct,
    this.selectedOptionId,
  });
}