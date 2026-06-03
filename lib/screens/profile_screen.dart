import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/app_text.dart';
import '../data/avatars.dart';
import '../data/campaign_levels.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import 'achievements_screen.dart';
import 'avatar_selection_screen.dart';
import 'credits_screen.dart';
import 'home_screen.dart';
import 'leaderboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const ProfileScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  String text(String key) {
    return AppText.get(progress.selectedLanguageCode, key);
  }

  String avatarName(String avatarId) {
    final languageCode = progress.selectedLanguageCode;

    final names = {
      'en': {
        'star': 'Star',
        'moon': 'Moon',
        'rocket': 'Rocket',
        'planet': 'Planet',
        'trophy': 'Trophy',
        'premium': 'Premium',
      },
      'uk': {
        'star': 'Зоря',
        'moon': 'Місяць',
        'rocket': 'Ракета',
        'planet': 'Планета',
        'trophy': 'Кубок',
        'premium': 'Преміум',
      },
      'ru': {
        'star': 'Звезда',
        'moon': 'Луна',
        'rocket': 'Ракета',
        'planet': 'Планета',
        'trophy': 'Кубок',
        'premium': 'Премиум',
      },
    };

    return names[languageCode]?[avatarId] ??
        names['en']?[avatarId] ??
        findAvatarById(avatarId).name;
  }

  int get playerLevel {
    return (progress.totalXp ~/ 1000) + 1;
  }

  int get campaignGoldAwardCount {
    return campaignLevels.where((level) {
      final totalQuestions =
          level.constellations.length < 5 ? level.constellations.length : 5;

      return progress.hasGoldAward(level.id, totalQuestions);
    }).length;
  }

  int get leaderboardScore {
    return playerLevel * 1000 +
        campaignGoldAwardCount * 250 +
        progress.unlockedAchievements.length * 100;
  }

  bool isValidName(String name) {
    final cleanedName = name.trim().toLowerCase();

    if (cleanedName.length < 3 || cleanedName.length > 16) {
      return false;
    }

    final validCharacters = RegExp(r'^[a-zA-Z0-9А-Яа-яІіЇїЄєҐґЁё\s]+$');

    if (!validCharacters.hasMatch(cleanedName)) {
      return false;
    }

    const blockedWords = [
      'fuck',
      'shit',
      'bitch',
      'nazi',
      'hitler',
      'хуй',
      'сука',
      'блять',
      'пизда',
    ];

    return !blockedWords.any(cleanedName.contains);
  }

  void openEditNameDialog(BuildContext context) {
    StellaAudioService.playButtonTap();

    final controller = TextEditingController(text: progress.playerName);

    showDialog(
      context: context,
      builder: (_) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF10243B),
              title: Text(
                text('editName'),
                style: const TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: controller,
                maxLength: 16,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: text('enterPlayerName'),
                  hintStyle: const TextStyle(color: Colors.white38),
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    StellaAudioService.playButtonTap();
                    Navigator.pop(context);
                  },
                  child: Text(text('cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    StellaAudioService.playButtonTap();

                    final newName = controller.text.trim();

                    if (!isValidName(newName)) {
                      setDialogState(() {
                        errorText = text('invalidName');
                      });
                      return;
                    }

                    final updatedProgress = progress.copyWith(
                      playerName: newName,
                    );

                    onProgressUpdated(updatedProgress);
                    Navigator.pop(context);
                  },
                  child: Text(text('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void openLeaderboard(BuildContext context) {
    StellaAudioService.playButtonTap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeaderboardScreen(progress: progress),
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

  void openAvatarSelection(BuildContext context) {
    StellaAudioService.playButtonTap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvatarSelectionScreen(
          progress: progress,
          onProgressUpdated: onProgressUpdated,
        ),
      ),
    );
  }

  void openCredits(BuildContext context) {
    StellaAudioService.playButtonTap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreditsScreen(
          languageCode: progress.selectedLanguageCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = findAvatarById(progress.selectedAvatarId);

    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              text('profile'),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              text('profileDescription'),
              style: const TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            Card(
              color: const Color(0xFF10243B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0x223A5B80)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: progress.selectedAvatarFrameId == 'seven_day'
                              ? const Color(0xFFFFD98A)
                              : progress.selectedAvatarFrameId == 'premium_gold'
                                  ? const Color(0xFFB78CFF)
                                  : Colors.transparent,
                          width:
                              progress.selectedAvatarFrameId == 'none' ? 0 : 3,
                        ),
                        boxShadow: progress.selectedAvatarFrameId == 'none'
                            ? null
                            : [
                                BoxShadow(
                                  color: progress.selectedAvatarFrameId ==
                                          'premium_gold'
                                      ? const Color(0x55B78CFF)
                                      : const Color(0x55FFD98A),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF071426),
                        child: Icon(
                          avatar.fallbackIcon,
                          color: const Color(0xFFFFD98A),
                          size: 38,
                        ),
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            progress.playerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${avatarName(avatar.id)} • ${text('level')} $playerLevel',
                            style: const TextStyle(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () => openEditNameDialog(context),
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _ProfileMainButton(
                    title: text('avatar'),
                    subtitle: text('chooseLook'),
                    icon: Icons.face,
                    filled: false,
                    onTap: () => openAvatarSelection(context),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _ProfileMainButton(
                    title: text('achievements'),
                    subtitle: text('viewBadges'),
                    icon: Icons.emoji_events,
                    filled: true,
                    onTap: () => openAchievements(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _ProfileMainButton(
              title: text('leaderboard'),
              subtitle: text('leaderboardSubtitle'),
              icon: Icons.leaderboard,
              filled: false,
              wide: true,
              onTap: () => openLeaderboard(context),
            ),

            const SizedBox(height: 24),

            _ProfileStatCard(
              title: text('level'),
              value: '$playerLevel',
              icon: Icons.trending_up,
            ),
            _ProfileStatCard(
              title: text('leaderboardScore'),
              value: '$leaderboardScore',
              icon: Icons.leaderboard,
            ),
            _ProfileStatCard(
              title: text('totalXp'),
              value: '${progress.totalXp}',
              icon: Icons.bolt,
            ),
            _ProfileStatCard(
              title: text('dailyLoginStreak'),
              value: '${progress.dailyLoginStreak}',
              icon: Icons.calendar_month,
            ),
            _ProfileStatCard(
              title: text('goldAwards'),
              value: '$campaignGoldAwardCount',
              icon: Icons.workspace_premium,
            ),
            _ProfileStatCard(
              title: text('achievements'),
              value:
                  '${progress.unlockedAchievements.length} / ${allAchievements.length}',
              icon: Icons.emoji_events,
            ),
            _ProfileStatCard(
              title: text('language'),
              value: progress.selectedLanguageCode.toUpperCase(),
              icon: Icons.language,
            ),
            _ProfileStatCard(
              title: text('sound'),
              value: progress.soundEnabled ? text('on') : text('off'),
              icon: progress.soundEnabled ? Icons.volume_up : Icons.volume_off,
            ),
            _ProfileStatCard(
              title: text('noAdsStatus'),
              value: progress.hasNoAds || progress.hasPremium
                  ? text('active')
                  : text('inactive'),
              icon: Icons.block,
            ),
            _ProfileStatCard(
              title: text('premiumStatus'),
              value: progress.hasPremium ? text('active') : text('inactive'),
              icon: Icons.workspace_premium,
            ),

            const SizedBox(height: 8),

            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white38,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(
                  Icons.image_outlined,
                  size: 15,
                ),
                label: Text(
                  text('imageCredits'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => openCredits(context),
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _ProfileMainButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool filled;
  final bool wide;
  final VoidCallback onTap;

  const _ProfileMainButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        filled ? const Color(0xFFFFD98A) : Colors.transparent;

    final borderColor =
        filled ? const Color(0xFFFFD98A) : const Color(0x99FFD98A);

    final contentColor =
        filled ? const Color(0xFF071426) : const Color(0xFFFFD98A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: wide ? 72 : 84,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              wide ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: contentColor,
              size: wide ? 24 : 27,
            ),

            SizedBox(width: wide ? 14 : 10),

            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: wide ? TextAlign.left : TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: wide ? 16 : 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    textAlign: wide ? TextAlign.left : TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          filled ? const Color(0xCC071426) : Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0x223A5B80)),
      ),
      child: ListTile(
        dense: true,
        minLeadingWidth: 28,
        visualDensity: const VisualDensity(
          horizontal: 0,
          vertical: -2,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 3,
        ),
        leading: Icon(
          icon,
          color: const Color(0xFFFFD98A),
          size: 20,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}