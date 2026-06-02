import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../models/player_progress.dart';
import 'home_screen.dart';

class AchievementsScreen extends StatelessWidget {
  final PlayerProgress progress;

  const AchievementsScreen({
    super.key,
    required this.progress,
  });

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
                'Achievements',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD98A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.unlockedAchievements.length} / ${allAchievements.length} unlocked',
                style: const TextStyle(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 24),
              ...allAchievements.map((achievement) {
                final unlocked = progress.hasAchievement(achievement.id);

                return Card(
                  color: unlocked
                      ? const Color(0xFF10243B)
                      : const Color(0xFF081525),
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: unlocked
                          ? const Color(0x44FFD98A)
                          : const Color(0x223A5B80),
                    ),
                  ),
                  child: ListTile(
                    leading: Text(
                      achievement.emoji,
                      style: TextStyle(
                        fontSize: 30,
                        color: unlocked ? Colors.white : Colors.white30,
                      ),
                    ),
                    title: Text(
                      achievement.title,
                      style: TextStyle(
                        color: unlocked ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      achievement.description,
                      style: TextStyle(
                        color: unlocked ? Colors.white60 : Colors.white30,
                      ),
                    ),
                    trailing: Icon(
                      unlocked ? Icons.check_circle : Icons.lock_outline,
                      color: unlocked
                          ? const Color(0xFFFFD98A)
                          : Colors.white30,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}