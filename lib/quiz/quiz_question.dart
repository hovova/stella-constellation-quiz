import '../models/constellation.dart';

class QuizQuestion {
  final String questionText;
  final Constellation correctAnswer;
  final List<Constellation> options;

  const QuizQuestion({
    required this.questionText,
    required this.correctAnswer,
    required this.options,
  });
}