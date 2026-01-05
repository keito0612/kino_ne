import 'package:flutter/material.dart';
import 'package:kino_ne/models/tree.dart';

class TreeVisualizer extends StatelessWidget {
  final Tree tree;
  final double baseSize;
  final double titleFontSize;
  final bool isProgressIndicator;

  const TreeVisualizer({
    super.key,
    required this.tree,
    this.titleFontSize = 14,
    this.baseSize = 60,
    this.isProgressIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    // 次のレベルまでの計算
    const charsPerLevel = 100;
    final progress = (tree.totalChars % charsPerLevel) / charsPerLevel;
    final charsNeeded = charsPerLevel - (tree.totalChars % charsPerLevel);

    // 育つほど色が深く、濃くなる
    final treeColor = Color.lerp(
      Colors.lightGreen.shade400,
      Colors.green.shade900,
      (tree.stage / 4).clamp(0.0, 1.0),
    );

    final size = baseSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            // 木のアイコン
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              child: Icon(tree.icon, size: size, color: treeColor),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 木の名前
        Text(
          tree.name,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        // --- 追加：レベルと「あと◯文字」の表示 ---
        if (isProgressIndicator) ...[
          // レベル（Stage）バッジ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: treeColor!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Lv.${tree.stage + 1}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: treeColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 経験値バー
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade200,
                  color: treeColor,
                  minHeight: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // あと◯文字
          Text(
            'あと $charsNeeded 文字',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
