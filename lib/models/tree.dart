import 'package:flutter/material.dart';

import 'growth_log.dart';

class Tree {
  final int? id;
  final String name;
  final String type;
  final int growthLevel;
  final DateTime createdAt;
  // 1対多のリレーション用リスト
  final List<GrowthLog> growthLogs;

  Tree({
    this.id,
    required this.name,
    required this.type,
    this.growthLevel = 1,
    required this.createdAt,
    this.growthLogs = const [],
  });

  // 便利ゲッター：リストの中から今日の日付のログだけを返す
  GrowthLog? get todayLog {
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      return growthLogs.firstWhere((log) => log.logDate == today);
    } catch (_) {
      return null;
    }
  }

  factory Tree.fromMap(Map<String, dynamic> map, {List<GrowthLog>? logs}) {
    return Tree(
      id: map['tree_id'],
      name: map['name'],
      type: map['type'],
      growthLevel: map['growth_level'] ?? 1,
      createdAt: DateTime.parse(map['created_at']),
      growthLogs: logs ?? const [],
    );
  }

  Tree copyWith({int? growthLevel, List<GrowthLog>? growthLogs}) {
    return Tree(
      id: id,
      name: name,
      type: type,
      growthLevel: growthLevel ?? this.growthLevel,
      createdAt: createdAt,
      growthLogs: growthLogs ?? this.growthLogs,
    );
  }
}

extension TreeGrowth on Tree {
  // レベル計算（例：100文字ごとに1レベルアップ）
  int get totalChars => growthLogs.fold(0, (sum, log) => sum + log.deltaChars);
  int get level => (totalChars / 100).floor() + 1;

  // 成長段階（0:種, 1:芽, 2:若木, 3:成木, 4:巨木）
  int get stage => switch (level) {
    >= 20 => 4,
    >= 10 => 3,
    >= 5 => 2,
    >= 2 => 1,
    _ => 0,
  };

  // ステージに応じたアイコン
  IconData get icon {
    switch (stage) {
      case 0:
        return Icons.eco_outlined; // 種・芽
      case 1:
        return Icons.grass; // 若葉
      case 2:
        return Icons.park_outlined; // 若木
      case 3:
        return Icons.park; // 成木
      default:
        return Icons.forest; // 巨木
    }
  }
}
