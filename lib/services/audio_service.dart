import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'settings_service.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _bgm = AudioPlayer();
  final AudioPlayer _sfxMove = AudioPlayer();
  final AudioPlayer _sfxCombo = AudioPlayer();

  bool _bgmStarted = false;

  Future<void> init() async {
    try {
      await _bgm.setReleaseMode(ReleaseMode.loop);
      await _bgm.setVolume(0.4);
      await _sfxMove.setReleaseMode(ReleaseMode.stop);
      await _sfxMove.setVolume(0.8);
      await _sfxCombo.setReleaseMode(ReleaseMode.stop);
      await _sfxCombo.setVolume(0.9);
      await _sfxMove.setSource(AssetSource('sounds/EFX_holder-2.mp3'));
      await _sfxCombo.setSource(AssetSource('sounds/EFX_holder-1.mp3'));
    } catch (e) {
      debugPrint('AudioService init failed: $e');
    }
  }

  Future<void> startBgm() async {
    if (!SettingsService.instance.bgm) return;
    if (_bgmStarted) return;
    _bgmStarted = true;
    try {
      await _bgm.play(AssetSource('sounds/BGM_endless-1.mp3'));
    } catch (e) {
      debugPrint('BGM play failed: $e');
      _bgmStarted = false;
    }
  }

  Future<void> stopBgm() async {
    _bgmStarted = false;
    await _bgm.stop();
  }

  void playMove() {
    if (!SettingsService.instance.sfx) return;
    _sfxMove.seek(Duration.zero);
    _sfxMove.resume();
  }

  void playCombo() {
    if (!SettingsService.instance.sfx) return;
    _sfxCombo.seek(Duration.zero);
    _sfxCombo.resume();
  }
}
