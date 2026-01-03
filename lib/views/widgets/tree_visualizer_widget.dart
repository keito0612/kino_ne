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
    // 育つほど色が深く、濃くなる
    final treeColor = Color.lerp(
      Colors.lightGreen.shade400,
      Colors.green.shade900,
      (tree.stage / 4).clamp(0.0, 1.0),
    );

    final size = baseSize + (tree.stage * 15);

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

        // ★ 追加：木の名前を表示
        Text(
          tree.name,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // 長すぎる名前は「...」にする
        ),

        const SizedBox(height: 4),

        // 次のレベルへの経験値バー
        if (isProgressIndicator)
          SizedBox(
            width: 80,
            child: LinearProgressIndicator(
              value: (tree.totalChars % 100) / 100,
              backgroundColor: Colors.grey.shade200,
              color: treeColor,
              minHeight: 4,
            ),
          ),
      ],
    );
  }
}
