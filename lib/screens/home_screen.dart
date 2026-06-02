import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StellaGradientScaffold(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                'Mriya Interactive',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 1.4,
                ),
              ),
            ),

            Spacer(),

            Text(
              'STELLA',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
                color: Color(0xFFFFD98A),
              ),
            ),

            SizedBox(height: 12),

            Text(
              'Learn the stars. Master the sky.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 16),

            Text(
              'Explore constellations, complete quiz levels, unlock achievements, and challenge friends.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white54,
              ),
            ),

            SizedBox(height: 48),

            _HomeActionCard(
              title: 'Continue Campaign',
              subtitle: 'Start your journey through the night sky.',
              icon: Icons.rocket_launch_outlined,
            ),

            SizedBox(height: 14),

            _HomeActionCard(
              title: 'Daily Challenge',
              subtitle: 'Complete a short quiz and earn bonus XP.',
              icon: Icons.bolt_outlined,
            ),

            SizedBox(height: 14),

            _HomeActionCard(
              title: 'Premium',
              subtitle: 'Remove ads and unlock offline quizzes.',
              icon: Icons.workspace_premium_outlined,
            ),

            Spacer(),

            Center(
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

class _HomeActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HomeActionCard({
    required this.title,
    required this.subtitle,
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