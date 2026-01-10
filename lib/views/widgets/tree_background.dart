import 'package:flutter/material.dart';
import 'package:kino_ne/models/tree.dart';

class TreeBackground extends StatelessWidget {
  final Tree tree;
  final Widget? child; // 背景の上に重ねるコンテンツ
  final double opacity; // コンテンツを読みやすくするためのフィルターの濃さ

  const TreeBackground({
    super.key,
    required this.tree,
    this.child,
    this.opacity = 0.2, // デフォルトは20%の白オーバーレイ
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackgroundImage(),
        Container(color: Colors.white.withOpacity(opacity)),
        if (child != null) child!,
      ],
    );
  }

  Widget _buildBackgroundImage() {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 2),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Image.asset(
        tree.bgImage,
        key: ValueKey(tree.bgImage),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
