import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/review.dart';
import '../../../../data/models/level.dart';
import '../../../../data/models/word.dart';
import '../../../../data/mocks/mock_data.dart';

// 事件定义
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  
  @override
  List<Object> get props => [];
}

class ReviewPlansRequested extends ReviewEvent {
  final String userId;
  
  const ReviewPlansRequested({
    required this.userId,
  });
  
  @override
  List<Object> get props => [userId];
}

class ReviewSelected extends ReviewEvent {
  final ReviewPlan reviewPlan;
  
  const ReviewSelected({
    required this.reviewPlan,
  });
  
  @override
  List<Object> get props => [reviewPlan];
}

class FlashcardReviewSelected extends ReviewEvent {
  final List<FlashcardReview> flashcardReviews;
  
  const FlashcardReviewSelected({
    required this.flashcardReviews,
  });
  
  @override
  List<Object> get props => [flashcardReviews];
}

class WordMemoryRated extends ReviewEvent {
  final String wordId;
  final MemoryDifficulty difficulty;
  
  const WordMemoryRated({
    required this.wordId,
    required this.difficulty,
  });
  
  @override
  List<Object> get props => [wordId, difficulty];
}

class NextFlashcardRequested extends ReviewEvent {}

class ReviewCompleted extends ReviewEvent {
  final int score;
  
  const ReviewCompleted({
    required this.score,
  });
  
  @override
  List<Object> get props => [score];
}

// 状态定义
abstract class ReviewState extends Equatable {
  const ReviewState();
  
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewPlansLoading extends ReviewState {}

class ReviewPlansLoaded extends ReviewState {
  final List<ReviewPlan> overdueReviewPlans;
  final List<ReviewPlan> todayReviewPlans;
  final List<ReviewPlan> upcomingReviewPlans;
  final List<ReviewPlan> completedReviewPlans;
  final List<FlashcardReview> dueFlashcardReviews;
  
  const ReviewPlansLoaded({
    required this.overdueReviewPlans,
    required this.todayReviewPlans,
    required this.upcomingReviewPlans,
    required this.completedReviewPlans,
    required this.dueFlashcardReviews,
  });
  
  @override
  List<Object?> get props => [
    overdueReviewPlans,
    todayReviewPlans,
    upcomingReviewPlans,
    completedReviewPlans,
    dueFlashcardReviews,
  ];
}

class UnitReviewInProgress extends ReviewState {
  final ReviewPlan reviewPlan;
  final Level level;
  final List<Word> words;
  final int currentWordIndex;
  final Word currentWord;
  final bool isLastWord;
  final int correctCount;
  final List<String> rememberedWordIds;
  
  const UnitReviewInProgress({
    required this.reviewPlan,
    required this.level,
    required this.words,
    required this.currentWordIndex,
    required this.currentWord,
    required this.isLastWord,
    required this.correctCount,
    required this.rememberedWordIds,
  });
  
  UnitReviewInProgress copyWith({
    ReviewPlan? reviewPlan,
    Level? level,
    List<Word>? words,
    int? currentWordIndex,
    Word? currentWord,
    bool? isLastWord,
    int? correctCount,
    List<String>? rememberedWordIds,
  }) {
    return UnitReviewInProgress(
      reviewPlan: reviewPlan ?? this.reviewPlan,
      level: level ?? this.level,
      words: words ?? this.words,
      currentWordIndex: currentWordIndex ?? this.currentWordIndex,
      currentWord: currentWord ?? this.currentWord,
      isLastWord: isLastWord ?? this.isLastWord,
      correctCount: correctCount ?? this.correctCount,
      rememberedWordIds: rememberedWordIds ?? this.rememberedWordIds,
    );
  }
  
  @override
  List<Object?> get props => [
    reviewPlan,
    level,
    words,
    currentWordIndex,
    currentWord,
    isLastWord,
    correctCount,
    rememberedWordIds,
  ];
}

class FlashcardReviewInProgress extends ReviewState {
  final List<FlashcardReview> flashcardReviews;
  final List<Word> words;
  final int currentIndex;
  final Word currentWord;
  final bool isCardFlipped;
  final MemoryDifficulty? selectedDifficulty;
  final bool isLastCard;
  final Map<String, MemoryDifficulty> ratedWords;
  
  const FlashcardReviewInProgress({
    required this.flashcardReviews,
    required this.words,
    required this.currentIndex,
    required this.currentWord,
    required this.isCardFlipped,
    this.selectedDifficulty,
    required this.isLastCard,
    required this.ratedWords,
  });
  
