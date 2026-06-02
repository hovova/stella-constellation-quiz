import 'package:flutter/material.dart';

import '../models/constellation.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String title;
  final int score;
  final int totalQuestions;
  final List<Constellation> constellations;

  const ResultsScreen({
    super.key,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.constellations,
  });

  int get accuracy {
    return ((score / totalQuestions) * 100).round();
  }

  int get xpEarned {
    return score * 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              const Text(
                'Quiz Complete',
                style: TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 36),

              _ResultCard(
                title: 'Score',
                value: '$score / $totalQuestions',
                icon: Icons.check_circle_outline,
              ),
              _ResultCard(
                title: 'Accuracy',
                value: '$accuracy%',
                icon: Icons.analytics_outlined,
              ),
              _ResultCard(
                title: 'XP Earned',
                value: '+$xpEarned XP',
                icon: Icons.bolt,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          title: title,
                          constellations: constellations,
                        ),
                      ),
                    );
                  },
                  child: const Text('Try Again'),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Campaign'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ResultCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF10243B),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x223A5B80)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFFD98A),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}