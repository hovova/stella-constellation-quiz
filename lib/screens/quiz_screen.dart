import 'dart:math';

import 'package:flutter/material.dart';

import '../data/constellation_data.dart';
import '../models/constellation.dart';
import '../quiz/quiz_question.dart';
import 'home_screen.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Constellation> constellations;
  final int questionCount;

  const QuizScreen({
    super.key,
    required this.title,
    required this.constellations,
    this.questionCount = 5,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> questions;

  int currentQuestionIndex = 0;
  int score = 0;
  Constellation? selectedAnswer;
  bool hasAnswered = false;

  @override
  void initState() {
    super.initState();
    questions = generateQuestions();
  }

  List<QuizQuestion> generateQuestions() {
    final random = Random();
    final shuffled = [...widget.constellations]..shuffle(random);

    final selectedConstellations = shuffled
        .take(min(widget.questionCount, widget.constellations.length))
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
        questionText:
            'Which constellation is best described as: "${correctConstellation.description}"',
        correctAnswer: correctConstellation,
        options: options,
      );
    }).toList();
  }

  void selectAnswer(Constellation answer) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswer = answer;
      hasAnswered = true;

      if (answer.id == questions[currentQuestionIndex].correctAnswer.id) {
        score++;
      }
    });
  }

  void nextQuestion() {
    final isLastQuestion = currentQuestionIndex == questions.length - 1;

    if (isLastQuestion) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            title: widget.title,
            score: score,
            totalQuestions: questions.length,
            constellations: widget.constellations,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentQuestionIndex++;
      selectedAnswer = null;
      hasAnswered = false;
    });
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
    final progressText = '${currentQuestionIndex + 1} / ${questions.length}';

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
                icon: const Icon(Icons.close),
              ),

              const SizedBox(height: 12),

              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Question $progressText • Score $score',
                style: const TextStyle(
                  color: Colors.white54,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                question.questionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 28),

              ...question.options.map((option) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: getOptionColor(option),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => selectAnswer(option),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        option.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              if (hasAnswered)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: nextQuestion,
                    child: Text(
                      currentQuestionIndex == questions.length - 1
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