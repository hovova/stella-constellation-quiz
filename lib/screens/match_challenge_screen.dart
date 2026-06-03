import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/constellation_data.dart';
import '../models/campaign_level.dart';
import '../models/constellation.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class MatchChallengeScreen extends StatefulWidget {
  final String titleKey;
  final List<Constellation> constellations;
  final PlayerProgress progress;

  final CampaignLevel? campaignLevel;
  final void Function(PlayerProgress updatedProgress)? onProgressUpdated;
  final bool countForCampaignProgress;

  const MatchChallengeScreen({
    super.key,
    required this.titleKey,
    required this.constellations,
    required this.progress,
    this.campaignLevel,
    this.onProgressUpdated,
    this.countForCampaignProgress = false,
  });

  @override
  State<MatchChallengeScreen> createState() => _MatchChallengeScreenState();
}

class _MatchChallengeScreenState extends State<MatchChallengeScreen> {
  static const int startingLives = 3;

  late final List<Constellation> roundTargets;

  int currentRoundIndex = 0;
  int completedRounds = 0;
  int lives = startingLives;

  late List<Constellation> currentRoundConstellations;
  late List<Constellation> currentNameOptions;

  String? selectedIconId;
  final Set<String> matchedIds = {};

  String? wrongIconId;
  String? wrongNameId;

  bool progressSaved = false;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();

    StellaAudioService.pauseMusicForGame();

    final random = Random();
    final shuffled = [...widget.constellations]..shuffle(random);

    final roundCount = min(5, shuffled.length);
    roundTargets = shuffled.take(roundCount).toList();

    setupRound();
  }

  @override
  void dispose() {
    StellaAudioService.resumeMusicForMenu();
    super.dispose();
  }

  String text(String key) {
    return AppText.get(widget.progress.selectedLanguageCode, key);
  }

  void setupRound() {
    final random = Random();
    final target = roundTargets[currentRoundIndex];

    final distractors = allConstellations
        .where((item) => item.id != target.id)
        .toList()
      ..shuffle(random);

    currentRoundConstellations = [
      target,
      ...distractors.take(3),
    ]..shuffle(random);

    currentNameOptions = [...currentRoundConstellations]..shuffle(random);

    selectedIconId = null;
    matchedIds.clear();
    wrongIconId = null;
    wrongNameId = null;
  }

  int calculateXpEarned() {
    final minimumMeaningfulScore = (roundTargets.length / 2).ceil();

    if (completedRounds < minimumMeaningfulScore) {
      return 0;
    }

    final correctRoundXp = completedRounds * 10;
    const completionBonus = 20;
    final perfectBonus = completedRounds == roundTargets.length ? 30 : 0;

    return correctRoundXp + completionBonus + perfectBonus;
  }

  void selectIcon(Constellation constellation) {
    if (isFinished || matchedIds.contains(constellation.id)) {
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
    if (isFinished || matchedIds.contains(constellation.id)) {
      return;
    }

    if (selectedIconId == null) {
      StellaAudioService.playButtonTap();
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

      if (matchedIds.length == currentRoundConstellations.length) {
        Future.delayed(
          const Duration(milliseconds: 450),
          completeRound,
        );
      }

      return;
    }

    StellaAudioService.playWrongAnswer();

    setState(() {
      lives--;
      wrongIconId = selectedIconId;
      wrongNameId = constellation.id;
    });

    if (lives <= 0) {
      Future.delayed(
        const Duration(milliseconds: 550),
        finishChallenge,
      );
      return;
    }

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || isFinished) return;

      setState(() {
        wrongIconId = null;
        wrongNameId = null;
        selectedIconId = null;
      });
    });
  }

  void completeRound() {
    if (isFinished) return;

    completedRounds++;

    final isLastRound = currentRoundIndex == roundTargets.length - 1;

    if (isLastRound) {
      finishChallenge();
      return;
    }

    setState(() {
      currentRoundIndex++;
      setupRound();
    });
  }

  void saveCampaignProgressIfNeeded() {
    if (progressSaved) {
      return;
    }

    if (!widget.countForCampaignProgress ||
        widget.campaignLevel == null ||
        widget.onProgressUpdated == null) {
      return;
    }

    progressSaved = true;

    final xpEarned = calculateXpEarned();

    final updatedProgress = widget.progress.addQuizResult(
      levelId: widget.campaignLevel!.id,
      score: completedRounds,
      totalQuestions: roundTargets.length,
      xpEarned: xpEarned,
    );

    widget.onProgressUpdated!(updatedProgress);
  }

  void finishChallenge() {
    if (isFinished) return;

    isFinished = true;
    saveCampaignProgressIfNeeded();

    final xpEarned = calculateXpEarned();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10243B),
          title: Text(
            text('premiumModeComplete'),
            style: const TextStyle(
              color: Color(0xFFFFD98A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '${text('score')}: $completedRounds / ${roundTargets.length}\n'
            '${text('xpEarned')}: +$xpEarned ${text('xp')}',
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
    final selected = selectedIconId == constellation.id;

    return InkWell(
      onTap: () => selectIcon(constellation),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconCardColor(constellation),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected || matched
                ? const Color(0xFFFFD98A)
                : const Color(0x223A5B80),
            width: selected || matched ? 1.6 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Transform.scale(
                scale: 1.18,
                child: Image.asset(
                  constellation.iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD98A),
                      size: 42,
                    );
                  },
                ),
              ),
            ),
            if (matched)
              const Positioned(
                right: 5,
                top: 5,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFFFD98A),
                  size: 21,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildNameCard(Constellation constellation) {
    final matched = matchedIds.contains(constellation.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: () => selectName(constellation),
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: nameCardColor(constellation),
            borderRadius: BorderRadius.circular(17),
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
                size: 19,
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
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLives() {
    return Row(
      children: List.generate(startingLives, (index) {
        final active = index < lives;

        return Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Icon(
            active ? Icons.favorite : Icons.favorite_border,
            color: active ? const Color(0xFFFF6B6B) : Colors.white30,
            size: 18,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalRounds = roundTargets.length;
    final roundText = '${currentRoundIndex + 1} / $totalRounds';
    final boardProgress =
        matchedIds.length / currentRoundConstellations.length;

    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 34,
                child: IconButton(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    StellaAudioService.playButtonTap();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                text(widget.titleKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${text('question')} $roundText • ${text('score')} $completedRounds',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  buildLives(),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: (currentRoundIndex + 1) / totalRounds,
                  minHeight: 5,
                  backgroundColor: const Color(0xFF10243B),
                  color: const Color(0xFFFFD98A),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                text('dailyMatchInstructions'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.25,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                '${text('dailyMatchProgress')}: ${matchedIds.length} / ${currentRoundConstellations.length}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: boardProgress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF10243B),
                  color: const Color(0xFFFFD98A),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.25,
                      children: currentRoundConstellations
                          .map(buildIconCard)
                          .toList(),
                    ),

                    const SizedBox(height: 14),

                    ...currentNameOptions.map(buildNameCard),

                    const SizedBox(height: 10),
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