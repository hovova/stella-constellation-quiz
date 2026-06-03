import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/constellation_data.dart';
import '../models/campaign_level.dart';
import '../models/constellation.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class MythologyQuizScreen extends StatefulWidget {
  final CampaignLevel level;
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const MythologyQuizScreen({
    super.key,
    required this.level,
    required this.progress,
    required this.onProgressUpdated,
  });

  @override
  State<MythologyQuizScreen> createState() => _MythologyQuizScreenState();
}

class _MythologyQuizScreenState extends State<MythologyQuizScreen> {
  late final List<Constellation> questions;
  late List<Constellation> currentOptions;

  int currentQuestionIndex = 0;
  int score = 0;
  bool hasAnswered = false;
  Constellation? selectedAnswer;

  @override
  void initState() {
    super.initState();

    StellaAudioService.pauseMusicForGame();

    final random = Random();
    final shuffled = [...widget.level.constellations]..shuffle(random);

    questions = shuffled.take(min(5, shuffled.length)).toList();
    currentOptions = generateAnswerOptions(questions[currentQuestionIndex]);
  }

  @override
  void dispose() {
    StellaAudioService.resumeMusicForMenu();
    super.dispose();
  }

  String text(String key) {
    return AppText.get(widget.progress.selectedLanguageCode, key);
  }

  String mythologyQuestionText() {
    final value = text('mythologyQuestion');

    if (value != 'mythologyQuestion') {
      return value;
    }

    switch (widget.progress.selectedLanguageCode) {
      case 'uk':
        return 'Яке сузір’я описує ця історія?';
      case 'ru':
        return 'Какое созвездие описывает эта история?';
      default:
        return 'Which constellation does this story describe?';
    }
  }

  List<Constellation> generateAnswerOptions(Constellation correctAnswer) {
    final random = Random();

    final wrongOptions = allConstellations
        .where((item) => item.id != correctAnswer.id)
        .toList()
      ..shuffle(random);

    final options = [
      correctAnswer,
      ...wrongOptions.take(3),
    ]..shuffle(random);

    return options;
  }

  void selectAnswer(Constellation answer) {
    if (hasAnswered) return;

    final correctAnswer = questions[currentQuestionIndex];
    final isCorrect = answer.id == correctAnswer.id;

    setState(() {
      selectedAnswer = answer;
      hasAnswered = true;

      if (isCorrect) {
        score++;
      }
    });

    if (isCorrect) {
      StellaAudioService.playCorrectAnswer();
    } else {
      StellaAudioService.playWrongAnswer();
    }
  }

  int calculateXpEarned() {
    final minimumMeaningfulScore = (questions.length / 2).ceil();

    if (score < minimumMeaningfulScore) {
      return 0;
    }

    final correctAnswerXp = score * 10;
    const completionBonus = 20;
    final perfectBonus = score == questions.length ? 30 : 0;

    return correctAnswerXp + completionBonus + perfectBonus;
  }

  void nextQuestion() {
    final isLastQuestion = currentQuestionIndex == questions.length - 1;

    if (isLastQuestion) {
      finishQuiz();
      return;
    }

    setState(() {
      currentQuestionIndex++;
      selectedAnswer = null;
      hasAnswered = false;
      currentOptions = generateAnswerOptions(questions[currentQuestionIndex]);
    });
  }

  void finishQuiz() {
    final xpEarned = calculateXpEarned();

    final updatedProgress = widget.progress.addQuizResult(
      levelId: widget.level.id,
      score: score,
      totalQuestions: questions.length,
      xpEarned: xpEarned,
    );

    widget.onProgressUpdated(updatedProgress);

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
            '${text('score')}: $score / ${questions.length}\n'
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

  Color optionColor(Constellation option, Constellation correctAnswer) {
    if (!hasAnswered) {
      return const Color(0xFF10243B);
    }

    if (option.id == correctAnswer.id) {
      return const Color(0xFF1F7A4D);
    }

    if (selectedAnswer?.id == option.id && option.id != correctAnswer.id) {
      return const Color(0xFF8A2F2F);
    }

    return const Color(0xFF10243B);
  }

  Widget buildImageOption(Constellation option, Constellation correctAnswer) {
    final selected = selectedAnswer?.id == option.id;
    final correct = hasAnswered && option.id == correctAnswer.id;
    final wrongSelected = hasAnswered && selected && !correct;

    return InkWell(
      onTap: () => selectAnswer(option),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: optionColor(option, correctAnswer),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected || correct
                ? const Color(0xFFFFD98A)
                : const Color(0x223A5B80),
            width: selected || correct ? 1.6 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Transform.scale(
                scale: 1.18,
                child: Image.asset(
                  option.iconPath,
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
            if (hasAnswered && (correct || wrongSelected))
              Positioned(
                right: 5,
                top: 5,
                child: Icon(
                  correct ? Icons.check_circle : Icons.cancel,
                  color: correct
                      ? const Color(0xFFFFD98A)
                      : const Color(0xFFFF6B6B),
                  size: 21,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final correctAnswer = questions[currentQuestionIndex];
    final progressText = '${currentQuestionIndex + 1} / ${questions.length}';

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
                text('mythology'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${text('question')} $progressText • ${text('score')} $score',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                minHeight: 5,
                backgroundColor: const Color(0xFF10243B),
                color: const Color(0xFFFFD98A),
              ),

              const SizedBox(height: 14),

              Text(
                mythologyQuestionText(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 150,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10243B),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0x223A5B80),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      correctAnswer.mythologyFor(
                        widget.progress.selectedLanguageCode,
                      ),
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.42,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.42,
                  children: currentOptions
                      .map((option) => buildImageOption(option, correctAnswer))
                      .toList(),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: hasAnswered
                      ? () {
                          StellaAudioService.playButtonTap();
                          nextQuestion();
                        }
                      : null,
                  child: Text(
                    currentQuestionIndex == questions.length - 1
                        ? text('seeResults')
                        : text('nextQuestion'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}