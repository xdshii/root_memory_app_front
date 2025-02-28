import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/root.dart';

class RootCard extends StatelessWidget {
  final Root root;
  final VoidCallback onContinue;
  final VoidCallback onPlayAudio;
  
  const RootCard({
    Key? key,
    required this.root,
    required this.onContinue,
    required this.onPlayAudio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 词根图像
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.grey[300],
                child: root.imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: root.imageUrl,
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
          
          const SizedBox(height: 24),
          
          // 词根信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '词根: ${root.text}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: onPlayAudio,
                tooltip: '播放发音',
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 来源
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '来源: ${root.origin}',
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 基本含义
          const Text(
            '基本含义:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            root.meaning,
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.textDark,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 记忆辅助
          const Text(
            '记忆提示:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            root.memoryAid,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 示例
          if (root.examples.isNotEmpty) ...[
            const Text(
              '常见例子:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            ...root.examples.map((example) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $example',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            )).toList(),
            const SizedBox(height: 24),
          ],
          
          // 继续按钮
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('开始学习词汇'),
          ),
          
          const SizedBox(height: 8),
          
          // 自动继续提示
          const Text(
            '页面将在5秒后自动继续',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}