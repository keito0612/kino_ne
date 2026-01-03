import 'package:flutter/material.dart';

class DynamicForestBackground extends StatelessWidget {
  final int treeCount;
  final Widget? child; // 背景の上に重ねるコンテンツ
  final double opacity; // コンテンツを読みやすくするためのフィルターの濃さ

  const DynamicForestBackground({
    super.key,
    required this.treeCount,
    this.child,
    this.opacity = 0.2, // デフォルトは20%の白オーバーレイ
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. 動的な画像レイヤー
        _buildBackgroundImage(),

        // 2. オーバーレイレイヤー（文字の可読性確保）
        Container(color: Colors.white.withOpacity(opacity)),

        // 3. コンテンツレイヤー
        if (child != null) child!,
      ],
    );
  }

  Widget _buildBackgroundImage() {
    String imagePath;

    // 木の数に応じたステージ判定
    if (treeCount == 0) {
      imagePath = 'assets/images/image1.png'; // 更地
    } else if (treeCount < 8) {
      imagePath = 'assets/images/image2.png'; // 平原
    } else {
      imagePath = 'assets/images/image3.png'; // 森林
    }

    return AnimatedSwitcher(
      duration: const Duration(seconds: 2),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Image.asset(
        imagePath,
        key: ValueKey(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
