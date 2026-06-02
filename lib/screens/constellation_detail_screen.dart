import 'package:flutter/material.dart';

import '../models/constellation.dart';
import 'home_screen.dart';

class ConstellationDetailScreen extends StatelessWidget {
  final Constellation constellation;

  const ConstellationDetailScreen({
    super.key,
    required this.constellation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 12),

              Text(
                constellation.name,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD98A),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                constellation.description,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              _InfoCard(
                title: 'Difficulty',
                value: constellation.difficulty,
                icon: Icons.stacked_bar_chart,
              ),
              _InfoCard(
                title: 'Hemisphere',
                value: constellation.hemisphere,
                icon: Icons.public,
              ),
              _InfoCard(
                title: 'Best Season',
                value: constellation.bestSeason,
                icon: Icons.calendar_month,
              ),
              _InfoCard(
                title: 'Brightest Star',
                value: constellation.brightestStar,
                icon: Icons.star,
              ),

              const SizedBox(height: 24),

              const Text(
                'Mythology',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                constellation.mythology,
                style: const TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}