class LearningStatistics {
  final int totalLevels;
  final int completedLevels;
  final int totalRoots;
  final int masteredRoots;
  final int totalWords;
  final int masteredWords;
  final double averageScore;
  final List<DailyStudyStat> studyTimeStats;
  
  LearningStatistics({
    required this.totalLevels,
    required this.completedLevels,
    required this.totalRoots,
    required this.masteredRoots,
    required this.totalWords,
    required this.masteredWords,
    required this.averageScore,
    required this.studyTimeStats,
  });
  
  // 计算总体完成率
  double get overallCompletionRate => completedLevels / totalLevels * 100;
  
  // 计算词根掌握率
  double get rootMasteryRate => masteredRoots / totalRoots * 100;
  
  // 计算词汇掌握率
  double get wordMasteryRate => masteredWords / totalWords * 100;
  
  // 计算近期学习趋势（7天平均）
  double get recentStudyTrend {
    if (studyTimeStats.length < 7) return 0;
    final recent = studyTimeStats.take(7).fold(0, (sum, stat) => sum + stat.minutes);
    return recent / 7;
  }
}

class DailyStudyStat {
  final DateTime date;
  final int minutes;
  
  DailyStudyStat({
    required this.date,
    required this.minutes,
  });
}