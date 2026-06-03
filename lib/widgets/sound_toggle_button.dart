import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';

class SoundToggleButton extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const SoundToggleButton({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  String text(String key) {
    return AppText.get(progress.selectedLanguageCode, key);
  }

  void openAudioPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AudioControlSheet(
        progress: progress,
        onProgressUpdated: onProgressUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = progress.musicEnabled || progress.soundEnabled;

    return InkWell(
      onTap: () async {
        await StellaAudioService.startMusicAfterUserGesture();
        await StellaAudioService.playButtonTap();

        if (!context.mounted) return;
        openAudioPanel(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF10243B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x223A5B80),
          ),
        ),
        child: Icon(
          enabled ? Icons.volume_up : Icons.volume_off,
          color: const Color(0xFFFFD98A),
          size: 22,
        ),
      ),
    );
  }
}

class _AudioControlSheet extends StatefulWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const _AudioControlSheet({
    required this.progress,
    required this.onProgressUpdated,
  });

  @override
  State<_AudioControlSheet> createState() => _AudioControlSheetState();
}

class _AudioControlSheetState extends State<_AudioControlSheet> {
  late PlayerProgress visibleProgress;
  late double musicVolume;
  late double sfxVolume;

  @override
  void initState() {
    super.initState();

    visibleProgress = widget.progress;
    musicVolume = StellaAudioService.musicVolume;
    sfxVolume = StellaAudioService.sfxVolume;
  }

  String text(String key) {
    return AppText.get(visibleProgress.selectedLanguageCode, key);
  }

  String safeText(String key, String fallback) {
    final value = text(key);
    return value == key ? fallback : value;
  }

  void updateVisibleProgress(PlayerProgress updatedProgress) {
    setState(() {
      visibleProgress = updatedProgress;
    });

    widget.onProgressUpdated(updatedProgress);
  }

  Future<void> updateMusicEnabled(bool value) async {
    final updatedProgress = visibleProgress.copyWith(
      musicEnabled: value,
    );

    updateVisibleProgress(updatedProgress);

    await StellaAudioService.updateMusicState(
      musicEnabled: value,
    );

    if (value) {
      await StellaAudioService.startMusicAfterUserGesture();
    }
  }

  Future<void> updateSoundEnabled(bool value) async {
    final updatedProgress = visibleProgress.copyWith(
      soundEnabled: value,
    );

    updateVisibleProgress(updatedProgress);

    await StellaAudioService.updateSoundState(
      soundEnabled: value,
    );

    if (value) {
      await StellaAudioService.playButtonTap();
    }
  }

  Future<void> updateMusicVolume(double value) async {
    setState(() {
      musicVolume = value;
    });

    await StellaAudioService.setMusicVolume(value);
  }

  Future<void> updateSfxVolume(double value) async {
    setState(() {
      sfxVolume = value;
    });

    await StellaAudioService.setSfxVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF071426),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.volume_up,
                    color: Color(0xFFFFD98A),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      safeText('audioSettings', 'Audio Settings'),
                      style: const TextStyle(
                        color: Color(0xFFFFD98A),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _AudioSwitchRow(
                icon: Icons.music_note,
                title: safeText('music', 'Music'),
                value: visibleProgress.musicEnabled,
                onChanged: updateMusicEnabled,
              ),

              const SizedBox(height: 12),

              _AudioSwitchRow(
                icon: Icons.graphic_eq,
                title: safeText('soundEffects', 'Sound Effects'),
                value: visibleProgress.soundEnabled,
                onChanged: updateSoundEnabled,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _VerticalVolumeControl(
                      title: safeText('musicVolume', 'Music'),
                      icon: Icons.music_note,
                      value: musicVolume,
                      enabled: visibleProgress.musicEnabled,
                      onChanged: updateMusicVolume,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _VerticalVolumeControl(
                      title: safeText('sfxVolume', 'SFX'),
                      icon: Icons.graphic_eq,
                      value: sfxVolume,
                      enabled: visibleProgress.soundEnabled,
                      onChanged: updateSfxVolume,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioSwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final Future<void> Function(bool value) onChanged;

  const _AudioSwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10243B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x223A5B80),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD98A),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: const Color(0xFFFFD98A),
            onChanged: (newValue) {
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}

class _VerticalVolumeControl extends StatelessWidget {
  final String title;
  final IconData icon;
  final double value;
  final bool enabled;
  final Future<void> Function(double value) onChanged;

  const _VerticalVolumeControl({
    required this.title,
    required this.icon,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Container(
      height: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10243B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0x223A5B80),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: enabled ? const Color(0xFFFFD98A) : Colors.white30,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percent%',
            style: TextStyle(
              color: enabled ? Colors.white54 : Colors.white24,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: Slider(
                value: value,
                min: 0,
                max: 1,
                activeColor: const Color(0xFFFFD98A),
                inactiveColor: const Color(0xFF071426),
                onChanged: enabled
                    ? (newValue) {
                        onChanged(newValue);
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}