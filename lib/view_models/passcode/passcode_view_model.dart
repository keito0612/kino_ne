// view_models/passcode/passcode_view_model.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/services/local_storage_service.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError();
});

final passcodeViewModelProvider =
    StateNotifierProvider<PasscodeViewModel, bool>((ref) {
      return PasscodeViewModel(ref.read(localStorageServiceProvider));
    });

class PasscodeViewModel extends StateNotifier<bool> {
  final LocalStorageService _storage;

  PasscodeViewModel(this._storage) : super(_storage.isPasscodeEnabled());

  /// ストレージの最新状態を state（UIに通知する値）に反映させる
  void updateStatus() {
    state = _storage.isPasscodeEnabled();
  }

  // 他の便利なメソッドも追加しておくと後で楽になります
  String? get currentPasscode => _storage.getPasscode();
}
