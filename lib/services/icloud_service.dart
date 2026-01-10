import 'dart:io';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ICloudService {
  // ※Apple Developer Portalで作成したコンテナIDをここにセット
  final String containerId = 'iCloud.com.yourdomain.kino-ne';
  final String backupFileName = 'kino_ne_backup.db';

  /// iCloudへDBファイルをアップロード
  Future<void> backupToICloud() async {
    final dbPath = await getDatabasesPath();
    final localFilePath = join(dbPath, 'kino_ne.db');

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
    final dbPath = await getDatabasesPath();
    final destinationPath = join(dbPath, 'kino_ne.db');

    try {
      await ICloudStorage.download(
        containerId: containerId,
        relativePath: backupFileName,
        destinationFilePath: destinationPath,
        onProgress: (stream) {
          stream.listen((progress) => print('ダウンロード中: $progress%'));
        },
      );
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
}
