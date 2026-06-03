import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/constellation_data.dart';
import '../models/constellation.dart';
import '../models/player_progress.dart';
import 'home_screen.dart';
import '../services/audio_service.dart';

class DailyMatchChallengeScreen extends StatefulWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const DailyMatchChallengeScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  @override
  State<DailyMatchChallengeScreen> createState() =>
      _DailyMatchChallengeScreenState();
}

class _DailyMatchChallengeScreenState extends State<DailyMatchChallengeScreen> {
  late final List<Constellation> challengeConstellations;
  late final List<Constellation> nameOptions;

  String? selectedIconId;
  final Set<String> matchedIds = {};

  String? wrongIconId;
  String? wrongNameId;

  static const int dailyRewardXp = 30;

    @override
  void initState() {
    super.initState();
    StellaAudioService.pauseMusicForGame();

    final random = Random();
    final shuffledConstellations = [...allConstellations]..shuffle(random);

    challengeConstellations = shuffledConstellations.take(4).toList();
    nameOptions = [...challengeConstellations]..shuffle(random);
  }

    @override
  void dispose() {
    StellaAudioService.resumeMusicForMenu();
    super.dispose();
  }

  String text(String key) {
    return AppText.get(widget.progress.selectedLanguageCode, key);
  }

  void selectIcon(Constellation constellation) {
  if (matchedIds.contains(constellation.id)) {
    return;
  }

  StellaAudioService.playButtonTap();

  setState(() {
    selectedIconId = constellation.id;
    wrongIconId = null;
    wrongNameId = null;
  });
}

  void selectName(Constellation constellation) {
    if (matchedIds.contains(constellation.id)) {
      return;
    }

    if (selectedIconId == null) {
      return;
    }

    if (selectedIconId == constellation.id) {
      StellaAudioService.playCorrectAnswer();
      setState(() {
        matchedIds.add(constellation.id);
        selectedIconId = null;
        wrongIconId = null;
        wrongNameId = null;
      });

      if (matchedIds.length == challengeConstellations.length) {
        Future.delayed(const Duration(milliseconds: 350), finishChallenge);
      }

      return;
    }
    
    StellaAudioService.playWrongAnswer();

    setState(() {
      wrongIconId = selectedIconId;
      wrongNameId = constellation.id;
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      setState(() {
        wrongIconId = null;
        wrongNameId = null;
        selectedIconId = null;
      });
    });
  }

  void finishChallenge() {
    final alreadyClaimed = widget.progress.hasCompletedDailyChallengeToday;
    final xpEarned = alreadyClaimed ? 0 : dailyRewardXp;

    var updatedProgress = widget.progress;

    if (!alreadyClaimed) {
      updatedProgress = updatedProgress
          .addXp(dailyRewardXp)
          .markDailyChallengeCompleted();

      widget.onProgressUpdated(updatedProgress);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10243B),
          title: Text(
            text('dailyChallengeCompleteTitle'),
            style: const TextStyle(
              color: Color(0xFFFFD98A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            alreadyClaimed
                ? text('dailyChallengeAlreadyClaimed')
                : '${text('dailyChallengeRewardEarned')}: +$xpEarned ${text('xp')}',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                StellaAudioService.playButtonTap();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(text('close')),
            ),
          ],
        );
      },
    );
  }

  Color iconCardColor(Constellation constellation) {
    if (matchedIds.contains(constellation.id)) {
      return const Color(0xFF1F7A4D);
    }

    if (wrongIconId == constellation.id) {
      return const Color(0xFF8A2F2F);
    }

    if (selectedIconId == constellation.id) {
      return const Color(0xFF18375A);
    }

    return const Color(0xFF10243B);
  }

  Color nameCardColor(Constellation constellation) {
    if (matchedIds.contains(constellation.id)) {
      return const Color(0xFF1F7A4D);
    }

    if (wrongNameId == constellation.id) {
      return const Color(0xFF8A2F2F);
    }

    return const Color(0xFF10243B);
  }

  Widget buildIconCard(Constellation constellation) {
    final matched = matchedIds.contains(constellation.id);

    return InkWell(
      onTap: () => selectIcon(constellation),
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconCardColor(constellation),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selectedIconId == constellation.id || matched
                ? const Color(0xFFFFD98A)
                : const Color(0x223A5B80),
            width: selectedIconId == constellation.id || matched ? 1.6 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Transform.scale(
                scale: 1.35,
                child: Image.asset(
                  constellation.iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD98A),
                      size: 46,
                    );
                  },
                ),
              ),
            ),
            if (matched)
              const Positioned(
                right: 6,
                top: 6,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFFFD98A),
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildNameCard(Constellation constellation) {
    final matched = matchedIds.contains(constellation.id);

    return InkWell(
      onTap: () => selectName(constellation),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: nameCardColor(constellation),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: matched
                ? const Color(0xFFFFD98A)
                : const Color(0x223A5B80),
          ),
        ),
        child: Row(
          children: [
            Icon(
              matched ? Icons.check_circle : Icons.label_outline,
              color: matched ? const Color(0xFFFFD98A) : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                constellation.nameFor(widget.progress.selectedLanguageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: matched ? const Color(0xFFFFD98A) : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alreadyClaimed = widget.progress.hasCompletedDailyChallengeToday;

    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 12),

              Text(
                text('dailyChallenge'),
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                text('dailyMatchInstructions'),
                style: const TextStyle(
                  color: Colors.white60,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.bolt,
                    color: Color(0xFFFFD98A),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    alreadyClaimed
                        ? text('dailyChallengeAlreadyClaimed')
                        : '+$dailyRewardXp ${text('xp')}',
                    style: const TextStyle(
                      color: Color(0xFFFFD98A),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                '${text('dailyMatchProgress')}: ${matchedIds.length} / ${challengeConstellations.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: matchedIds.length / challengeConstellations.length,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF10243B),
                  color: const Color(0xFFFFD98A),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      children: challengeConstellations.map(buildIconCard).toList(),
                    ),

                    const SizedBox(height: 18),

                    ...nameOptions.map(
                      (constellation) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: buildNameCard(constellation),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}