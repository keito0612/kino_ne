import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _keyPasscodeEnabled = 'passcode_enabled';
  static const String _keyAppPasscode = 'app_passcode';
  static const String _keyUseBiometrics = 'use_biometrics'; // 生体認証用（将来用）

  bool isPasscodeEnabled() {
    return _prefs.getBool(_keyPasscodeEnabled) ?? false;
  }

  String? getPasscode() {
    return _prefs.getString(_keyAppPasscode);
  }

  Future<void> setPasscode(String code) async {
    await _prefs.setBool(_keyPasscodeEnabled, true);
    await _prefs.setString(_keyAppPasscode, code);
  }

  Future<void> disablePasscode() async {
    await _prefs.setBool(_keyPasscodeEnabled, false);
    await _prefs.remove(_keyAppPasscode);
    await _prefs.setBool(_keyUseBiometrics, false);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _prefs.setBool(_keyUseBiometrics, enabled);
  }

  bool isBiometricsEnabled() {
    return _prefs.getBool(_keyUseBiometrics) ?? false;
  }
}
