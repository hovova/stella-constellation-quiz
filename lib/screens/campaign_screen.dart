import 'package:flutter/material.dart';
import 'home_screen.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: const [
            Text(
              'Campaign',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Progress through difficulty levels and master the constellations.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            SizedBox(height: 28),

            _CampaignLevelCard(
              level: 'Beginner',
              description: 'Famous constellations like Orion, Ursa Major and Cassiopeia.',
              progress: '0 / 10 levels',
              unlocked: true,
            ),

            _CampaignLevelCard(
              level: 'Intermediate',
              description: 'Recognise more complex star patterns and seasonal skies.',
              progress: 'Locked',
              unlocked: false,
            ),

            _CampaignLevelCard(
              level: 'Advanced',
              description: 'Harder constellations with fewer obvious shapes.',
              progress: 'Locked',
              unlocked: false,
            ),

            _CampaignLevelCard(
              level: 'Expert',
              description: 'Rare and obscure constellations for true stargazers.',
              progress: 'Locked',
              unlocked: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignLevelCard extends StatelessWidget {
  final String level;
  final String description;
  final String progress;
  final bool unlocked;

  const _CampaignLevelCard({
    required this.level,
    required this.description,
    required this.progress,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: unlocked ? const Color(0xFF10243B) : const Color(0xFF081525),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: unlocked ? const Color(0x44FFD98A) : const Color(0x223A5B80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              unlocked ? Icons.lock_open_outlined : Icons.lock_outline,
              color: unlocked ? const Color(0xFFFFD98A) : Colors.white30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: TextStyle(
                      color: unlocked ? Colors.white : Colors.white38,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: unlocked ? Colors.white60 : Colors.white30,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    progress,
                    style: TextStyle(
                      color: unlocked ? const Color(0xFFFFD98A) : Colors.white30,
                      fontSize: 12,
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