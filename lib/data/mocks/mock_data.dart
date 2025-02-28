import '../models/level.dart';
import '../models/root.dart';
import '../models/user.dart';
import '../models/user_progress.dart';
import '../models/word.dart';

class MockData {
  // 单例模式
  static final MockData _instance = MockData._internal();
  
  factory MockData() {
    return _instance;
  }
  
  MockData._internal();
  
  // 模拟用户数据
  User getMockUser() {
    return User(
      id: 'user_001',
      username: 'testuser',
      email: 'test@example.com',
      examType: 'TOEFL',
      preferredMode: 'UNIT',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLogin: DateTime.now(),
      deviceToken: 'mock-device-token',
      settings: UserSettings(
        reminderEnabled: true,
        reminderTime: '20:00',
        soundEnabled: true,
      ),
    );
  }
  
  // 模拟词根数据
  List<Root> getMockRoots() {
    return [
      Root(
        id: 'root_dict_001',
        text: 'dict',
        origin: 'Latin',
        meaning: '说话，断言',
        memoryAid: '想象一位"法官(裁判官)"正在"宣判(dictate)"命令。',
        imageUrl: 'assets/images/roots/dict.jpg',
        audioUrl: 'assets/audio/dict.mp3',
        examples: [
          'dict-ion (词典): 收录词语的书',
          'ver-dict (判决): 正式宣布的决定',
          'pre-dict (预测): 提前说出将要发生的事'
        ],
        difficulty: 2,
        frequency: {
          'GRE': 85,
          'TOEFL': 92,
          'IELTS': 88,
          'CET6': 90
        },
      ),
      Root(
        id: 'root_spec_002',
        text: 'spect',
        origin: 'Latin',
        meaning: '看，观察',
        memoryAid: '想象自己戴着"眼镜(spectacles)"观察世界。',
        imageUrl: 'assets/images/roots/spect.jpg',
        audioUrl: 'assets/audio/spect.mp3',
        examples: [
          'in-spect (检查): 仔细观察',
          'retro-spect (回顾): 向后看',
          'pro-spect (前景): 向前看'
        ],
        difficulty: 2,
        frequency: {
          'GRE': 88,
          'TOEFL': 90,
          'IELTS': 85,
          'CET6': 87
        },
      ),
    ];
  }
  
  // 模拟单词数据
  List<Word> getMockWords() {
    return [
      Word(
        id: 'word_predict_001',
        text: 'predict',
        rootIds: ['root_dict_001'],
        prefixes: ['pre'],
        suffixes: [],
        phonetic: '/prɪˈdɪkt/',
        audioUrl: 'assets/audio/words/predict.mp3',
        imageUrl: 'assets/images/words/predict.jpg',
        partOfSpeech: ['verb'],
        definitions: [
          WordDefinition(
            pos: 'verb',
            meaning: '预测，预言',
            examples: [
              'Scientists predict that the hurricane will reach land by Friday.',
              'It\'s difficult to predict how the market will react to this news.'
            ],
          ),
        ],
        examTags: ['TOEFL', 'IELTS', 'CET6'],
        difficulty: 2,
      ),
      Word(
        id: 'word_dictate_002',
        text: 'dictate',
        rootIds: ['root_dict_001'],
        prefixes: [],
        suffixes: [],
        phonetic: '/ˈdɪkteɪt/',
        audioUrl: 'assets/audio/words/dictate.mp3',
        imageUrl: 'assets/images/words/dictate.jpg',
        partOfSpeech: ['verb', 'noun'],
        definitions: [
          WordDefinition(
            pos: 'verb',
            meaning: '口述；命令',
            examples: [
              'She dictated a letter to her secretary.',
              'I won\'t let anyone dictate how I should live my life.'
            ],
          ),
          WordDefinition(
            pos: 'noun',
            meaning: '命令；指示',
            examples: [
              'The dictates of fashion',
            ],
          ),
        ],
        examTags: ['TOEFL', 'GRE'],
        difficulty: 3,
      ),
    ];
  }
  
