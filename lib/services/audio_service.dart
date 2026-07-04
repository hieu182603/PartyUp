import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = prefs.getBool('is_sound_enabled') ?? true;
    _isMusicEnabled = prefs.getBool('is_music_enabled') ?? true;

    // Configure BGM Player to loop
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    
    // Set initial volumes based on preferences (BGM at 35% to be pleasant background music)
    await _bgmPlayer.setVolume(_isMusicEnabled ? 0.35 : 0.0);
    await _sfxPlayer.setVolume(_isSoundEnabled ? 1.0 : 0.0);
  }

  Future<void> playBGM() async {
    try {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  Future<void> playSFX(String filename) async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$filename'));
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_sound_enabled', enabled);
    await _sfxPlayer.setVolume(enabled ? 1.0 : 0.0);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_music_enabled', enabled);
    await _bgmPlayer.setVolume(enabled ? 0.35 : 0.0);
    
    if (enabled) {
      await playBGM();
    } else {
      await stopBGM();
    }
  }
}
