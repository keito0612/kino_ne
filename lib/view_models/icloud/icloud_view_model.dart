import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../services/icloud_service.dart';

final icloudServiceProvider = Provider((ref) => ICloudService());

final icloudViewModelProvider =
    StateNotifierProvider<ICloudViewModel, AsyncValue<void>>((ref) {
      final service = ref.watch(icloudServiceProvider);
      return ICloudViewModel(service);
    });

class ICloudViewModel extends StateNotifier<AsyncValue<void>> {
  final ICloudService _service;
  static const String _lastBackupKey = 'last_backup_datetime';
  static const String _autoBackupKey = 'auto_backup_enabled';

  ICloudViewModel(this._service) : super(const AsyncValue.data(null));

  Future<String> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBackupKey) ?? '未実施';
  }

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupKey) ?? false;
  }

  Future<void> toggleAutoBackup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupKey, enabled);
  }

  Future<void> backup() async {
    state = const AsyncValue.loading();
    try {
      await _service.backupToICloud();
      await _saveCurrentTimestamp();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> restore() async {
    state = const AsyncValue.loading();
    try {
      await _service.restoreFromICloud();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 起動時などの自動バックアップ（サイレント実行）
  Future<void> runAutoBackupIfEnabled() async {
    if (await isAutoBackupEnabled()) {
      try {
        await _service.backupToICloud();
        await _saveCurrentTimestamp();
      } catch (e) {
        print("自動バックアップサイレント失敗: $e");
      }
    }
  }

  Future<bool> checkConnection() async {
    final isAvailable = await _service.isICloudAvailable();
    return isAvailable;
  }

  Future<void> _saveCurrentTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now());
    await prefs.setString(_lastBackupKey, now);
  }
}
