import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:kino_ne/core/database/database_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ICloudService {
  // ※Apple Developer Portalで作成したコンテナIDをここにセット
  final String containerId = dotenv.get('ICLOUD_CONTAINER_ID');
  final String backupFileName = 'kino_ne_backup.db';

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
      print(e);
      return false;
    }
  }
}
