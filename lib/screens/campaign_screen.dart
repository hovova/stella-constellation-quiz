import 'dart:math';

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

  int expectedQuestionsForLevel(CampaignLevel level) {
    return min(5, level.constellations.length);
  }

  bool isLevelUnlocked(CampaignLevel level) {
    if (level.levelNumber == 1) {
      return true;
    }

    final hasRequiredXp = progress.totalXp >= level.requiredXp;

    final previousLevelId = level.previousLevelId;
    final previousLevel = previousLevelId == null
        ? null
        : campaignLevels.where((item) => item.id == previousLevelId).firstOrNull;

    final hasPerfectPreviousLevel = previousLevel != null &&
        progress.hasPerfectScore(
          levelId: previousLevel.id,
          totalQuestions: expectedQuestionsForLevel(previousLevel),
        );

    return hasRequiredXp || hasPerfectPreviousLevel;
  }

  bool hasGoldAward(CampaignLevel level) {
    return progress.hasGoldAward(
      level.id,
      expectedQuestionsForLevel(level),
    );
  }

  int latestUnlockedLevelNumber() {
    int latest = 1;

    for (final level in campaignLevels) {
      if (isLevelUnlocked(level)) {
        latest = level.levelNumber;
      }
    }

    return latest;
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
    final latestUnlocked = latestUnlockedLevelNumber();

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

            Row(
              children: [
                const Icon(
                  Icons.bolt,
                  color: Color(0xFFFFD98A),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${progress.totalXp} XP',
                  style: const TextStyle(
                    color: Color(0xFFFFD98A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 18),
                const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFFFD98A),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${progress.goldAwardCount(5)} Gold',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              'Move through the sky path. Each level adds 4 new constellations while keeping previous ones.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            ...campaignLevels.map((level) {
              final unlocked = isLevelUnlocked(level);
              final gold = hasGoldAward(level);
              final isCurrent = unlocked && level.levelNumber == latestUnlocked;
              final alignLeft = level.levelNumber.isOdd;

              return _CampaignMapNode(
                level: level,
                unlocked: unlocked,
                gold: gold,
                isCurrent: isCurrent,
                alignLeft: alignLeft,
                bestScore: progress.bestScoresByLevel[level.id] ?? 0,
                totalQuestions: expectedQuestionsForLevel(level),
                onTap: unlocked ? () => startLevel(context, level) : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CampaignMapNode extends StatelessWidget {
  final CampaignLevel level;
  final bool unlocked;
  final bool gold;
  final bool isCurrent;
  final bool alignLeft;
  final int bestScore;
  final int totalQuestions;
  final VoidCallback? onTap;

  const _CampaignMapNode({
    required this.level,
    required this.unlocked,
    required this.gold,
    required this.isCurrent,
    required this.alignLeft,
    required this.bestScore,
    required this.totalQuestions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final constellationCount = level.constellations.length;

    final statusText = gold
        ? 'Gold Award • Perfect score'
        : unlocked
            ? 'Best: $bestScore / $totalQuestions • $constellationCount constellations'
            : 'Locked • ${level.requiredXp} XP or 100% previous';

    final node = InkWell(
      onTap: unlocked ? onTap : null,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gold
              ? const Color(0xFF172B3F)
              : unlocked
                  ? const Color(0xFF10243B)
                  : const Color(0xFF081525),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gold
                ? const Color(0xFFFFD98A)
                : unlocked
                    ? const Color(0x44FFD98A)
                    : const Color(0x223A5B80),
            width: gold ? 2 : 1,
          ),
          boxShadow: gold
              ? const [
                  BoxShadow(
                    color: Color(0x33FFD98A),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: gold
                      ? const Color(0xFFFFD98A)
                      : unlocked
                          ? const Color(0xFF233A55)
                          : const Color(0xFF0D1A2B),
                  child: Icon(
                    gold
                        ? Icons.workspace_premium
                        : unlocked
                            ? Icons.star
                            : Icons.lock_outline,
                    color: gold ? const Color(0xFF071426) : Colors.white70,
                    size: 29,
                  ),
                ),
                if (isCurrent)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD98A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF071426),
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      color: unlocked ? Colors.white : Colors.white38,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: gold
                          ? const Color(0xFFFFD98A)
                          : unlocked
                              ? Colors.white60
                              : Colors.white30,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: gold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      children: [
        Align(
          alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: node,
        ),

        if (level.levelNumber != campaignLevels.length)
          SizedBox(
            height: 42,
            child: CustomPaint(
              painter: _PathLinePainter(
                alignLeft: alignLeft,
                unlocked: unlocked,
              ),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

class _PathLinePainter extends CustomPainter {
  final bool alignLeft;
  final bool unlocked;

  const _PathLinePainter({
    required this.alignLeft,
    required this.unlocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = unlocked
          ? const Color(0x66FFD98A)
          : const Color(0x223A5B80)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final startX = alignLeft ? size.width * 0.28 : size.width * 0.72;
    final endX = alignLeft ? size.width * 0.72 : size.width * 0.28;

    final path = Path()
      ..moveTo(startX, 0)
      ..cubicTo(
        startX,
        size.height * 0.45,
        endX,
        size.height * 0.55,
        endX,
        size.height,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathLinePainter oldDelegate) {
    return oldDelegate.alignLeft != alignLeft ||
        oldDelegate.unlocked != unlocked;
  }
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}