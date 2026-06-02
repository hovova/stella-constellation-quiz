import 'package:flutter/material.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: const [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Track your progress, achievements and premium status.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            SizedBox(height: 28),

            _ProfileStatCard(
              title: 'Level',
              value: '1',
              icon: Icons.trending_up,
            ),
            _ProfileStatCard(
              title: 'XP',
              value: '0',
              icon: Icons.bolt,
            ),
            _ProfileStatCard(
              title: 'Achievements',
              value: '0 / 20',
              icon: Icons.emoji_events,
            ),
            _ProfileStatCard(
              title: 'Premium',
              value: 'Inactive',
              icon: Icons.workspace_premium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ProfileStatCard({
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
          style: const TextStyle(
            color: Colors.white60,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}