  List<Level> getMockLevels() {
  return [
    Level(
      id: 'level_dict_001',
      title: '词根 DICT - 说话，断言',
      rootId: 'root_dict_001',
      examType: 'TOEFL',
      sequence: 1,
      wordIds: [
        'word_predict_001',
        'word_dictate_002',
        'word_contradict_003',
        'word_verdict_004',
        'word_dictionary_005',
        'word_indict_006',
        'word_edict_007',
      ],
      challengeWordIds: [
        'word_benediction_101',
        'word_malediction_102',
      ],
      imageUrl: 'assets/images/levels/dict_level.jpg',
      description: '这个关卡将帮助你掌握表示"说话，断言"的词根DICT及其派生词。',
      estimatedTime: 15,
    ),
    Level(
      id: 'level_spect_002',
      title: '词根 SPECT - 看，观察',
      rootId: 'root_spect_002',
      examType: 'TOEFL',
      sequence: 2,
      wordIds: [
        'word_inspect_007',
        'word_spectacle_008',
        'word_perspective_009',
        'word_prospect_010',
        'word_retrospect_011',
        'word_circumspect_012',
      ],
      challengeWordIds: [
        'word_introspection_103',
        'word_spectator_104',
      ],
      imageUrl: 'assets/images/levels/spect_level.jpg',
      description: '这个关卡将帮助你掌握表示"看，观察"的词根SPECT及其派生词。',
      estimatedTime: 12,
    ),
    // 更多模拟关卡...
  ];
}

// 获取模拟用户进度
List<UserProgress> getMockUserProgress(String userId) {
  return [
    UserProgress(
      id: 'progress_001',
      userId: userId,
      levelId: 'level_dict_001',
      status: 'COMPLETED',
      progress: 100,
      testResults: [
        TestResult(
          attemptAt: DateTime.now().subtract(const Duration(days: 5)),
          score: 85,
          correctCount: 17,
          totalCount: 20,
        ),
      ],
      wordStatus: [
        WordStatus(
          wordId: 'word_predict_001',
          status: 'MASTERED',
          correct: 3,
          incorrect: 0,
          lastReviewed: DateTime.now().subtract(const Duration(days: 2)),
        ),
        WordStatus(
          wordId: 'word_dictate_002',
          status: 'LEARNING',
          correct: 2,
          incorrect: 1,
          lastReviewed: DateTime.now().subtract(const Duration(days: 2)),
        ),
        // 更多单词状态...
      ],
      reviews: [
        Review(
          reviewType: 'UNIT',
          scheduledFor: DateTime.now().add(const Duration(days: 1)),
          completedAt: null,
          score: null,
        ),
      ],
    ),
    UserProgress(
      id: 'progress_002',
      userId: userId,
      levelId: 'level_spect_002',
      status: 'LEARNING',
      progress: 40,
      testResults: [],
      wordStatus: [
        WordStatus(
          wordId: 'word_inspect_007',
          status: 'LEARNING',
          correct: 1,
          incorrect: 0,
          lastReviewed: DateTime.now().subtract(const Duration(days: 1)),
        ),
        // 更多单词状态...
      ],
      reviews: [],
    ),
    // 更多用户进度...
  ];
}

    // 获取模拟测验数据
    Quiz getMockQuizForLevel(String levelId) {
    // 获取关卡信息
    final level = getMockLevels().firstWhere(
        (l) => l.id == levelId,
        orElse: () => throw Exception('Level not found'),
    );
    
    // 获取词根信息
    final root = getMockRoots().firstWhere(
        (r) => r.id == level.rootId,
        orElse: () => throw Exception('Root not found'),
    );
    
    // 获取关卡单词
    final levelWords = getMockWords().where(
        (w) => level.wordIds.contains(w.id),
    ).toList();
    
    // 获取挑战单词
    final challengeWords = getMockWords().where(
        (w) => level.challengeWordIds.contains(w.id),
    ).toList();
    
    // 创建测验问题
    List<QuizQuestion> questions = [];
    
    // 级别1: 单词→选择正确释义 (每个单词一题)
    for (var word in levelWords) {
        questions.add(_createWordToMeaningQuestion(word, levelWords));
    }
    
    // 级别2: 释义→选择正确单词 (每个单词一题)
    for (var word in levelWords) {
        questions.add(_createMeaningToWordQuestion(word, levelWords));
    }
    
    // 级别3: 句子填空 (每个单词一题)
    for (var word in levelWords) {
        questions.add(_createSentenceCompletionQuestion(word, levelWords));
    }
    
    // 级别4: 挑战题 (未学过但含相同词根的词)
    for (var word in challengeWords) {
        questions.add(_createChallengeQuestion(word, root, levelWords));
    }
    
    return Quiz(
        id: 'quiz_${levelId}_${DateTime.now().millisecondsSinceEpoch}',
        levelId: levelId,
        questions: questions,
        totalQuestions: questions.length,
    );
    }

