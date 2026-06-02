import 'package:flutter/material.dart';

import '../models/player_progress.dart';
import 'home_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  final PlayerProgress progress;

  const LeaderboardScreen({
    super.key,
    required this.progress,
  });

  int get playerLevel {
    return (progress.totalXp ~/ 1000) + 1;
  }

  int get leaderboardScore {
    return playerLevel * 1000 +
        progress.goldAwardCount(5) * 250 +
        progress.unlockedAchievements.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    final samplePlayers = [
      _LeaderboardPlayer(
        name: progress.playerName,
        level: playerLevel,
        score: leaderboardScore,
        isYou: true,
      ),
      const _LeaderboardPlayer(
        name: 'Andromeda',
        level: 8,
        score: 8700,
      ),
      const _LeaderboardPlayer(
        name: 'Orion',
        level: 6,
        score: 6400,
      ),
      const _LeaderboardPlayer(
        name: 'Lyra',
        level: 4,
        score: 4300,
      ),
      const _LeaderboardPlayer(
        name: 'Nova',
        level: 3,
        score: 3100,
      ),
    ]..sort((a, b) => b.score.compareTo(a.score));

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
                'Leaderboard',
                style: TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rankings are currently local preview data. Online leaderboard will come later.',
                style: TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ...samplePlayers.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;

                return Card(
                  color: player.isYou
                      ? const Color(0xFF132B46)
                      : const Color(0xFF10243B),
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: player.isYou
                          ? const Color(0xFFFFD98A)
                          : const Color(0x223A5B80),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF071426),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFFFFD98A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player.isYou ? '${player.name}  You' : player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Level ${player.level}',
                      style: const TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                    trailing: Text(
                      '${player.score}',
                      style: const TextStyle(
                        color: Color(0xFFFFD98A),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

class _LeaderboardPlayer {
  final String name;
  final int level;
  final int score;
  final bool isYou;

  const _LeaderboardPlayer({
    required this.name,
    required this.level,
    required this.score,
    this.isYou = false,
  });
}