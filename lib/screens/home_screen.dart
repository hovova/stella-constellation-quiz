import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/app_text.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import '../widgets/language_selector.dart';
import '../widgets/premium_banner.dart';
import '../widgets/sound_toggle_button.dart';
import 'achievements_screen.dart';
import 'daily_match_challenge_screen.dart';

class HomeScreen extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;
  final VoidCallback onNavigateToCampaign;

  const HomeScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
    required this.onNavigateToCampaign,
  });

  void openDailyChallenge(BuildContext context) {
    StellaAudioService.playButtonTap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyMatchChallengeScreen(
          progress: progress,
          onProgressUpdated: onProgressUpdated,
        ),
      ),
    );
  }

  void openAchievements(BuildContext context) {
    StellaAudioService.playButtonTap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AchievementsScreen(progress: progress),
      ),
    );
  }

  void continueCampaign() {
    StellaAudioService.playButtonTap();
    onNavigateToCampaign();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = progress.unlockedAchievements.length;
    final totalAchievements = allAchievements.length;
    final achievementProgress = totalAchievements == 0
        ? 0.0
        : unlockedAchievements / totalAchievements;

    String text(String key) {
      return AppText.get(progress.selectedLanguageCode, key);
    }

    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mriya Interactive',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                LanguageSelector(
                  progress: progress,
                  onProgressUpdated: onProgressUpdated,
                ),
                const SizedBox(width: 8),
                SoundToggleButton(
                  progress: progress,
                  onProgressUpdated: onProgressUpdated,
                ),
                const SizedBox(width: 8),
                PremiumBanner(
                  languageCode: progress.selectedLanguageCode,
                ),
              ],
            ),

            const Spacer(),

            Text(
              text('homeTitle'),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
                color: Color(0xFFFFD98A),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              text('homeSubtitle'),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              text('homeDescription'),
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 48),

            _HomeActionCard(
              title: text('continueCampaign'),
              subtitle: text('continueCampaignSubtitle'),
              icon: Icons.rocket_launch_outlined,
              onTap: continueCampaign,
            ),

            const SizedBox(height: 14),

            _HomeActionCard(
              title: text('dailyChallenge'),
              subtitle: progress.hasCompletedDailyChallengeToday
                  ? text('dailyChallengeAlreadyClaimed')
                  : text('dailyChallengeSubtitle'),
              icon: Icons.bolt_outlined,
              onTap: () => openDailyChallenge(context),
            ),

            const SizedBox(height: 14),

            _AchievementProgressCard(
              title: text('achievementProgress'),
              subtitle: text('achievementProgressSubtitle'),
              unlockedAchievements: unlockedAchievements,
              totalAchievements: totalAchievements,
              progress: achievementProgress,
              onTap: () => openAchievements(context),
            ),

            const Spacer(),

            Center(
              child: Text(
                text('version'),
                style: const TextStyle(
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
  final String title;
  final String subtitle;
  final int unlockedAchievements;
  final int totalAchievements;
  final double progress;
  final VoidCallback onTap;

  const _AchievementProgressCard({
    required this.title,
    required this.subtitle,
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
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

              Text(
                subtitle,
                style: const TextStyle(
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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