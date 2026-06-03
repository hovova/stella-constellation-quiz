import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class StellaAudioService {
  static final AudioPlayer _musicPlayer = AudioPlayer();

  static bool _musicInitialised = false;
  static bool _musicEnabled = true;
  static bool _soundEnabled = true;
  static bool _appInBackground = false;

  static double _musicVolume = 0.18;
  static double _sfxVolume = 0.9;

  static const String _backgroundMusicPath = 'audio/background_music.mp3';

  static bool get musicEnabled => _musicEnabled;
  static bool get soundEnabled => _soundEnabled;
  static double get musicVolume => _musicVolume;
  static double get sfxVolume => _sfxVolume;

  static Source audioSource(String assetPath) {
    if (kIsWeb) {
      return UrlSource('assets/assets/$assetPath');
    }

    return AssetSource(assetPath);
  }

  static Future<void> initialiseMusic() async {
    if (_musicInitialised) {
      return;
    }

    _musicInitialised = true;

    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
    } catch (error) {
      debugPrint('MUSIC INIT ERROR: $error');
    }
  }

  static Future<void> startMusic() async {
    if (!_musicEnabled || _appInBackground) {
      return;
    }

    try {
      await initialiseMusic();

      final state = _musicPlayer.state;

      if (state == PlayerState.playing) {
        await _musicPlayer.setVolume(_musicVolume);
        return;
      }

      if (state == PlayerState.paused) {
        await _musicPlayer.setVolume(_musicVolume);
        await _musicPlayer.resume();
        return;
      }

      await _musicPlayer.play(
        audioSource(_backgroundMusicPath),
        volume: _musicVolume,
      );
    } catch (error) {
      debugPrint('MUSIC START ERROR: $error');
    }
  }

  static Future<void> startMusicAfterUserGesture() async {
    await startMusic();
  }

  static Future<void> pauseMusicForGame() async {
    try {
      await _musicPlayer.pause();
    } catch (error) {
      debugPrint('MUSIC PAUSE ERROR: $error');
    }
  }

  static Future<void> resumeMusicForMenu() async {
    if (_appInBackground) {
      return;
    }

    await startMusic();
  }

  static Future<void> updateMusicState({
    required bool musicEnabled,
  }) async {
    _musicEnabled = musicEnabled;

    if (_musicEnabled) {
      await startMusic();
    } else {
      try {
        await _musicPlayer.pause();
      } catch (error) {
        debugPrint('MUSIC OFF ERROR: $error');
      }
    }
  }

  static Future<void> updateSoundState({
    required bool soundEnabled,
  }) async {
    _soundEnabled = soundEnabled;
  }

  static Future<void> configureFromProgress({
    required bool musicEnabled,
    required bool soundEnabled,
  }) async {
    _musicEnabled = musicEnabled;
    _soundEnabled = soundEnabled;

    await initialiseMusic();
  }

  static Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);

    try {
      await _musicPlayer.setVolume(_musicVolume);
    } catch (error) {
      debugPrint('MUSIC VOLUME ERROR: $error');
    }
  }

  static Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  static Future<void> playButtonTap() async {
    playSfx(
      assetPath: 'audio/button_tap.mp3',
      volumeMultiplier: 0.9,
      disposeAfter: const Duration(seconds: 2),
    );
  }

  static Future<void> playCorrectAnswer() async {
    playSfx(
      assetPath: 'audio/correct.mp3',
      volumeMultiplier: 1.0,
      disposeAfter: const Duration(seconds: 3),
    );
  }

  static Future<void> playWrongAnswer() async {
    playSfx(
      assetPath: 'audio/wrong.mp3',
      volumeMultiplier: 1.0,
      disposeAfter: const Duration(seconds: 3),
    );
  }

  static Future<void> playAchievementUnlock() async {
    playImportantSfx('audio/achievement.mp3');
  }

  static Future<void> playLevelComplete() async {
    playImportantSfx('audio/achievement.mp3');
  }

  static Future<void> playGoldAward() async {
    playImportantSfx('audio/achievement.mp3');
  }

  static void playSfx({
    required String assetPath,
    double volumeMultiplier = 1.0,
    Duration disposeAfter = const Duration(seconds: 3),
  }) {
    if (!_soundEnabled || _appInBackground) {
      return;
    }

    final player = AudioPlayer();

    unawaited(
      () async {
        try {
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setVolume(
            (_sfxVolume * volumeMultiplier).clamp(0.0, 1.0),
          );

          await player
              .play(
                audioSource(assetPath),
              )
              .timeout(const Duration(seconds: 3));

          Future.delayed(disposeAfter, () async {
            try {
              await player.dispose();
            } catch (_) {}
          });
        } catch (error) {
          debugPrint('SFX ERROR for $assetPath: $error');

          try {
            await player.dispose();
          } catch (_) {}
        }
      }(),
    );
  }

  static void playImportantSfx(String assetPath) {
    if (!_soundEnabled || _appInBackground) {
      return;
    }

    final player = AudioPlayer();
    final musicWasPlaying =
        _musicEnabled && _musicPlayer.state == PlayerState.playing;

    unawaited(
      () async {
        try {
          if (musicWasPlaying) {
            await _musicPlayer.setVolume(0.02);
          }

          await player.setReleaseMode(ReleaseMode.stop);
          await player.setVolume(_sfxVolume);

          await player
              .play(
                audioSource(assetPath),
              )
              .timeout(const Duration(seconds: 3));

          Future.delayed(const Duration(seconds: 4), () async {
            try {
              await player.dispose();
            } catch (_) {}

            if (musicWasPlaying && _musicEnabled && !_appInBackground) {
              await _musicPlayer.setVolume(_musicVolume);
            }
          });
        } catch (error) {
          debugPrint('IMPORTANT SFX ERROR for $assetPath: $error');

          try {
            await player.dispose();
          } catch (_) {}

          if (musicWasPlaying && _musicEnabled && !_appInBackground) {
            await _musicPlayer.setVolume(_musicVolume);
          }
        }
      }(),
    );
  }

  static Future<void> stopAllSfx() async {
    // Temporary SFX players dispose themselves.
    return;
  }

  static Future<void> pauseAllAudioForAppBackground() async {
    _appInBackground = true;

    try {
      await _musicPlayer.pause();
    } catch (error) {
      debugPrint('APP BACKGROUND AUDIO PAUSE ERROR: $error');
    }
  }

  static Future<void> resumeAudioAfterAppForeground() async {
    _appInBackground = false;

    if (_musicEnabled) {
      await resumeMusicForMenu();
    }
  }
}