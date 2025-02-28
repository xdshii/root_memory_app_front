import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/quiz.dart';
import '../../../../data/models/quiz_result.dart';

// 事件定义
abstract class QuizEvent extends Equatable {
  const QuizEvent();
  
  @override
  List<Object> get props => [];
}

class QuizStarted extends QuizEvent {
  final Quiz quiz;
  
  const QuizStarted({required this.quiz});
  
  @override
  List<Object> get props => [quiz];
}

class AnswerSubmitted extends QuizEvent {
  final String optionId;
  
  const AnswerSubmitted({required this.optionId});
  
  @override
  List<Object> get props => [optionId];
}

class NextQuestionRequested extends QuizEvent {}

class QuizCompleted extends QuizEvent {}

// 状态定义
abstract class QuizState extends Equatable {
  const QuizState();
  
  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizInProgress extends QuizState {
  final Quiz quiz;
  final int currentQuestionIndex;
  final QuizQuestion currentQuestion;
  final int currentLevel;
  final int answeredCount;
  final int correctCount;
  final String? selectedOptionId;
  final bool? isCorrect;
  final bool showExplanation;
  final List<QuestionResult> results;
  final bool isLastQuestion;
  final bool isLastQuestionInLevel;
  
  const QuizInProgress({
    required this.quiz,
    required this.currentQuestionIndex,
    required this.currentQuestion,
    required this.currentLevel,
    required this.answeredCount,
    required this.correctCount,
    this.selectedOptionId,
    this.isCorrect,
    this.showExplanation = false,
    required this.results,
    required this.isLastQuestion,
    required this.isLastQuestionInLevel,
  });
  
  QuizInProgress copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    QuizQuestion? currentQuestion,
    int? currentLevel,
    int? answeredCount,
    int? correctCount,
    String? selectedOptionId,
    bool? isCorrect,
    bool? showExplanation,
    List<QuestionResult>? results,
    bool? isLastQuestion,
    bool? isLastQuestionInLevel,
  }) {
    return QuizInProgress(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentLevel: currentLevel ?? this.currentLevel,
      answeredCount: answeredCount ?? this.answeredCount,
      correctCount: correctCount ?? this.correctCount,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      isCorrect: isCorrect ?? this.isCorrect,
      showExplanation: showExplanation ?? this.showExplanation,
      results: results ?? this.results,
      isLastQuestion: isLastQuestion ?? this.isLastQuestion,
      isLastQuestionInLevel: isLastQuestionInLevel ?? this.isLastQuestionInLevel,
    );
  }
  
  @override
  List<Object?> get props => [
    quiz,
    currentQuestionIndex,
    currentQuestion,
    currentLevel,
    answeredCount,
    correctCount,
    selectedOptionId,
    isCorrect,
    showExplanation,
    results,
    isLastQuestion,
    isLastQuestionInLevel,
  ];
}

class QuizFinished extends QuizState {
  final QuizResult result;
  final Map<int, List<QuestionResult>> resultsByLevel;
  final List<String> weakWordIds;
  
  const QuizFinished({
    required this.result,
    required this.resultsByLevel,
    required this.weakWordIds,
  });
  
  @override
  List<Object?> get props => [result, resultsByLevel, weakWordIds];
}

