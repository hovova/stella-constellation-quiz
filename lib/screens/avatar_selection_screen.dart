import 'package:flutter/material.dart';

import '../data/avatars.dart';
import '../models/player_progress.dart';
import 'home_screen.dart';

class AvatarSelectionScreen extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const AvatarSelectionScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  void selectAvatar(BuildContext context, String avatarId) {
    final updatedProgress = progress.copyWith(
      selectedAvatarId: avatarId,
    );

    onProgressUpdated(updatedProgress);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose Avatar',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD98A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your Stella profile avatar.',
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: avatarOptions.map((avatar) {
                  final selected = avatar.id == progress.selectedAvatarId;

                  return InkWell(
                    onTap: () => selectAvatar(context, avatar.id),
                    borderRadius: BorderRadius.circular(22),
                    child: Card(
                      color: selected
                          ? const Color(0xFF132B46)
                          : const Color(0xFF10243B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(
                          color: selected
                              ? const Color(0xFFFFD98A)
                              : const Color(0x223A5B80),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            avatar.fallbackIcon,
                            color: const Color(0xFFFFD98A),
                            size: 46,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            avatar.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(height: 8),
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFFFFD98A),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}