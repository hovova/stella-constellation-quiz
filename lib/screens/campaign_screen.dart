import 'package:flutter/material.dart';

import '../data/campaign_levels.dart';
import '../models/campaign_level.dart';
import '../models/player_progress.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';

class CampaignScreen extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const CampaignScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  bool isLevelUnlocked(CampaignLevel level) {
    if (level.levelNumber == 1) {
      return true;
    }

    final hasRequiredXp = progress.totalXp >= level.requiredXp;

    final previousLevelId = level.previousLevelId;
    final hasPerfectPreviousLevel = previousLevelId != null &&
        progress.hasPerfectScore(
          levelId: previousLevelId,
          totalQuestions: 5,
        );

    return hasRequiredXp || hasPerfectPreviousLevel;
  }

  void startLevel(BuildContext context, CampaignLevel level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          level: level,
          progress: progress,
          onProgressUpdated: onProgressUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              'Campaign',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Total XP: ${progress.totalXp}',
              style: const TextStyle(
                color: Color(0xFFFFD98A),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Each level adds 4 new constellations while keeping previous ones. Unlock the next level with enough XP or 100% on the previous level.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            ...campaignLevels.map((level) {
              final unlocked = isLevelUnlocked(level);
              final bestScore = progress.bestScoresByLevel[level.id] ?? 0;

              return _CampaignLevelCard(
                level: level,
                unlocked: unlocked,
                bestScore: bestScore,
                onTap: unlocked ? () => startLevel(context, level) : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CampaignLevelCard extends StatelessWidget {
  final CampaignLevel level;
  final bool unlocked;
  final int bestScore;
  final VoidCallback? onTap;

  const _CampaignLevelCard({
    required this.level,
    required this.unlocked,
    required this.bestScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final constellationCount = level.constellations.length;
    final hasGoldAward = bestScore == 5;

    final progressText = unlocked
        ? hasGoldAward
            ? 'Gold Award • Perfect score • $constellationCount constellations'
            : 'Best score: $bestScore / 5 • $constellationCount constellations'
        : 'Locked • Requires ${level.requiredXp} XP or 100% on previous level';

    return Card(
      color: unlocked ? const Color(0xFF10243B) : const Color(0xFF081525),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: hasGoldAward
              ? const Color(0xFFFFD98A)
              : unlocked
                  ? const Color(0x44FFD98A)
                  : const Color(0x223A5B80),
        ),
      ),
      child: InkWell(
        onTap: unlocked ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(
                hasGoldAward
                    ? Icons.workspace_premium
                    : unlocked
                        ? Icons.lock_open_outlined
                        : Icons.lock_outline,
                color: hasGoldAward
                    ? const Color(0xFFFFD98A)
                    : unlocked
                        ? const Color(0xFFFFD98A)
                        : Colors.white30,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.title,
                      style: TextStyle(
                        color: unlocked ? Colors.white : Colors.white38,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      level.description,
                      style: TextStyle(
                        color: unlocked ? Colors.white60 : Colors.white30,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      progressText,
                      style: TextStyle(
                        color: hasGoldAward
                            ? const Color(0xFFFFD98A)
                            : unlocked
                                ? const Color(0xFFFFD98A)
                                : Colors.white30,
                        fontSize: 12,
                        fontWeight:
                            hasGoldAward ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              if (unlocked)
                Icon(
                  hasGoldAward
                      ? Icons.emoji_events
                      : Icons.chevron_right,
                  color: hasGoldAward
                      ? const Color(0xFFFFD98A)
                      : Colors.white38,
                ),
            ],
          ),
        ),
      ),
    );
  }
}