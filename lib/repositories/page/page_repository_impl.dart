import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../../models/page.dart';
import 'page_repository.dart';

part 'page_repository_impl.g.dart';

class PageRepositoryImpl implements PageRepository {
  final _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<Page>> fetchPagesByTreeId(int treeId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pages',
      where: 'tree_id = ?',
      whereArgs: [treeId],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => Page.fromMap(m)).toList();
  }

  @override
  Future<int> createPage(int treeId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    return await db.insert('pages', {
      'tree_id': treeId,
      'title': '',
      'content': '',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  @override
  Future<void> updatePage(Page page) async {
    final db = await _dbHelper.database;
    await db.update(
      'pages',
      page.toMap(),
      where: 'id = ?',
      whereArgs: [page.id],
    );
  }

  @override
  Future<void> deletePage(int id) async {
    final db = await _dbHelper.database;
    await db.delete('pages', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> saveAndGrow({
    required Page page,
    required int deltaChars,
  }) async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    await db.transaction((txn) async {
      // 1. ページ内容を更新
      if (page.id != null) {
        await txn.update(
          'pages',
          page.copyWith().toMap(),
          where: 'id = ?',
          whereArgs: [page.id],
        );
      } else {
        await txn.insert('pages', {
          'tree_id': page.treeId,
          'title': page.title,
          'content': page.content,
        });
      }

      // 2. 今日の成長ログを処理
      if (deltaChars > 0) {
        // 今日のログが既に存在するか確認
        final List<Map<String, dynamic>> existingLogs = await txn.query(
          'growth_logs',
          where: 'tree_id = ? AND log_date = ?',
          whereArgs: [page.treeId, today],
        );

        if (existingLogs.isEmpty) {
          // 今日初めての保存なら新規作成
          await txn.insert('growth_logs', {
            'tree_id': page.treeId,
            'delta_chars': deltaChars,
            'log_date': today,
          });
        } else {
          // 既にログがあれば、現在の値に今回の増分を加算
          final currentDelta = existingLogs.first['delta_chars'] as int;
          await txn.update(
            'growth_logs',
            {'delta_chars': currentDelta + deltaChars},
            where: 'id = ?',
            whereArgs: [existingLogs.first['id']],
          );
        }
      }
    });
  }
}

@riverpod
PageRepository pageRepository(Ref ref) => PageRepositoryImpl();