  FlashcardReviewInProgress copyWith({
    List<FlashcardReview>? flashcardReviews,
    List<Word>? words,
    int? currentIndex,
    Word? currentWord,
    bool? isCardFlipped,
    MemoryDifficulty? selectedDifficulty,
    bool? isLastCard,
    Map<String, MemoryDifficulty>? ratedWords,
  }) {
    return FlashcardReviewInProgress(
      flashcardReviews: flashcardReviews ?? this.flashcardReviews,
      words: words ?? this.words,
      currentIndex: currentIndex ?? this.currentIndex,
      currentWord: currentWord ?? this.currentWord,
      isCardFlipped: isCardFlipped ?? this.isCardFlipped,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      isLastCard: isLastCard ?? this.isLastCard,
      ratedWords: ratedWords ?? this.ratedWords,
    );
  }
  
  @override
  List<Object?> get props => [
    flashcardReviews,
    words,
    currentIndex,
    currentWord,
    isCardFlipped,
    selectedDifficulty,
    isLastCard,
    ratedWords,
  ];
}

class ReviewCompleting extends ReviewState {}

class ReviewCompleted extends ReviewState {
  final ReviewPlan reviewPlan;
  final int score;
  final DateTime nextReviewDate;
  
  const ReviewCompleted({
    required this.reviewPlan,
    required this.score,
    required this.nextReviewDate,
  });
  
  @override
  List<Object?> get props => [reviewPlan, score, nextReviewDate];
}

// Bloc实现
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final MockData _mockData = MockData();
  
  ReviewBloc() : super(ReviewInitial()) {
    on<ReviewPlansRequested>(_onReviewPlansRequested);
    on<ReviewSelected>(_onReviewSelected);
    on<FlashcardReviewSelected>(_onFlashcardReviewSelected);
    on<WordMemoryRated>(_onWordMemoryRated);
    on<NextFlashcardRequested>(_onNextFlashcardRequested);
    on<ReviewCompleted>(_onReviewCompleted);
  }
  
  FutureOr<void> _onReviewPlansRequested(
    ReviewPlansRequested event, 
    Emitter<ReviewState> emit,
  ) {
    emit(ReviewPlansLoading());
    
    final userId = event.userId;
    
    // 获取用户的复习计划
    final reviewPlans = _mockData.getMockReviewPlans(userId);
    final flashcardReviews = _mockData.getMockFlashcardReviews(userId);
    
    final now = DateTime.now();
    
    // 今天的开始和结束
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    // 分类复习计划
    final overdueReviewPlans = reviewPlans.where((plan) => 
      plan.status == ReviewStatus.overdue || 
      (plan.status == ReviewStatus.scheduled && plan.scheduledFor.isBefore(now))
    ).toList();
    
    final todayReviewPlans = reviewPlans.where((plan) => 
      plan.status == ReviewStatus.scheduled && 
      plan.scheduledFor.isAfter(now) &&
      plan.scheduledFor.isBefore(todayEnd)
    ).toList();
    
    final upcomingReviewPlans = reviewPlans.where((plan) => 
      plan.status == ReviewStatus.scheduled && 
      plan.scheduledFor.isAfter(todayEnd)
    ).toList();
    
    final completedReviewPlans = reviewPlans.where((plan) => 
      plan.status == ReviewStatus.completed
    ).toList();
    
    // 获取今天应该复习的闪卡
    final dueFlashcardReviews = flashcardReviews.where((review) => 
      review.nextReview.isBefore(todayEnd)
    ).toList();
    
    emit(ReviewPlansLoaded(
      overdueReviewPlans: overdueReviewPlans,
      todayReviewPlans: todayReviewPlans,
      upcomingReviewPlans: upcomingReviewPlans,
      completedReviewPlans: completedReviewPlans,
      dueFlashcardReviews: dueFlashcardReviews,
    ));
  }
  
  FutureOr<void> _onReviewSelected(
    ReviewSelected event, 
    Emitter<ReviewState> emit,
  ) {
    final reviewPlan = event.reviewPlan;
    
    // 获取关卡信息
    final level = _mockData.getMockLevels().firstWhere(
      (l) => l.id == reviewPlan.levelId,
      orElse: () => throw Exception('Level not found'),
    );
    
    // 获取单词信息
    final allWords = _mockData.getMockWords();
    final words = allWords.where(
      (w) => reviewPlan.wordIds.contains(w.id),
    ).toList();
    
    if (words.isEmpty) {
      // 如果没有需要复习的单词，直接标记为完成
      add(ReviewCompleted(score: 100));
      return;
    }
    
    // 开始关卡复习
    emit(UnitReviewInProgress(
      reviewPlan: reviewPlan,
      level: level,
      words: words,
      currentWordIndex: 0,
      currentWord: words.first,
      isLastWord: words.length == 1,
      correctCount: 0,
      rememberedWordIds: [],
    ));
  }
  
