import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';



import '../data/constellation_data.dart';
import '../models/constellation.dart';
import '../models/campaign_level.dart';
import '../models/player_progress.dart';
import '../quiz/quiz_question.dart';
import 'home_screen.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final CampaignLevel level;
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const QuizScreen({
    super.key,
    required this.level,
    required this.progress,
    required this.onProgressUpdated,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> questions;

  static const int secondsPerQuestion = 15;
  static const int startingLives = 3;

  int currentQuestionIndex = 0;
  int score = 0;
  int lives = startingLives;
  int secondsLeft = secondsPerQuestion;

  Timer? questionTimer;
  Constellation? selectedAnswer;
  bool hasAnswered = false;
  bool timedOut = false;
  
  @override
  void initState() {
    super.initState();
    questions = generateQuestions();
    startQuestionTimer();
  }

@override
void dispose() {
  questionTimer?.cancel();
  super.dispose();
}

void startQuestionTimer() {
  questionTimer?.cancel();

  setState(() {
    secondsLeft = secondsPerQuestion;
    timedOut = false;
  });

  questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted || hasAnswered) {
      timer.cancel();
      return;
    }

    if (secondsLeft <= 1) {
      timer.cancel();
      handleTimeout();
      return;
    }

    setState(() {
      secondsLeft--;
    });
  });
}

void handleTimeout() {
  if (hasAnswered) return;

  setState(() {
    hasAnswered = true;
    timedOut = true;
    lives--;
  });
}

  List<QuizQuestion> generateQuestions() {
    final random = Random();
    final shuffled = [...widget.level.constellations]..shuffle(random);

    final selectedConstellations = shuffled
        .take(min(5, widget.level.constellations.length))
        .toList();

    return selectedConstellations.map((correctConstellation) {
      final wrongOptions = allConstellations
          .where((item) => item.id != correctConstellation.id)
          .toList()
        ..shuffle(random);

      final options = [
        correctConstellation,
        ...wrongOptions.take(3),
      ]..shuffle(random);

      return QuizQuestion(
        questionText: 'Which constellation is shown?',
        correctAnswer: correctConstellation,
        options: options,
      );
    }).toList();
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

  void selectAnswer(Constellation answer) {
    if (hasAnswered) return;

    questionTimer?.cancel();

    final isCorrect =
        answer.id == questions[currentQuestionIndex].correctAnswer.id;

    setState(() {
      selectedAnswer = answer;
      hasAnswered = true;

      if (isCorrect) {
        score++;
      } else {
        lives--;
      }
    });
  }

    void nextQuestion() {
    final isLastQuestion = currentQuestionIndex == questions.length - 1;
    final isOutOfLives = lives <= 0;

    if (isLastQuestion || isOutOfLives) {
      questionTimer?.cancel();

      final xpEarned = calculateXpEarned();

      final updatedProgress = widget.progress.addQuizResult(
        levelId: widget.level.id,
        score: score,
        totalQuestions: questions.length,
        xpEarned: xpEarned,
      );

      widget.onProgressUpdated(updatedProgress);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            level: widget.level,
            progress: updatedProgress,
            score: score,
            totalQuestions: questions.length,
            xpEarned: xpEarned,
            onProgressUpdated: widget.onProgressUpdated,
          ),
        ),
      );

      return;
    }

    setState(() {
      currentQuestionIndex++;
      selectedAnswer = null;
      hasAnswered = false;
      timedOut = false;
    });

    startQuestionTimer();
  }

  Color getOptionColor(Constellation option) {
    if (!hasAnswered) {
      return const Color(0xFF10243B);
    }

    final correctAnswer = questions[currentQuestionIndex].correctAnswer;

    if (option.id == correctAnswer.id) {
      return const Color(0xFF1F7A4D);
    }

    if (selectedAnswer?.id == option.id && option.id != correctAnswer.id) {
      return const Color(0xFF8A2F2F);
    }

    return const Color(0xFF10243B);
  }

@override
Widget build(BuildContext context) {
  final question = questions[currentQuestionIndex];
  final correctConstellation = question.correctAnswer;
  final progressText = '${currentQuestionIndex + 1} / ${questions.length}';

  Widget answerButton(Constellation option) {
    return Expanded(
      child: SizedBox.expand(
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: getOptionColor(option),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: () => selectAnswer(option),
          child: Text(
            option.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  return Scaffold(
    body: StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 34,
              child: IconButton(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              widget.level.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFD98A),
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

                  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Question $progressText • Score $score',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Color(0xFFFF6B6B),
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                '$lives',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.timer_outlined,
                color: Color(0xFFFFD98A),
                size: 17,
              ),
              const SizedBox(width: 4),
              Text(
                '${secondsLeft}s',
                style: TextStyle(
                  color: secondsLeft <= 5
                      ? const Color(0xFFFF6B6B)
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              minHeight: 4,
              backgroundColor: const Color(0xFF10243B),
              color: const Color(0xFFFFD98A),
            ),

            const SizedBox(height: 12),

            Text(
              question.questionText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                height: 1.18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

          if (timedOut) ...[
            const SizedBox(height: 8),
            const Text(
              'Time is up! You lost 1 life.',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF10243B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0x223A5B80),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    correctConstellation.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Constellation image missing',
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 190,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        answerButton(question.options[0]),
                        const SizedBox(width: 12),
                        answerButton(question.options[1]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: Row(
                      children: [
                        answerButton(question.options[2]),
                        const SizedBox(width: 12),
                        answerButton(question.options[3]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: hasAnswered ? nextQuestion : null,
                  child: Text(
                    lives <= 0 || currentQuestionIndex == questions.length - 1
                        ? 'See Results'
                        : 'Next Question',
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