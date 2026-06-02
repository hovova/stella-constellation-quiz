import 'package:flutter/material.dart';

import '../data/avatars.dart';
import '../models/player_progress.dart';
import 'achievements_screen.dart';
import 'avatar_selection_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const ProfileScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  int get playerLevel {
    return (progress.totalXp ~/ 1000) + 1;
  }

  bool isValidName(String name) {
    final cleanedName = name.trim().toLowerCase();

    if (cleanedName.length < 3 || cleanedName.length > 16) {
      return false;
    }

    final validCharacters = RegExp(r'^[a-zA-Z0-9А-Яа-яІіЇїЄєҐґЁё\s]+$');

    if (!validCharacters.hasMatch(cleanedName)) {
      return false;
    }

    const blockedWords = [
      'fuck',
      'shit',
      'bitch',
      'nazi',
      'hitler',
      'хуй',
      'сука',
      'блять',
      'пизда',
    ];

    return !blockedWords.any(cleanedName.contains);
  }

  void openEditNameDialog(BuildContext context) {
    final controller = TextEditingController(text: progress.playerName);

    showDialog(
      context: context,
      builder: (_) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF10243B),
              title: const Text(
                'Edit Name',
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: controller,
                maxLength: 16,
                decoration: InputDecoration(
                  hintText: 'Enter player name',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final newName = controller.text.trim();

                    if (!isValidName(newName)) {
                      setDialogState(() {
                        errorText =
                            'Use 3–16 clean letters/numbers only.';
                      });
                      return;
                    }

                    final updatedProgress = progress.copyWith(
                      playerName: newName,
                    );

                    onProgressUpdated(updatedProgress);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void openAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(progress: progress),
      ),
    );
  }

  void openAvatarSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvatarSelectionScreen(
          progress: progress,
          onProgressUpdated: onProgressUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = findAvatarById(progress.selectedAvatarId);

    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your progress, achievements and premium status.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            Card(
              color: const Color(0xFF10243B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0x223A5B80)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF071426),
                      child: Icon(
                        avatar.fallbackIcon,
                        color: const Color(0xFFFFD98A),
                        size: 38,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            progress.playerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            avatar.name,
                            style: const TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => openEditNameDialog(context),
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openAvatarSelection(context),
                    icon: const Icon(Icons.face),
                    label: const Text('Avatar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => openAchievements(context),
                    icon: const Icon(Icons.emoji_events),
                    label: const Text('Achievements'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _ProfileStatCard(
              title: 'Level',
              value: '$playerLevel',
              icon: Icons.trending_up,
            ),
            _ProfileStatCard(
              title: 'Total XP',
              value: '${progress.totalXp}',
              icon: Icons.bolt,
            ),
            _ProfileStatCard(
              title: 'Gold Awards',
              value: '${progress.goldAwardCount(5)}',
              icon: Icons.workspace_premium,
            ),
            _ProfileStatCard(
              title: 'Achievements',
              value:
                  '${progress.unlockedAchievements.length} / ${allAchievementsCount}',
              icon: Icons.emoji_events,
            ),
            _ProfileStatCard(
              title: 'No Ads',
              value: progress.hasNoAds || progress.hasPremium
                  ? 'Active'
                  : 'Inactive',
              icon: Icons.block,
            ),
            _ProfileStatCard(
              title: 'Premium',
              value: progress.hasPremium ? 'Active' : 'Inactive',
              icon: Icons.workspace_premium,
            ),
          ],
        ),
      ),
    );
  }
}

const int allAchievementsCount = 4;

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF10243B),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x223A5B80)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFFD98A),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}