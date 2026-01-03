import 'package:sqflite/sqflite.dart' as sqflite;

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}

class DiskFullException implements Exception {
  final String message;
  DiskFullException(this.message);
  @override
  String toString() => message;
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  @override
  String toString() => message;
}

class ExceptionHandler {
  /// エラーを解析して適切な例外を throw する
  static Never handle(dynamic e, [String? customMessage]) {
    // 既に定義済みの独自例外ならそのまま投げる
    if (e is ValidationException ||
        e is DiskFullException ||
        e is DatabaseException) {
      throw e;
    }

    final errorStr = e.toString();

    // SQLiteの容量不足エラー判定
    if (errorStr.contains('code 13') || errorStr.contains('SQLITE_FULL')) {
      throw DiskFullException('端末の空き容量が不足しています。');
    }

    // その他のDBエラー
    if (e is sqflite.DatabaseException) {
      throw DatabaseException(customMessage ?? 'データベースエラーが発生しました。');
    }

    // 想定外のエラー
    throw DatabaseException(customMessage ?? '予期せぬエラーが発生しました。');
  }
}
