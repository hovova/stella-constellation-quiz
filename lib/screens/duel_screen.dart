import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../models/player_progress.dart';
import 'home_screen.dart';

class DuelScreen extends StatelessWidget {
  final PlayerProgress progress;

  const DuelScreen({
    super.key,
    required this.progress,
  });

  String text(String key) {
    return AppText.get(progress.selectedLanguageCode, key);
  }

  @override
  Widget build(BuildContext context) {
    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text('duelTitle'),
              style: const TextStyle(
                color: Color(0xFFFFD98A),
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              text('duelDescription'),
              style: const TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 46),

            Card(
              color: const Color(0xFF10243B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(
                  color: Color(0x223A5B80),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.sports_esports,
                      color: Color(0xFFFFD98A),
                      size: 34,
                    ),

                    const SizedBox(height: 26),

                    Text(
                      text('friendDuelsComingSoon'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      text('duelCardDescription'),
                      style: const TextStyle(
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
                child: Text(text('createDuelRoom')),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: null,
                child: Text(text('joinWithCode')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}