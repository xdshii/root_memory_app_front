class MemoryAnalytics {
  final List<RetentionPoint> retentionCurve;
  final Map<String, double> forgettingRateByCategory;
  final Map<MemoryDifficulty, int> wordCountByDifficulty;
  final double overallRetentionRate;
  
  MemoryAnalytics({
    required this.retentionCurve,
    required this.forgettingRateByCategory,
    required this.wordCountByDifficulty,
    required this.overallRetentionRate,
  });
}

class RetentionPoint {
  final int daysSinceLearn;
  final double retentionPercentage;
  
  RetentionPoint({
    required this.daysSinceLearn,
    required this.retentionPercentage,
  });
}