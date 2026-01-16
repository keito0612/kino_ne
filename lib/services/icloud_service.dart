import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:kino_ne/core/database/database_helper.dart';
import 'package:path/path.dart';

class ICloudService {
  final String containerId = dotenv.get('ICLOUD_CONTAINER_ID');
  final String backupFileName = 'kino_note.db';

  /// iCloudへDBファイルをアップロード
  Future<void> backupToICloud() async {
    final localFilePath = await DatabaseHelper.instance.dbPath();
    try {
      await ICloudStorage.upload(
        containerId: containerId,
        filePath: localFilePath,
        destinationRelativePath: backupFileName,
        onProgress: (stream) {
          stream.listen((progress) => print('アップロード中: $progress%'));
        },
      );
    } catch (e) {
      throw Exception('iCloudアップロード失敗: $e');
    }
  }

  /// iCloudからDBファイルをダウンロードして復元
  Future<void> restoreFromICloud() async {
    final destinationPath = await DatabaseHelper.instance.dbPath();
    // 一時的なダウンロード先を作成
    final tempPath = join(dirname(destinationPath), 'temp_backup.db');

    try {
      // 1. iCloudから一時ファイルとしてダウンロード
      await ICloudStorage.download(
        containerId: containerId,
        relativePath: backupFileName,
        destinationFilePath: tempPath,
        onProgress: (stream) {
          stream.listen((progress) => print('ダウンロード中: $progress%'));
        },
      );
      await DatabaseHelper.instance.closeDatabase();

      await DatabaseHelper.instance.deleteExtraFiles();

      final tempFile = File(tempPath);
      if (await tempFile.exists()) {
        await tempFile.copy(destinationPath);
        // 5. 使い終わった一時ファイルを削除
        await tempFile.delete();
      }
    } catch (e) {
      throw Exception('iCloud復元失敗: $e');
    }
  }

  Future<bool> isICloudAvailable() async {
    try {
      await ICloudStorage.gather(containerId: containerId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ICloudFile>> getBackupFiles() async {
    // 指定したコンテナ内のファイル一覧を取得
    final files = await ICloudStorage.gather(containerId: containerId);
    return files;
  }
}
