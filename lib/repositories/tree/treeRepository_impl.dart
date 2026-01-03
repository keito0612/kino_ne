import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/models/growth_log.dart';
import 'package:kino_ne/repositories/tree/tree_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/database_helper.dart';
import '../../models/tree.dart';
part 'treeRepository_impl.g.dart';

class TreeRepositoryImpl implements TreeRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Tree>> fetchAllTrees() async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT DISTINCT
      t.id as tree_id, t.name, t.type, t.growth_level, t.created_at,
      g.id as log_id, g.delta_chars, g.log_date
    FROM trees t
    LEFT JOIN growth_logs g ON t.id = g.tree_id
    ORDER BY t.created_at DESC
  ''');
    final groupedMaps = groupBy(maps, (Map row) => row['tree_id'] as int);
    final treeList = groupedMaps.values.map((rows) {
      final firstRow = rows.first;
      final logs = rows
          .where((row) => row['log_id'] != null)
          .map(
            (row) => GrowthLog(
              id: row['log_id'],
              treeId: row['tree_id'],
              deltaChars: row['delta_chars'],
              logDate: row['log_date'],
            ),
          )
          .toList();
      return Tree.fromMap(firstRow, logs: logs);
    }).toList();
    return treeList;
  }

  @override
  Future<int> plantTree(Tree tree) async {
    final db = await _dbHelper.database;
    // モデルをMapに変換して保存（IDは自動採番されるので渡さない）
    return await db.insert('trees', {
      'name': tree.name,
      'type': tree.type,
      'growth_level': tree.growthLevel,
      'created_at': tree.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> updateTreeLevel(int treeId, int newLevel) async {
    final db = await _dbHelper.database;
    await db.update(
      'trees',
      {'growth_level': newLevel},
      where: 'id = ?',
      whereArgs: [treeId],
    );
  }

  @override
  Future<void> deleteTree(int treeId) async {
    final db = await _dbHelper.database;
    await db.delete('trees', where: 'id = ?', whereArgs: [treeId]);
  }
}

@riverpod
TreeRepository treeRepository(Ref ref) => TreeRepositoryImpl();
