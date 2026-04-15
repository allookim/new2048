import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _kBgm = 'settings_bgm';
  static const _kSfx = 'settings_sfx';
  static const _kVibration = 'settings_vibration';

  bool _bgm = true;
  bool _sfx = true;
  bool _vibration = true;

  bool get bgm => _bgm;
  bool get sfx => _sfx;
  bool get vibration => _vibration;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _bgm = p.getBool(_kBgm) ?? true;
    _sfx = p.getBool(_kSfx) ?? true;
    _vibration = p.getBool(_kVibration) ?? true;
    notifyListeners();
  }

  Future<void> setBgm(bool v) async {
    _bgm = v;
    (await SharedPreferences.getInstance()).setBool(_kBgm, v);
    notifyListeners();
  }

  Future<void> setSfx(bool v) async {
    _sfx = v;
    (await SharedPreferences.getInstance()).setBool(_kSfx, v);
    notifyListeners();
  }

  Future<void> setVibration(bool v) async {
    _vibration = v;
    (await SharedPreferences.getInstance()).setBool(_kVibration, v);
    notifyListeners();
  }
}
