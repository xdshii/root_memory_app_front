import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/models/statistics/learning_statistics.dart';
import '../../../../data/models/statistics/memory_analytics.dart';
import '../../../../data/models/statistics/vocabulary_status.dart';
import '../../../../data/repositories/statistics_repository.dart';

// 事件定义
abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadLearningStatistics extends StatisticsEvent {
  final String userId;
  final String? period;
  
  const LoadLearningStatistics({
    required this.userId,
    this.period,
  });
  
  @override
  List<Object?> get props => [userId, period];
}

class LoadMemoryAnalytics extends StatisticsEvent {
  final String userId;
  
  const LoadMemoryAnalytics({
    required this.userId,
  });
  
  @override
  List<Object> get props => [userId];
}

class LoadVocabularyStatus extends StatisticsEvent {
  final String userId;
  final String? status;
  final String? rootId;
  final int offset;
  final int limit;
  
  const LoadVocabularyStatus({
    required this.userId,
    this.status,
    this.rootId,
    this.offset = 0,
    this.limit = 20,
  });
  
  @override
  List<Object?> get props => [userId, status, rootId, offset, limit];
}

class LoadStudyHeatmap extends StatisticsEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  
  const LoadStudyHeatmap({
    required this.userId,
    this.startDate,
    this.endDate,
  });
  
  @override
  List<Object?> get props => [userId, startDate, endDate];
}

// 状态定义
abstract class StatisticsState extends Equatable {
  const StatisticsState();
  
  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class LearningStatisticsLoaded extends StatisticsState {
  final LearningStatistics statistics;
  
  const LearningStatisticsLoaded({
    required this.statistics,
  });
  
  @override
  List<Object> get props => [statistics];
}

class MemoryAnalyticsLoaded extends StatisticsState {
  final MemoryAnalytics analytics;
  
  const MemoryAnalyticsLoaded({
    required this.analytics,
  });
  
  @override
  List<Object> get props => [analytics];
}

class VocabularyStatusLoaded extends StatisticsState {
  final List<VocabularyStatus> vocabularyItems;
  final int totalCount;
  final bool hasMore;
  
  const VocabularyStatusLoaded({
    required this.vocabularyItems,
    required this.totalCount,
    required this.hasMore,
  });
  
  @override
  List<Object> get props => [vocabularyItems, totalCount, hasMore];
}

class StudyHeatmapLoaded extends StatisticsState {
  final Map<DateTime, int> heatmapData;
  final int totalMinutes;
  
  const StudyHeatmapLoaded({
    required this.heatmapData,
    required this.totalMinutes,
  });
  
  @override
  List<Object> get props => [heatmapData, totalMinutes];
}

class StatisticsError extends StatisticsState {
  final String message;
  
  const StatisticsError({
    required this.message,
  });
  
  @override
  List<Object> get props => [message];
}

// Bloc实现
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StatisticsRepository repository;
  
  StatisticsBloc({
    required this.repository,
  }) : super(StatisticsInitial()) {
    on<LoadLearningStatistics>(_onLoadLearningStatistics);
    on<LoadMemoryAnalytics>(_onLoadMemoryAnalytics);
    on<LoadVocabularyStatus>(_onLoadVocabularyStatus);
    on<LoadStudyHeatmap>(_onLoadStudyHeatmap);
  }
  
  FutureOr<void> _onLoadLearningStatistics(
    LoadLearningStatistics event, 
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());
    try {
      final statistics = await repository.getLearningStatistics(
        event.userId,
        period: event.period,
      );
      emit(LearningStatisticsLoaded(statistics: statistics));
      
      // 同时加载热图数据
      add(LoadStudyHeatmap(userId: event.userId));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }
  
  FutureOr<void> _onLoadMemoryAnalytics(
    LoadMemoryAnalytics event, 
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());
    try {
      final analytics = await repository.getMemoryAnalytics(event.userId);
      emit(MemoryAnalyticsLoaded(analytics: analytics));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }
  
  FutureOr<void> _onLoadVocabularyStatus(
    LoadVocabularyStatus event, 
    Emitter<StatisticsState> emit,
  ) async {
    emit(StatisticsLoading());
    try {
      final vocabularyItems = await repository.getVocabularyStatus(
        event.userId,
        status: event.status,
        rootId: event.rootId,
        offset: event.offset,
        limit: event.limit,
      );
      
      // 在实际应用中，需要从API获取总数，这里简化处理
      final totalCount = vocabularyItems.length + event.offset;
      final hasMore = vocabularyItems.length >= event.limit;
      
      emit(VocabularyStatusLoaded(
        vocabularyItems: vocabularyItems,
        totalCount: totalCount,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(StatisticsError(message: e.toString()));
    }
  }
  
  FutureOr<void> _onLoadStudyHeatmap(
    LoadStudyHeatmap event, 
    Emitter<StatisticsState> emit,
  ) async {
    try {
      final heatmapData = await repository.getStudyHeatmap(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      // 计算总学习时间
      final totalMinutes = heatmapData.values.fold(0, (sum, minutes) => sum + minutes);
      
      emit(StudyHeatmapLoaded(
        heatmapData: heatmapData,
        totalMinutes: totalMinutes,
      ));
    } catch (e) {
      // 热图加载失败不影响主要统计数据显示
      print('Failed to load heatmap: $e');
    }
  }
}