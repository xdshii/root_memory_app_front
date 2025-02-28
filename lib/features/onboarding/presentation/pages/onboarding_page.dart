import 'package:flutter/material.dart';

import '../../../../core/themes/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedExamType = 'TOEFL';
  String _selectedLearningMode = 'UNIT';
  
  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: '通过词根记忆法高效学习英语',
      description: '我们的应用使用系统化的词根学习体系，帮助你快速扩充词汇量，掌握英语单词的构成规律。',
      image: 'assets/images/onboarding1.png',
    ),
    OnboardingSlide(
      title: '三维学习体验',
      description: '通过图像、文字和声音的结合，强化记忆，让学习更高效。',
      image: 'assets/images/onboarding2.png',
    ),
    OnboardingSlide(
      title: '科学的复习机制',
      description: '基于艾宾浩斯遗忘曲线的复习提醒，确保你的记忆长久保持。',
      image: 'assets/images/onboarding3.png',
    ),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _navigateToNextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _showExamTypeSelectionSheet();
    }
  }
  
  void _showExamTypeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '请选择您的考试类型',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 考试类型选项
              _buildExamTypeOptions(setState),
              const SizedBox(height: 24),
              const Text(
                '请选择您的学习模式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 学习模式选项
              _buildLearningModeOptions(setState),
              const SizedBox(height: 24),
              // 开始学习按钮
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: 导航到关卡列表页面
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('开始学习'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildExamTypeOptions(StateSetter setState) {
    return Column(
      children: [
        _buildExamTypeOption(
          'TOEFL',
          '托福考试 - 适合出国留学的学生',
          setState,
        ),
        _buildExamTypeOption(
          'IELTS',
          '雅思考试 - 适合出国留学、工作的学生',
          setState,
        ),
        _buildExamTypeOption(
          'GRE',
          'GRE考试 - 适合申请国外研究生的学生',
          setState,
        ),
        _buildExamTypeOption(
          'CET6',
          '六级考试 - 适合大学英语水平测试',
          setState,
        ),
      ],
    );
  }
  
  Widget _buildExamTypeOption(
    String value,
    String description,
    StateSetter setState,
  ) {
    return RadioListTile<String>(
      title: Text(value),
      subtitle: Text(description),
      value: value,
      groupValue: _selectedExamType,
      onChanged: (newValue) {
        setState(() {
          _selectedExamType = newValue!;
        });
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }
  
  Widget _buildLearningModeOptions(StateSetter setState) {
    return Column(
      children: [
        _buildLearningModeOption(
          'UNIT',
          '关卡模式 - 系统化学习词根及派生词汇',
          setState,
        ),
        _buildLearningModeOption(
          'FLASHCARD',
          '闪卡模式 - 自由定制学习词汇',
          setState,
        ),
      ],
    );
  }
  
  Widget _buildLearningModeOption(
    String value,
    String description,
    StateSetter setState,
  ) {
    return RadioListTile<String>(
      title: Text(value),
      subtitle: Text(description),
      value: value,
      groupValue: _selectedLearningMode,
      onChanged: (newValue) {
        setState(() {
          _selectedLearningMode = newValue!;
        });
      },
      activeColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildSlidePage(_slides[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 页面指示器
                Row(
                  children: _buildPageIndicators(),
                ),
                // 下一步按钮
                ElevatedButton(
                  onPressed: _navigateToNextPage,
                  child: Text(_currentPage < _slides.length - 1 ? '下一步' : '开始'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSlidePage(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图片占位符（在真实环境中应替换为实际图像）
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          // 标题
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 描述
          Text(
            slide.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  List<Widget> _buildPageIndicators() {
    List<Widget> indicators = [];
    
    for (int i = 0; i < _slides.length; i++) {
      indicators.add(
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage
                ? AppTheme.primaryColor
                : const Color(0xFFD9D9D9),
          ),
        ),
      );
    }
    
    return indicators;
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String image;
  
  OnboardingSlide({
    required this.title,
    required this.description,
    required this.image,
  });
}