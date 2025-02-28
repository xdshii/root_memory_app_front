import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/statistics/learning_statistics.dart';
import '../../../../data/models/statistics/memory_analytics.dart';
import '../../../../data/repositories/statistics_repository.dart';
import '../blocs/statistics_bloc.dart';
import '../widgets/progress_overview_card.dart';
import '../widgets/learning_trend_chart.dart';
import '../widgets/memory_retention_chart.dart';
import '../widgets/vocabulary_status_pie.dart';
import 'personal_vocabulary_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StatisticsBloc _statisticsBloc;
  final StatisticsRepository _repository = StatisticsRepository();
  String _selectedPeriod = 'month'; // 默认显示本月数据
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _statisticsBloc = StatisticsBloc(repository: _repository);
    
    // 加载统计数据
    _statisticsBloc.add(LoadLearningStatistics(
      userId: 'current_user',
      period: _selectedPeriod,
    ));
    _statisticsBloc.add(const LoadMemoryAnalytics(
      userId: 'current_user',
    ));
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _statisticsBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _statisticsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('学习统计'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '学习进度'),
              Tab(text: '记忆效果'),
              Tab(text: '个人词库'),
            ],
          ),
          actions: [
            // 时间范围选择
            PopupMenuButton<String>(
              icon: const Icon(Icons.calendar_today),
              onSelected: (String period) {
                setState(() {
                  _selectedPeriod = period;
                });
                // 重新加载数据
                _statisticsBloc.add(LoadLearningStatistics(
                  userId: 'current_user',
                  period: period,
                ));
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'week',
                  child: Text('本周'),
                ),
                const PopupMenuItem<String>(
                  value: 'month',
                  child: Text('本月'),
                ),
                const PopupMenuItem<String>(
                  value: 'year',
                  child: Text('今年'),
                ),
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Text('全部'),
                ),
              ],
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLearningProgressTab(),
            _buildMemoryAnalyticsTab(),
            _buildPersonalVocabularyTab(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLearningProgressTab() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      buildWhen: (previous, current) => 
        current is LearningStatisticsLoaded || 
        current is StatisticsLoading,
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LearningStatisticsLoaded) {
          final stats = state.statistics;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 概览卡片
                ProgressOverviewCard(statistics: stats),
                
                const SizedBox(height: 24),
                
                // 学习进度百分比
                _buildProgressSection(stats),
                
                const SizedBox(height: 24),
                
                // 学习时间趋势
                _buildLearningTrendSection(stats),
                
                const SizedBox(height: 24),
                
                // 学习热图
                _buildHeatmapSection(),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('无法加载统计数据'),
          );
        }
      },
    );
  }
  
  Widget _buildProgressSection(LearningStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '学习进度',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildProgressIndicator(
              title: '关卡完成率',
              percentage: stats.overallCompletionRate,
              color: AppTheme.primaryColor,
            ),
            _buildProgressIndicator(
              title: '词根掌握率',
              percentage: stats.rootMasteryRate,
              color: Colors.orange,
            ),
            _buildProgressIndicator(
              title: '词汇掌握率',
              percentage: stats.wordMasteryRate,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildProgressIndicator({
    required String title,
    required double percentage,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLearningTrendSection(LearningStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '学习时间趋势',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LearningTrendChart(
            studyStats: stats.studyTimeStats,
            period: _selectedPeriod,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '日均学习时间: ${stats.recentStudyTrend.toStringAsFixed(1)}分钟',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeatmapSection() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      buildWhen: (previous, current) => 
        current is StudyHeatmapLoaded || 
        current is StatisticsLoading,
      builder: (context, state) {
        if (state is StudyHeatmapLoaded) {
          // 在这里我们简化处理，仅显示热图的文本描述
          // 实际应用中应实现可视化热图组件
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '学习热图',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '此处将显示过去180天的学习热图\n每个方块代表一天，颜色深浅表示学习时长',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '过去30天总学习时间: ${state.totalMinutes}分钟',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
  
  Widget _buildMemoryAnalyticsTab() {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      buildWhen: (previous, current) => 
        current is MemoryAnalyticsLoaded || 
        current is StatisticsLoading,
      builder: (context, state) {
        if (state is StatisticsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is MemoryAnalyticsLoaded) {
          final analytics = state.analytics;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 记忆保留率概览
                _buildRetentionOverview(analytics),
                
                const SizedBox(height: 24),
                
                // 记忆曲线图表
                _buildRetentionCurve(analytics),
                
                const SizedBox(height: 24),
                
                // 单词难度分布
                _buildWordDifficultyDistribution(analytics),
                
                const SizedBox(height: 24),
                
                // 词汇类别遗忘率
                _buildCategoryForgettingRates(analytics),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text('无法加载记忆分析数据'),
          );
        }
      },
    );
  }
  
  Widget _buildRetentionOverview(MemoryAnalytics analytics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '记忆保留率概览',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: analytics.overallRetentionRate / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getRetentionColor(analytics.overallRetentionRate),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${analytics.overallRetentionRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getRetentionColor(analytics.overallRetentionRate),
                            ),
                          ),
                          const Text(
                            '记忆保留',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '记忆效率分析基于你的学习和复习行为，结合艾宾浩斯遗忘曲线计算得出。保持科学的复习节奏可以显著提高记忆保留率。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRetentionColor(double rate) {
    if (rate >= 80) {
      return Colors.green;
    } else if (rate >= 60) {
      return Colors.blue;
    } else if (rate >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  Widget _buildRetentionCurve(MemoryAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '记忆保留曲线',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: MemoryRetentionChart(
            retentionCurve: analytics.retentionCurve,
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            '曲线显示记忆随时间衰减的规律，基于艾宾浩斯遗忘曲线',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWordDifficultyDistribution(MemoryAnalytics analytics) {
    final totalWords = analytics.wordCountByDifficulty.values
        .fold(0, (sum, count) => sum + count);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '单词难度分布',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: VocabularyStatusPie(
            wordCountByDifficulty: analytics.wordCountByDifficulty,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: Colors.green,
              label: '简单',
              count: analytics.wordCountByDifficulty[MemoryDifficulty.easy] ?? 0,
              total: totalWords,
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: Colors.orange,
              label: '一般',
              count: analytics.wordCountByDifficulty[MemoryDifficulty.medium] ?? 0,
              total: totalWords,
            ),
            const SizedBox(width: 16),
            _buildLegendItem(
              color: Colors.red,
              label: '困难',
              count: analytics.wordCountByDifficulty[MemoryDifficulty.hard] ?? 0,
              total: totalWords,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
    required int total,
  }) {
    final percentage = (count / total * 100).toStringAsFixed(1);
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count ($percentage%)',
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryForgettingRates(MemoryAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '不同词性的遗忘率',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: analytics.forgettingRateByCategory.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      _getCategoryName(entry.key),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getForgettingColor(entry.value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value}%',
                    style: TextStyle(
                      color: _getForgettingColor(entry.value),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            '遗忘率越低越好，数值表示30天后未经复习的预期遗忘比例',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getCategoryName(String key) {
    switch (key) {
      case 'noun':
        return '名词';
      case 'verb':
        return '动词';
      case 'adjective':
        return '形容词';
      case 'adverb':
        return '副词';
      case 'phrase':
        return '短语';
      default:
        return key;
    }
  }
  
  Color _getForgettingColor(double rate) {
    if (rate <= 30) {
      return Colors.green;
    } else if (rate <= 40) {
      return Colors.blue;
    } else if (rate <= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  Widget _buildPersonalVocabularyTab() {
    return const PersonalVocabularyPage();
  }
}