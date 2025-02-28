import 'dart:async';
import '../models/statistics/learning_statistics.dart';
import '../models/statistics/memory_analytics.dart';
import '../models/statistics/vocabulary_status.dart';
import '../mocks/mock_data.dart';

class StatisticsRepository {
  final MockData _mockData = MockData();
  
  // 获取学习统计数据
  Future<LearningStatistics> getLearningStatistics(String userId, {String? period}) async {
    // 在实际应用中，这里会从本地数据库或远程API获取数据
    // 现在使用模拟数据
    return _mockData.getMockLearningStatistics(userId, period: period);
  }
  
  // 获取记忆分析数据
  Future<MemoryAnalytics> getMemoryAnalytics(String userId) async {
    return _mockData.getMockMemoryAnalytics(userId);
  }
  
  // 获取个人词库状态
  Future<List<VocabularyStatus>> getVocabularyStatus(
    String userId, {
    String? status,
    String? rootId,
    int offset = 0,
    int limit = 20,
  }) async {
    return _mockData.getMockVocabularyStatus(
      userId,
      status: status,
      rootId: rootId,
      offset: offset,
      limit: limit,
    );
  }
  
  // 获取学习热图数据
  Future<Map<DateTime, int>> getStudyHeatmap(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _mockData.getMockStudyHeatmap(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}