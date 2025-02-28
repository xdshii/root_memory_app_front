import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/level.dart';
import '../../../../data/models/root.dart';
import '../../../../data/models/word.dart';

// 事件定义
abstract class LearningEvent extends Equatable {
  const LearningEvent();
  
  @override
  List<Object> get props => [];
}

class LearningStarted extends LearningEvent {
  final Level level;
  final Root root;
  final List<Word> words;
  
  const LearningStarted({
    required this.level,
    required this.root,
    required this.words,
  });
  
  @override
  List<Object> get props => [level, root, words];
}

class MoveToNextWord extends LearningEvent {}

class MoveToPreviousWord extends LearningEvent {}

class MarkWordAsDifficult extends LearningEvent {
  final Word word;
  
  const MarkWordAsDifficult(this.word);
  
  @override
  List<Object> get props => [word];
}

class CompleteRootLearning extends LearningEvent {}

// 状态定义
abstract class LearningState extends Equatable {
  const LearningState();
  
  @override
  List<Object?> get props => [];
}

class LearningInitial extends LearningState {}

class LearningRootIntroduction extends LearningState {
  final Level level;
  final Root root;
  final List<Word> words;
  
  const LearningRootIntroduction({
    required this.level,
    required this.root,
    required this.words,
  });
  
  @override
  List<Object?> get props => [level, root, words];
}

class LearningWordDetails extends LearningState {
  final Level level;
  final Root root;
  final List<Word> words;
  final Word currentWord;
  final int currentIndex;
  final int totalWords;
  final bool isLastWord;
  final List<String> difficultWordIds;
  
  const LearningWordDetails({
    required this.level,
    required this.root,
    required this.words,
    required this.currentWord,
    required this.currentIndex,
    required this.totalWords,
    required this.isLastWord,
    required this.difficultWordIds,
  });
  
  LearningWordDetails copyWith({
    Level? level,
    Root? root,
    List<Word>? words,
    Word? currentWord,
    int? currentIndex,
    int? totalWords,
    bool? isLastWord,
    List<String>? difficultWordIds,
  }) {
    return LearningWordDetails(
      level: level ?? this.level,
      root: root ?? this.root,
      words: words ?? this.words,
      currentWord: currentWord ?? this.currentWord,
      currentIndex: currentIndex ?? this.currentIndex,
      totalWords: totalWords ?? this.totalWords,
      isLastWord: isLastWord ?? this.isLastWord,
      difficultWordIds: difficultWordIds ?? this.difficultWordIds,
    );
  }
  
  @override
  List<Object?> get props => [
    level, 
    root, 
    words, 
    currentWord, 
    currentIndex, 
    totalWords, 
    isLastWord,
    difficultWordIds,
  ];
}

class LearningCompleted extends LearningState {
  final Level level;
  final List<String> difficultWordIds;
  
  const LearningCompleted({
    required this.level,
    required this.difficultWordIds,
  });
  
  @override
  List<Object?> get props => [level, difficultWordIds];
}

// Bloc实现
class LearningBloc extends Bloc<LearningEvent, LearningState> {
  LearningBloc() : super(LearningInitial()) {
    on<LearningStarted>(_onLearningStarted);
    on<MoveToNextWord>(_onMoveToNextWord);
    on<MoveToPreviousWord>(_onMoveToPreviousWord);
    on<MarkWordAsDifficult>(_onMarkWordAsDifficult);
    on<CompleteRootLearning>(_onCompleteRootLearning);
  }
  
  FutureOr<void> _onLearningStarted(
    LearningStarted event, 
    Emitter<LearningState> emit,
  ) {
    emit(LearningRootIntroduction(
      level: event.level,
      root: event.root,
      words: event.words,
    ));
    
    // 5秒后自动进入单词学习，用户也可以手动点击继续
    // 注意：实际应用中可能需要处理事件监听的取消
    Future.delayed(const Duration(seconds: 5), () {
      if (state is LearningRootIntroduction) {
        add(MoveToNextWord());
      }
    });
  }
  
  FutureOr<void> _onMoveToNextWord(
    MoveToNextWord event, 
    Emitter<LearningState> emit,
  ) {
    if (state is LearningRootIntroduction) {
      final introState = state as LearningRootIntroduction;
      final words = introState.words;
      
      if (words.isEmpty) {
        emit(LearningCompleted(
          level: introState.level,
          difficultWordIds: [],
        ));
        return;
      }
      
      emit(LearningWordDetails(
        level: introState.level,
        root: introState.root,
        words: words,
        currentWord: words[0],
        currentIndex: 0,
        totalWords: words.length,
        isLastWord: words.length == 1,
        difficultWordIds: [],
      ));
    } else if (state is LearningWordDetails) {
      final detailState = state as LearningWordDetails;
      final nextIndex = detailState.currentIndex + 1;
      
      if (nextIndex >= detailState.words.length) {
        emit(LearningCompleted(
          level: detailState.level,
          difficultWordIds: detailState.difficultWordIds,
        ));
        return;
      }
      
      emit(detailState.copyWith(
        currentWord: detailState.words[nextIndex],
        currentIndex: nextIndex,
        isLastWord: nextIndex == detailState.words.length - 1,
      ));
    }
  }
  
  FutureOr<void> _onMoveToPreviousWord(
    MoveToPreviousWord event, 
    Emitter<LearningState> emit,
  ) {
    if (state is LearningWordDetails) {
      final detailState = state as LearningWordDetails;
      final previousIndex = detailState.currentIndex - 1;
      
      if (previousIndex < 0) {
        // 返回到词根介绍页面
        emit(LearningRootIntroduction(
          level: detailState.level,
          root: detailState.root,
          words: detailState.words,
        ));
        return;
      }
      
      emit(detailState.copyWith(
        currentWord: detailState.words[previousIndex],
        currentIndex: previousIndex,
        isLastWord: false,
      ));
    }
  }
  
  FutureOr<void> _onMarkWordAsDifficult(
    MarkWordAsDifficult event, 
    Emitter<LearningState> emit,
  ) {
    if (state is LearningWordDetails) {
      final detailState = state as LearningWordDetails;
      final difficultWordIds = List<String>.from(detailState.difficultWordIds);
      
      if (difficultWordIds.contains(event.word.id)) {
        difficultWordIds.remove(event.word.id);
      } else {
        difficultWordIds.add(event.word.id);
      }
      
      emit(detailState.copyWith(
        difficultWordIds: difficultWordIds,
      ));
    }
  }
  
  FutureOr<void> _onCompleteRootLearning(
    CompleteRootLearning event, 
    Emitter<LearningState> emit,
  ) {
    if (state is LearningWordDetails) {
      final detailState = state as LearningWordDetails;
      emit(LearningCompleted(
        level: detailState.level,
        difficultWordIds: detailState.difficultWordIds,
      ));
    }
  }
}