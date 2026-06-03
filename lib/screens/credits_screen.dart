import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class CreditsScreen extends StatelessWidget {
  final String languageCode;

  const CreditsScreen({
    super.key,
    required this.languageCode,
  });

  String text(String key) {
    return AppText.get(languageCode, key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StellaGradientScaffold(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      StellaAudioService.playButtonTap();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  text('imageCredits'),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD98A),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  text('imageCreditsDescription'),
                  style: const TextStyle(
                    color: Colors.white60,
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 24),

                _CreditCard(
                  title: text('creditsNoirlabTitle'),
                  icon: Icons.public,
                  body: text('creditsNoirlabBody'),
                ),

                const SizedBox(height: 14),

                _CreditCard(
                  title: text('creditsAdaptationsTitle'),
                  icon: Icons.brush,
                  body: text('creditsAdaptationsBody'),
                ),

                const SizedBox(height: 14),

                _CreditCard(
                  title: text('creditsIndependenceTitle'),
                  icon: Icons.info_outline,
                  body: text('creditsIndependenceBody'),
                ),

                const SizedBox(height: 14),

                _CreditCard(
                  title: text('creditsOtherAssetsTitle'),
                  icon: Icons.auto_awesome,
                  body: text('creditsOtherAssetsBody'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _CreditCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF10243B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0x223A5B80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFD98A),
              size: 26,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFFFD98A),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    body,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}