import 'package:flutter/material.dart';
import 'home_screen.dart';

class DuelScreen extends StatelessWidget {
  const DuelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Duel',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Challenge friends in quick constellation quizzes.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            Card(
              color: const Color(0xFF10243B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0x223A5B80)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sports_esports,
                      color: Color(0xFFFFD98A),
                      size: 38,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Friend Duels Coming Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create a room code, invite a friend, answer the same questions, and compete for the highest score.',
                      style: TextStyle(
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: null,
                child: Text('Create Duel Room'),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: null,
                child: Text('Join with Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}