    // 级别1: 单词→选择正确释义
    QuizQuestion _createWordToMeaningQuestion(Word correctWord, List<Word> allWords) {
    // 获取正确单词的第一个定义
    final correctDefinition = correctWord.definitions.first;
    
    // 创建正确选项
    final correctOption = QuizOption(
        id: 'option_correct',
        text: correctDefinition.meaning,
    );
    
    // 创建干扰选项 (从其他单词中随机选择3个不同的)
    List<QuizOption> distractors = [];
    final otherWords = allWords.where((w) => w.id != correctWord.id).toList();
    otherWords.shuffle();
    
    for (var i = 0; i < 3 && i < otherWords.length; i++) {
        distractors.add(QuizOption(
        id: 'option_$i',
        text: otherWords[i].definitions.first.meaning,
        ));
    }
    
    // 合并所有选项并随机排序
    List<QuizOption> allOptions = [correctOption, ...distractors];
    allOptions.shuffle();
    
    return QuizQuestion(
        id: 'q_word_${correctWord.id}',
        wordId: correctWord.id,
        type: QuestionType.wordToMeaning,
        question: '单词 "${correctWord.text}" 的含义是什么?',
        options: allOptions,
        correctOptionId: correctOption.id,
        level: 1,
        explanation: '${correctWord.text} 是由词根 ${correctWord.rootIds.first} 构成，意思是"${correctDefinition.meaning}"。',
    );
    }

    // 级别2: 释义→选择正确单词
    QuizQuestion _createMeaningToWordQuestion(Word correctWord, List<Word> allWords) {
    // 获取正确单词的第一个定义
    final correctDefinition = correctWord.definitions.first;
    
    // 创建正确选项
    final correctOption = QuizOption(
        id: 'option_correct',
        text: correctWord.text,
    );
    
    // 创建干扰选项 (从其他单词中随机选择3个不同的)
    List<QuizOption> distractors = [];
    final otherWords = allWords.where((w) => w.id != correctWord.id).toList();
    otherWords.shuffle();
    
    for (var i = 0; i < 3 && i < otherWords.length; i++) {
        distractors.add(QuizOption(
        id: 'option_$i',
        text: otherWords[i].text,
        ));
    }
    
    // 合并所有选项并随机排序
    List<QuizOption> allOptions = [correctOption, ...distractors];
    allOptions.shuffle();
    
    return QuizQuestion(
        id: 'q_meaning_${correctWord.id}',
        wordId: correctWord.id,
        type: QuestionType.meaningToWord,
        question: '哪个单词的含义是 "${correctDefinition.meaning}"?',
        options: allOptions,
        correctOptionId: correctOption.id,
        level: 2,
        explanation: '${correctWord.text} 含义为"${correctDefinition.meaning}"，来自词根 ${correctWord.rootIds.first}。',
    );
    }