  FutureOr<void> _onFlashcardReviewSelected(
    FlashcardReviewSelected event, 
    Emitter<ReviewState> emit,
  ) {
    final flashcardReviews = event.flashcardReviews;
    
    // 获取单词信息
    final allWords = _mockData.getMockWords();
    final words = allWords.where(
      (w) => flashcardReviews.map((r) => r.wordId).contains(w.id),
    ).toList();
    
    if (words.isEmpty) {
      // 如果没有需要复习的单词，返回
      return;
    }
    
    // 开始闪卡复习
    emit(FlashcardReviewInProgress(
      flashcardReviews: flashcardReviews,
      words: words,
      currentIndex: 0,
      currentWord: words.first,
      isCardFlipped: false,
      isLastCard: words.length == 1,
      ratedWords: {},
    ));
  }
  
  FutureOr<void> _onWordMemoryRated(
    WordMemoryRated event, 
    Emitter<ReviewState> emit,
  ) {
    if (state is FlashcardReviewInProgress) {
      final currentState = state as FlashcardReviewInProgress;
      
      // 更新已评分单词
      final updatedRatedWords = Map<String, MemoryDifficulty>.from(currentState.ratedWords);
      updatedRatedWords[event.wordId] = event.difficulty;
      
      emit(currentState.copyWith(
        selectedDifficulty: event.difficulty,
        ratedWords: updatedRatedWords,
      ));
      
      // 自动前进到下一个闪卡
      Future.delayed(const Duration(milliseconds: 500), () {
        add(NextFlashcardRequested());
      });
    } else if (state is UnitReviewInProgress) {
      final currentState = state as UnitReviewInProgress;
      
      // 更新已记住的单词列表
      final rememberedWordIds = List<String>.from(currentState.rememberedWordIds);
      if (event.difficulty != MemoryDifficulty.hard) {
        // 如果不是困难，则认为记住了
        rememberedWordIds.add(event.wordId);
      }
      
      // 计算下一个单词
      final nextIndex = currentState.currentWordIndex + 1;
      
      if (nextIndex >= currentState.words.length) {
        // 如果是最后一个单词，计算分数并完成复习
        final score = (rememberedWordIds.length / currentState.words.length * 100).round();
        add(ReviewCompleted(score: score));
      } else {
        // 进入下一个单词
        emit(currentState.copyWith(
          currentWordIndex: nextIndex,
          currentWord: currentState.words[nextIndex],
          isLastWord: nextIndex == currentState.words.length - 1,
          correctCount: rememberedWordIds.length,
          rememberedWordIds: rememberedWordIds,
        ));
      }
    }
  }
  
  FutureOr<void> _onNextFlashcardRequested(
    NextFlashcardRequested event, 
    Emitter<ReviewState> emit,
  ) {
    if (state is FlashcardReviewInProgress) {
      final currentState = state as FlashcardReviewInProgress;
      
      // 翻转卡片状态
      if (!currentState.isCardFlipped) {
        // 如果卡片未翻转，先翻转
        emit(currentState.copyWith(
          isCardFlipped: true,
        ));
        return;
      }
      
      // 如果已经评分，移动到下一个闪卡
      if (currentState.selectedDifficulty != null) {
        final nextIndex = currentState.currentIndex + 1;
        
        if (nextIndex >= currentState.words.length) {
          // 所有闪卡已完成，更新复习计划和下次复习时间
          
          // 请求复习计划列表刷新
          add(ReviewPlansRequested(userId: 'current_user'));
          return;
        }
        
        // 进入下一个闪卡
        emit(currentState.copyWith(
          currentIndex: nextIndex,
          currentWord: currentState.words[nextIndex],
          isCardFlipped: false,
          selectedDifficulty: null,
          isLastCard: nextIndex == currentState.words.length - 1,
        ));
      }
    }
  }
  
  FutureOr<void> _onReviewCompleted(
    ReviewCompleted event, 
    Emitter<ReviewState> emit,
  ) {
    emit(ReviewCompleting());
    
    if (state is UnitReviewInProgress) {
      final currentState = state as UnitReviewInProgress;
      
      // 更新复习计划状态
      final updatedReviewPlan = currentState.reviewPlan.copyWith(
        status: ReviewStatus.completed,
        completedAt: DateTime.now(),
        score: event.score,
      );
      
      // 计算下次复习时间
      final nextReviewDate = DateTime.now().add(
        currentState.reviewPlan.type == ReviewType.unit 
            ? const Duration(days: 3) // 二次复习间隔
            : const Duration(days: 7) // 三次复习间隔
      );
      
      emit(ReviewCompleted(
        reviewPlan: updatedReviewPlan,
        score: event.score,
        nextReviewDate: nextReviewDate,
      ));
    }
  }
}