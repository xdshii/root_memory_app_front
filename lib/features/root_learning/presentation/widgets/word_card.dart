import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/root.dart';
import '../../../../data/models/word.dart';

class WordCard extends StatelessWidget {
  final Word word;
  final Root root;
  final VoidCallback onPlayAudio;
  
  const WordCard({
    Key? key,
    required this.word,
    required this.root,
    required this.onPlayAudio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 单词图像
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.grey[300],
                child: word.imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: word.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 单词和发音
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.text,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      word.phonetic,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, size: 30),
                onPressed: onPlayAudio,
                tooltip: '播放发音',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 构词分析
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '构词分析:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                _buildWordStructureAnalysis(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 词性和定义
          ...word.definitions.map((definition) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, 
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    definition.pos,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  definition.meaning,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                if (definition.examples.isNotEmpty) ...[
                  const Text(
                    '例句:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...definition.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $example',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  )).toList(),
                ],
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 8),
          
          // 考试标签
          Wrap(
            spacing: 8,
            children: word.examTags.map((tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.grey[200],
            )).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWordStructureAnalysis() {
    // 提取前缀
    final prefixes = word.prefixes.isNotEmpty 
        ? word.prefixes.join('-') + '-' 
        : '';
    
    // 提取后缀
    final suffixes = word.suffixes.isNotEmpty 
        ? '-' + word.suffixes.join('-') 
        : '';
    
    // 词根部分 (简化处理，实际应用中需要更精确地定位词根)
    String remainingPart = word.text;
    if (prefixes.isNotEmpty) {
      remainingPart = remainingPart.substring(prefixes.length - 1);
    }
    if (suffixes.isNotEmpty) {
      remainingPart = remainingPart.substring(
        0, 
        remainingPart.length - suffixes.length + 1,
      );
    }
    
    String formattedPrefix = '';
    String formattedRoot = '';
    String formattedSuffix = '';
    String explanation = '';
    
    // 格式化前缀
    if (prefixes.isNotEmpty) {
      formattedPrefix = prefixes;
      explanation += '${prefixes.replaceAll('-', '')} (${_getPrefixMeaning(prefixes)})';
    }
    
    // 格式化词根
    formattedRoot = remainingPart;
    if (explanation.isNotEmpty) {
      explanation += ' + ';
    }
    explanation += '${root.text} (${root.meaning})';
    
    // 格式化后缀
    if (suffixes.isNotEmpty) {
      formattedSuffix = suffixes;
      explanation += ' + ${suffixes.replaceAll('-', '')} (${_getSuffixMeaning(suffixes)})';
    }
    
    explanation += ' = "${_getFullMeaning()}"';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 可视化构词
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
            children: [
              if (formattedPrefix.isNotEmpty)
                TextSpan(
                  text: formattedPrefix,
                  style: const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              TextSpan(
                text: formattedRoot,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (formattedSuffix.isNotEmpty)
                TextSpan(
                  text: formattedSuffix,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(explanation),
      ],
    );
  }
  
  String _getPrefixMeaning(String prefix) {
    // 简化的前缀含义映射
    final Map<String, String> prefixMeanings = {
      'pre-': '提前',
      'con-': '共同',
      're-': '重新',
      'in-': '向内',
      'de-': '向下',
      'dis-': '分离',
      'un-': '不',
      'im-': '不',
    };
    
    // 清理前缀字符串
    final cleanPrefix = prefix.replaceAll('-', '');
    return prefixMeanings[prefix] ?? cleanPrefix;
  }
  
  String _getSuffixMeaning(String suffix) {
    // 简化的后缀含义映射
    final Map<String, String> suffixMeanings = {
      '-tion': '动作/状态',
      '-ity': '状态/性质',
      '-ment': '动作/结果',
      '-ness': '状态/性质',
      '-ly': '方式',
      '-ful': '充满的',
      '-less': '没有的',
      '-er': '人/物',
    };
    
    // 清理后缀字符串
    final cleanSuffix = suffix.replaceAll('-', '');
    return suffixMeanings[suffix] ?? cleanSuffix;
  }
  
  String _getFullMeaning() {
    // 获取第一个定义作为完整含义
    if (word.definitions.isNotEmpty) {
      return word.definitions.first.meaning;
    }
    return '';
  }
}