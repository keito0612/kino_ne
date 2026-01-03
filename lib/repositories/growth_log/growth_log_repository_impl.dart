import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/core/database/database_helper.dart';
import 'package:kino_ne/models/growth_log.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'growth_log_repository.dart';

part 'growth_log_repository_impl.g.dart';

@riverpod
GrowthLogRepository growthLogRepository(Ref ref) {
  return GrowthLogRepositoryImpl(DatabaseHelper.instance);
}

class GrowthLogRepositoryImpl implements GrowthLogRepository {
  final DatabaseHelper _dbHelper;

  GrowthLogRepositoryImpl(this._dbHelper);

  @override
  Future<List<GrowthLog>> fetchAllLogs(int treeId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT 
      MAX(id) as id, 
      tree_id, 
      SUM(delta_chars) as delta_chars, 
      date(created_at) as log_date 
    FROM growth_logs 
    WHERE tree_id = ?
    GROUP BY log_date
    ORDER BY log_date DESC
  ''',
      [treeId],
    );
    return maps.map((m) => GrowthLog.fromMap(m)).toList();
  }

  @override
  Future<List<GrowthLog>> fetchLogsByTreeId(
    int treeId, {
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await _dbHelper.database;

    // 期間指定がある場合は WHERE 句を構築
    String whereClause = 'tree_id = ?';
    List<dynamic> whereArgs = [treeId];

    if (start != null && end != null) {
      whereClause += ' AND created_at BETWEEN ? AND ?';
      whereArgs.addAll([start.toIso8601String(), end.toIso8601String()]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'growth_logs',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => GrowthLog.fromMap(m)).toList();
  }

  @override
  Future<int> getTodayTotalGrowth() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT SUM(delta_chars) as total 
      FROM growth_logs 
      WHERE created_at >= ?
    ''',
      [todayStart],
    );

    return result.first['total'] as int? ?? 0;
  }
}