    // 级别3: 句子填空 (选择)
    QuizQuestion _createSentenceCompletionQuestion(Word correctWord, List<Word> allWords) {
    // 获取正确单词的例句，如果有的话
    String sentenceTemplate = '';
    if (correctWord.definitions.isNotEmpty && 
        correctWord.definitions.first.examples.isNotEmpty) {
        sentenceTemplate = correctWord.definitions.first.examples.first;
    } else {
        // 如果没有例句，创建一个简单的句子
        sentenceTemplate = 'The professor tried to _____ the complex theory to the students.';
    }
    
    // 在句子中插入空白处替换原单词
    String sentence = sentenceTemplate.replaceAll(correctWord.text, '______');
    
    // 创建正确选项
    final correctOption = QuizOption(
        id: 'option_correct',
        text: correctWord.text,
    );
    
    // 创建干扰选项 (从其他单词中随机选择3个相同词性的)
    List<QuizOption> distractors = [];
    final otherWords = allWords.where((w) => 
        w.id != correctWord.id && 
        w.partOfSpeech.any((pos) => correctWord.partOfSpeech.contains(pos))
    ).toList();
    
    otherWords.shuffle();
    
    for (var i = 0; i < 3 && i < otherWords.length; i++) {
        distractors.add(QuizOption(
        id: 'option_$i',
        text: otherWords[i].text,
        ));
    }
    
    // 合并所有选项并随机排序
    List<QuizOption> allOptions = [correctOption, ...distractors];
    allOptions.shuffle();
    
    return QuizQuestion(
        id: 'q_sentence_${correctWord.id}',
        wordId: correctWord.id,
        type: QuestionType.sentenceCompletion,
        question: '选择合适的单词填空: $sentence',
        options: allOptions,
        correctOptionId: correctOption.id,
        level: 3,
        explanation: '正确答案是 ${correctWord.text}，意思是"${correctWord.definitions.first.meaning}"。',
    );
    }

    // 级别4: 挑战题 (未学过但含相同词根的词)
    QuizQuestion _createChallengeQuestion(Word challengeWord, Root root, List<Word> levelWords) {
    // 创建问题描述，基于词根知识推断新单词
    final question = '基于你对词根 ${root.text} (${root.meaning}) 的了解，推断单词 "${challengeWord.text}" 的可能含义:';
    
    // 创建正确选项
    final correctOption = QuizOption(
        id: 'option_correct',
        text: challengeWord.definitions.first.meaning,
    );
    
    // 创建干扰选项 (完全不同的含义)
    List<QuizOption> distractors = [
        QuizOption(
        id: 'option_1',
        text: '与 ${root.meaning} 相反的意思',
        ),
        QuizOption(
        id: 'option_2',
        text: '与 ${root.meaning} 无关的行为或状态',
        ),
        QuizOption(
        id: 'option_3',
        text: '不含 ${root.meaning} 意义的事物',
        ),
    ];
    
    // 合并所有选项并随机排序
    List<QuizOption> allOptions = [correctOption, ...distractors];
    allOptions.shuffle();
    
    return QuizQuestion(
        id: 'q_challenge_${challengeWord.id}',
        wordId: challengeWord.id,
        type: QuestionType.challenge,
        question: question,
        options: allOptions,
        correctOptionId: correctOption.id,
        level: 4,
        explanation: '${challengeWord.text} 含有词根 ${root.text}，表示"${root.meaning}"，' +
            '因此其含义为"${challengeWord.definitions.first.meaning}"。' +
            '通过分析词根，你可以推断出许多相关单词的含义。',
    );
    }

