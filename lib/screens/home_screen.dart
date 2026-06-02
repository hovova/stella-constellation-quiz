import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../models/player_progress.dart';
import '../widgets/premium_banner.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatelessWidget {
  final PlayerProgress progress;
  final VoidCallback onNavigateToCampaign;

  const HomeScreen({
    super.key,
    required this.progress,
    required this.onNavigateToCampaign,
  });

  void showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10243B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: const Text(
          'Daily Challenge is coming soon.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

    void openAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(progress: progress),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = progress.unlockedAchievements.length;
    final totalAchievements = allAchievements.length;
    final achievementProgress = totalAchievements == 0
        ? 0.0
        : unlockedAchievements / totalAchievements;

    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mriya Interactive',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PremiumBanner(),
              ],
            ),

            const Spacer(),

            const Text(
              'STELLA',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
                color: Color(0xFFFFD98A),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Learn the stars. Master the sky.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Explore constellations, complete quiz levels, unlock achievements, and challenge friends.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 48),

            _HomeActionCard(
              title: 'Continue Campaign',
              subtitle: 'Start your journey through the night sky.',
              icon: Icons.rocket_launch_outlined,
              onTap: onNavigateToCampaign,
            ),

            const SizedBox(height: 14),

            _HomeActionCard(
              title: 'Daily Challenge',
              subtitle: 'Complete a short quiz and earn bonus XP.',
              icon: Icons.bolt_outlined,
              onTap: () => showComingSoon(context),
            ),

            const SizedBox(height: 14),

          _AchievementProgressCard(
            unlockedAchievements: unlockedAchievements,
            totalAchievements: totalAchievements,
            progress: achievementProgress,
            onTap: () => openAchievements(context),
          ),

            const Spacer(),

            const Center(
              child: Text(
                'Version 0.1.0',
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementProgressCard extends StatelessWidget {
  final int unlockedAchievements;
  final int totalAchievements;
  final double progress;
  final VoidCallback onTap;

  const _AchievementProgressCard({
    required this.unlockedAchievements,
    required this.totalAchievements,
    required this.progress,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events_outlined,
                    color: Color(0xFFFFD98A),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Achievement Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '$unlockedAchievements / $totalAchievements',
                    style: const TextStyle(
                      color: Color(0xFFFFD98A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: const Color(0xFF071426),
                  color: const Color(0xFFFFD98A),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tap to view your achievements, rewards, and locked badges.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          leading: Icon(
            icon,
            color: const Color(0xFFFFD98A),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.white38,
          ),
        ),
      ),
    );
  }
}

class StellaGradientScaffold extends StatelessWidget {
  final Widget child;

  const StellaGradientScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF071426),
            Color(0xFF0B1D33),
            Color(0xFF030814),
          ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}