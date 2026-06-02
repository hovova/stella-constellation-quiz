import 'package:flutter/material.dart';

import '../models/player_progress.dart';

class SoundToggleButton extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const SoundToggleButton({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  void toggleSound() {
    final newValue = !progress.soundEnabled;

    final updatedProgress = progress.copyWith(
      soundEnabled: newValue,
      musicEnabled: newValue,
    );

    onProgressUpdated(updatedProgress);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = progress.soundEnabled && progress.musicEnabled;

    return InkWell(
      onTap: toggleSound,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
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
          size: 20,
        ),
      ),
    );
  }
}