    // 获取用户的复习计划
    List<ReviewPlan> getMockReviewPlans(String userId) {
    final now = DateTime.now();
    
    return [
        // 已过期的复习
        ReviewPlan(
        id: 'review_001',
        userId: userId,
        levelId: 'level_dict_001',
        type: ReviewType.unit,
        scheduledFor: now.subtract(const Duration(days: 1)),
        status: ReviewStatus.overdue,
        wordIds: ['word_predict_001', 'word_dictate_002', 'word_contradict_003'],
        ),
        // 今日复习
        ReviewPlan(
        id: 'review_002',
        userId: userId,
        levelId: 'level_spect_002',
        type: ReviewType.unit,
        scheduledFor: now.add(const Duration(hours: 2)),
        status: ReviewStatus.scheduled,
        wordIds: ['word_inspect_007', 'word_spectacle_008', 'word_perspective_009'],
        ),
        // 未来复习
        ReviewPlan(
        id: 'review_003',
        userId: userId,
        levelId: 'level_dict_001',
        type: ReviewType.unit,
        scheduledFor: now.add(const Duration(days: 2)),
        status: ReviewStatus.scheduled,
        wordIds: ['word_predict_001', 'word_dictate_002', 'word_contradict_003'],
        ),
        // 已完成的复习
        ReviewPlan(
        id: 'review_004',
        userId: userId,
        levelId: 'level_dict_001',
        type: ReviewType.unit,
        scheduledFor: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 3, hours: 1)),
        status: ReviewStatus.completed,
        score: 85,
        wordIds: ['word_predict_001', 'word_dictate_002', 'word_contradict_003'],
        ),
        // 闪卡复习
        ReviewPlan(
        id: 'review_005',
        userId: userId,
        levelId: 'flashcards',
        type: ReviewType.flashcard,
        scheduledFor: now,
        status: ReviewStatus.scheduled,
        wordIds: ['word_contradict_003', 'word_spectacle_008'],
        ),
    ];
    }

    // 获取用户的闪卡复习数据
    List<FlashcardReview> getMockFlashcardReviews(String userId) {
    final now = DateTime.now();
    
    return [
        FlashcardReview(
        wordId: 'word_contradict_003',
        difficulty: MemoryDifficulty.hard,
        lastReviewed: now.subtract(const Duration(days: 1)),
        nextReview: now.add(const Duration(hours: 1)),
        ),
        FlashcardReview(
        wordId: 'word_spectacle_008',
        difficulty: MemoryDifficulty.medium,
        lastReviewed: now.subtract(const Duration(days: 3)),
        nextReview: now,
        ),
        FlashcardReview(
        wordId: 'word_dictate_002',
        difficulty: MemoryDifficulty.easy,
        lastReviewed: now.subtract(const Duration(days: 3)),
        nextReview: now.add(const Duration(days: 4)),
        ),
    ];
    }

    // 生成新的复习计划
    ReviewPlan generateReviewPlan({
    required String userId,
    required String levelId,
    required ReviewType type,
    required DateTime scheduledFor,
    required List<String> wordIds,
    }) {
    return ReviewPlan(
        id: 'review_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        levelId: levelId,
        type: type,
        scheduledFor: scheduledFor,
        status: ReviewStatus.scheduled,
        wordIds: wordIds,
    );
    }

    // 根据艾宾浩斯遗忘曲线计算下次复习时间
    DateTime calculateNextReviewTime(MemoryDifficulty difficulty) {
    final now = DateTime.now();
    
    switch (difficulty) {
        case MemoryDifficulty.hard:
        return now.add(const Duration(days: 1));
        case MemoryDifficulty.medium:
        return now.add(const Duration(days: 3));
        case MemoryDifficulty.easy:
        return now.add(const Duration(days: 7));
    }
    }
        // 添加到现有的MockData类中

    // 获取模拟学习统计数据
    LearningStatistics getMockLearningStatistics(String userId, {String? period}) {
    // 默认为"all"时段
    period ??= 'all';
    
    // 基于当前日期生成动态数据
    final now = DateTime.now();
    final studyTimeStats = <DailyStudyStat>[];
    
    // 生成过去30天的学习数据
    for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        // 随机生成学习时间，周末时间较多
        final isWeekend = date.weekday == 6 || date.weekday == 7;
        final minutes = 15 + (isWeekend ? 30 : 0) + (Random().nextInt(30));
        studyTimeStats.add(DailyStudyStat(date: date, minutes: minutes));
    }
    
    return LearningStatistics(
        totalLevels: 20,
        completedLevels: 8,
        totalRoots: 30,
        masteredRoots: 12,
        totalWords: 240,
        masteredWords: 85,
        averageScore: 82.5,
        studyTimeStats: studyTimeStats,
    );
    }

    // 获取模拟记忆分析数据
    MemoryAnalytics getMockMemoryAnalytics(String userId) {
    // 基于艾宾浩斯遗忘曲线生成记忆保留率数据
    final retentionCurve = <RetentionPoint>[];
    
    // 经典艾宾浩斯遗忘曲线数据点
    final retentionPoints = [
        [0, 100.0],   // 学习当天
        [1, 70.0],    // 1天后
        [2, 65.0],    // 2天后
        [3, 62.0],    // 3天后
        [5, 58.0],    // 5天后
        [7, 55.0],    // 1周后
        [14, 45.0],   // 2周后
        [30, 40.0],   // 1个月后
        [60, 35.0],   // 2个月后
        [90, 30.0],   // 3个月后
    ];
    
    for (var point in retentionPoints) {
        retentionCurve.add(RetentionPoint(
        daysSinceLearn: point[0] as int,
        retentionPercentage: point[1] as double,
        ));
    }
    
    // 模拟不同类别单词的遗忘率
    final forgettingRateByCategory = {
        'noun': 35.0,
        'verb': 40.0,
        'adjective': 30.0,
        'adverb': 45.0,
        'phrase': 50.0,
    };
    
    // 模拟不同难度单词的数量
    final wordCountByDifficulty = {
        MemoryDifficulty.easy: 45,
        MemoryDifficulty.medium: 30,
        MemoryDifficulty.hard: 10,
    };
    
    return MemoryAnalytics(
        retentionCurve: retentionCurve,
        forgettingRateByCategory: forgettingRateByCategory,
        wordCountByDifficulty: wordCountByDifficulty,
        overallRetentionRate: 65.0,
    );
    }

    // 获取模拟词汇状态数据
    List<VocabularyStatus> getMockVocabularyStatus(
    String userId, {
    String? status,
    String? rootId,
    int offset = 0,
    int limit = 20,
    }) {
    // 获取所有单词
    final allWords = getMockWords();
    
    // 生成随机状态
    final statuses = ['MASTERED', 'LEARNING', 'DIFFICULT'];
    final result = <VocabularyStatus>[];
    
    // 根据传入的status筛选
    final filteredWords = status != null
        ? allWords.where((w) => 
            statuses[w.id.hashCode % statuses.length] == status)
            .toList()
        : allWords;
    
    // 根据传入的rootId筛选
    final rootFilteredWords = rootId != null
        ? filteredWords.where((w) => w.rootIds.contains(rootId)).toList()
        : filteredWords;
    
    // 分页处理
    final paginatedWords = rootFilteredWords
        .skip(offset)
        .take(limit)
        .toList();
    
    // 为每个单词生成状态
    for (var word in paginatedWords) {
        // 使用单词ID的哈希值确保同一个单词总是得到相同的状态
        final wordStatus = statuses[word.id.hashCode % statuses.length];
        final correctRate = 50 + (word.id.hashCode % 50); // 50-99%的正确率
        
        result.add(VocabularyStatus(
        word: word,
        status: wordStatus,
        correctRate: correctRate,
        lastReviewed: DateTime.now().subtract(Duration(days: word.id.hashCode % 14)),
        reviewCount: 3 + (word.id.hashCode % 10),
        ));
    }
    
    return result;
    }

    // 获取模拟学习热图数据（过去6个月的学习记录）
    Map<DateTime, int> getMockStudyHeatmap(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    }) {
    final Map<DateTime, int> heatmap = {};
    final now = DateTime.now();
    startDate ??= now.subtract(const Duration(days: 180));
    endDate ??= now;
    
    for (var day = startDate;
        day.isBefore(endDate) || day.isAtSameMomentAs(endDate);
        day = day.add(const Duration(days: 1))) {
        // 生成学习分钟数，周末和工作日不同
        final isWeekend = day.weekday == 6 || day.weekday == 7;
        final studyProbability = isWeekend ? 0.7 : 0.5; // 周末更可能学习
        
        if (Random().nextDouble() < studyProbability) {
        // 如果这天学习了，生成学习时间
        final minutes = 10 + Random().nextInt(50);
        heatmap[DateTime(day.year, day.month, day.day)] = minutes;
        }
    }
    
    return heatmap;
    }
}