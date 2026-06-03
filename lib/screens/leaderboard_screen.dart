import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../models/player_progress.dart';
import 'home_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  final PlayerProgress progress;

  const LeaderboardScreen({
    super.key,
    required this.progress,
  });

  String text(String key) {
    return AppText.get(progress.selectedLanguageCode, key);
  }

  int get playerLevel {
    return (progress.totalXp ~/ 1000) + 1;
  }

  int get leaderboardScore {
    return playerLevel * 1000 +
        progress.goldAwardCount(5) * 250 +
        progress.unlockedAchievements.length * 100;
  }

  List<_LeaderboardPlayer> buildLeaderboard() {
    final names = [
      'AstraNova',
      'OrionHunter',
      'LyraQueen',
      'CosmicMriya',
      'NovaKnight',
      'AndromedaAce',
      'StarVoyager',
      'PolarisPrime',
      'CelestialFox',
      'NebulaWolf',
      'VegaVision',
      'LunarFalcon',
      'SkyAtlas',
      'MeteorMind',
      'AuroraPilot',
      'GalaxySage',
      'SolarEcho',
      'CometSeeker',
      'StarlitOwl',
      'ZenithTiger',
      'NightCompass',
      'AstroDragon',
      'MoonlitBear',
      'CygnusWing',
      'PegasusPath',
      'CassiopeiaX',
      'ScorpiusFire',
      'TaurusTrail',
      'GeminiPulse',
      'LeoSpark',
      'VirgoNova',
      'HydraStorm',
      'DracoShift',
      'PhoenixRay',
      'AquilaArrow',
      'PerseusPeak',
      'CruxMaster',
      'UrsaLegend',
      'SiriusMode',
      'AltairQuest',
    ];

    final rivals = List.generate(200, (index) {
      final rankSeed = 200 - index;
      final baseName = names[index % names.length];
      final suffix = (index ~/ names.length) + 1;

      final level = 4 + (rankSeed ~/ 8);
      final score = 3200 + rankSeed * 185 + (index % 7) * 45;

      return _LeaderboardPlayer(
        name: '$baseName$suffix',
        level: level,
        score: score,
        isYou: false,
      );
    });

    rivals.add(
      _LeaderboardPlayer(
        name: progress.playerName,
        level: playerLevel,
        score: leaderboardScore,
        isYou: true,
      ),
    );

    rivals.sort((a, b) => b.score.compareTo(a.score));

    return rivals;
  }

  @override
  Widget build(BuildContext context) {
    final players = buildLeaderboard();
    final yourRank = players.indexWhere((player) => player.isYou) + 1;

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
              Text(
                text('stellaLeague'),
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${text('yourRank')}: #$yourRank / ${players.length}',
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text('leaguePreview'),
                style: const TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ...players.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;

                return Card(
                  color: player.isYou
                      ? const Color(0xFF132B46)
                      : const Color(0xFF10243B),
                  margin: const EdgeInsets.only(bottom: 12),
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
                      backgroundColor: index < 3
                          ? const Color(0xFFFFD98A)
                          : const Color(0xFF071426),
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          color: index < 3
                              ? const Color(0xFF071426)
                              : const Color(0xFFFFD98A),
                          fontWeight: FontWeight.bold,
                          fontSize: index < 99 ? 13 : 11,
                        ),
                      ),
                    ),
                    title: Text(
                      player.isYou
                          ? '${player.name}  ${text('you')}'
                          : player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${text('level')} ${player.level}',
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