// Bloc实现
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizInitial()) {
    on<QuizStarted>(_onQuizStarted);
    on<AnswerSubmitted>(_onAnswerSubmitted);
    on<NextQuestionRequested>(_onNextQuestionRequested);
    on<QuizCompleted>(_onQuizCompleted);
  }
  
  FutureOr<void> _onQuizStarted(
    QuizStarted event, 
    Emitter<QuizState> emit,
  ) {
    emit(QuizLoading());
    
    final quiz = event.quiz;
    
    if (quiz.questions.isEmpty) {
      // 如果没有问题，直接完成测验
      emit(QuizFinished(
        result: QuizResult(
          id: 'result_${DateTime.now().millisecondsSinceEpoch}',
          quizId: quiz.id,
          userId: 'current_user',
          levelId: quiz.levelId,
          score: 0,
          correctCount: 0,
          totalCount: 0,
          completedAt: DateTime.now(),
          questionResults: [],
          passed: false,
        ),
        resultsByLevel: {},
        weakWordIds: [],
      ));
      return;
    }
    
    // 找到第一个问题
    final firstQuestion = quiz.questions.first;
    
    emit(QuizInProgress(
      quiz: quiz,
      currentQuestionIndex: 0,
      currentQuestion: firstQuestion,
      currentLevel: firstQuestion.level,
      answeredCount: 0,
      correctCount: 0,
      results: [],
      isLastQuestion: quiz.questions.length == 1,
      isLastQuestionInLevel: _isLastQuestionInLevel(quiz.questions, 0),
    ));
  }
  
  FutureOr<void> _onAnswerSubmitted(
    AnswerSubmitted event, 
    Emitter<QuizState> emit,
  ) {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;
      
      if (currentState.selectedOptionId != null) {
        // 已经回答过，忽略
        return;
      }
      
      final isCorrect = event.optionId == currentState.currentQuestion.correctOptionId;
      
      // 创建问题结果
      final questionResult = QuestionResult(
        questionId: currentState.currentQuestion.id,
        wordId: currentState.currentQuestion.wordId,
        correct: isCorrect,
        selectedOptionId: event.optionId,
      );
      
      // 更新结果列表
      final updatedResults = List<QuestionResult>.from(currentState.results)
        ..add(questionResult);
      
      emit(currentState.copyWith(
        selectedOptionId: event.optionId,
        isCorrect: isCorrect,
        showExplanation: true,
        answeredCount: currentState.answeredCount + 1,
        correctCount: isCorrect ? currentState.correctCount + 1 : currentState.correctCount,
        results: updatedResults,
      ));
    }
  }
  
  FutureOr<void> _onNextQuestionRequested(
    NextQuestionRequested event, 
    Emitter<QuizState> emit,
  ) {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;
      
      if (currentState.isLastQuestion) {
        // 已经是最后一个问题，完成测验
        add(QuizCompleted());
        return;
      }
      
      // 移动到下一个问题
      final nextIndex = currentState.currentQuestionIndex + 1;
      final nextQuestion = currentState.quiz.questions[nextIndex];
      
      emit(QuizInProgress(
        quiz: currentState.quiz,
        currentQuestionIndex: nextIndex,
        currentQuestion: nextQuestion,
        currentLevel: nextQuestion.level,
        answeredCount: currentState.answeredCount,
        correctCount: currentState.correctCount,
        results: currentState.results,
        isLastQuestion: nextIndex == currentState.quiz.questions.length - 1,
        isLastQuestionInLevel: _isLastQuestionInLevel(
          currentState.quiz.questions, 
          nextIndex,
        ),
      ));
    }
  }
  
  FutureOr<void> _onQuizCompleted(
    QuizCompleted event, 
    Emitter<QuizState> emit,
  ) {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;
      
      // 计算分数 (百分比)
      final score = (currentState.correctCount / currentState.quiz.questions.length * 100).round();
      
      // 检查是否通过测验
      final passed = score >= currentState.quiz.passingScore;
      
      // 按级别分组结果
      Map<int, List<QuestionResult>> resultsByLevel = {};
      
      for (int i = 0; i < currentState.results.length; i++) {
        final result = currentState.results[i];
        final question = currentState.quiz.questions[i];
        final level = question.level;
        
        if (!resultsByLevel.containsKey(level)) {
          resultsByLevel[level] = [];
        }
        
        resultsByLevel[level]!.add(result);
      }
      
      // 找出薄弱单词
      final weakWordIds = currentState.results
          .where((result) => !result.correct)
          .map((result) => result.wordId)
          .toList();
      
      // 创建测验结果
      final quizResult = QuizResult(
        id: 'result_${DateTime.now().millisecondsSinceEpoch}',
        quizId: currentState.quiz.id,
        userId: 'current_user',
        levelId: currentState.quiz.levelId,
        score: score,
        correctCount: currentState.correctCount,
        totalCount: currentState.quiz.questions.length,
        completedAt: DateTime.now(),
        questionResults: currentState.results,
        passed: passed,
      );
      
      emit(QuizFinished(
        result: quizResult,
        resultsByLevel: resultsByLevel,
        weakWordIds: weakWordIds,
      ));
    }
  }
  
  bool _isLastQuestionInLevel(List<QuizQuestion> questions, int currentIndex) {
    if (currentIndex >= questions.length - 1) {
      return true;
    }
    
    final currentLevel = questions[currentIndex].level;
    final nextLevel = questions[currentIndex + 1].level;
    
    return currentLevel != nextLevel;
  }
}