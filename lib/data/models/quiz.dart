class Quiz {
  final String id;
  final String levelId;
  final List<QuizQuestion> questions;
  final int totalQuestions;
  final int passingScore; // 及格分数，通常为80%
  
  Quiz({
    required this.id,
    required this.levelId,
    required this.questions,
    required this.totalQuestions,
    this.passingScore = 80,
  });
}

class QuizQuestion {
  final String id;
  final String wordId; // 关联的单词ID
  final QuestionType type; // 问题类型
  final String question; // 问题文本
  final List<QuizOption> options; // 选项
  final String correctOptionId; // 正确选项ID
  final int level; // 难度级别 1-4
  final String? explanation; // 解析，错误时显示
  
  QuizQuestion({
    required this.id,
    required this.wordId,
    required this.type,
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.level,
    this.explanation,
  });
}

class QuizOption {
  final String id;
  final String text;
  
  QuizOption({
    required this.id,
    required this.text,
  });
}

enum QuestionType {
  wordToMeaning, // 级别1: 单词→选择正确释义
  meaningToWord, // 级别2: 释义→选择正确单词
  sentenceCompletion, // 级别3: 句子填空
  challenge, // 级别4: 挑战题(未学过但含相同词根的词)
}