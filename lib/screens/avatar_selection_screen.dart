import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/avatars.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const AvatarSelectionScreen({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  late PlayerProgress visibleProgress;

  @override
  void initState() {
    super.initState();
    visibleProgress = widget.progress;
  }

  String text(String key) {
    return AppText.get(visibleProgress.selectedLanguageCode, key);
  }

  String avatarName(String avatarId) {
    final languageCode = visibleProgress.selectedLanguageCode;

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

  void updateVisibleProgress(PlayerProgress updatedProgress) {
    setState(() {
      visibleProgress = updatedProgress;
    });

    widget.onProgressUpdated(updatedProgress);
  }

  void showLockedPremiumMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10243B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text(
          text('unlockedWithPremium'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void showLockedFrameMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF10243B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text(
          text('lockedFrame'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void selectAvatar(BuildContext context, String avatarId) {
    StellaAudioService.playButtonTap();

    final isPremiumAvatar = avatarId == 'premium';

    if (isPremiumAvatar && !visibleProgress.hasPremium) {
      showLockedPremiumMessage(context);
      return;
    }

    final updatedProgress = visibleProgress.copyWith(
      selectedAvatarId: avatarId,
    );

    updateVisibleProgress(updatedProgress);
  }

  void selectFrame(BuildContext context, String frameId, bool unlocked) {
    StellaAudioService.playButtonTap();

    if (!unlocked) {
      showLockedFrameMessage(context);
      return;
    }

    final updatedProgress = visibleProgress.selectAvatarFrame(frameId);
    updateVisibleProgress(updatedProgress);
  }

  bool isFrameUnlocked(String frameId) {
    if (frameId == 'none') {
      return true;
    }

    if (frameId == 'seven_day') {
      return visibleProgress.unlockedAvatarFrameIds.contains('seven_day');
    }

    if (frameId == 'premium_gold') {
      return visibleProgress.hasPremium;
    }

    return false;
  }

  Color frameColor(String frameId) {
    switch (frameId) {
      case 'seven_day':
        return const Color(0xFFFFD98A);
      case 'premium_gold':
        return const Color(0xFFB78CFF);
      default:
        return Colors.white24;
    }
  }

  String frameTitle(String frameId) {
    switch (frameId) {
      case 'seven_day':
        return text('sevenDayFrame');
      case 'premium_gold':
        return text('premiumFrame');
      default:
        return text('noFrame');
    }
  }

  String frameSubtitle(String frameId) {
    switch (frameId) {
      case 'seven_day':
        return text('unlockedBySevenDayLogin');
      case 'premium_gold':
        return text('unlockedWithPremium');
      default:
        return text('active');
    }
  }

  IconData frameIcon(String frameId) {
    switch (frameId) {
      case 'seven_day':
        return Icons.calendar_month;
      case 'premium_gold':
        return Icons.workspace_premium;
      default:
        return Icons.block;
    }
  }

  Widget framedIcon({
    required IconData icon,
    required String frameId,
    required bool large,
    bool locked = false,
  }) {
    final hasFrame = frameId != 'none' && !locked;
    final color = frameColor(frameId);

    return Opacity(
      opacity: locked ? 0.35 : 1,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: hasFrame ? color : Colors.transparent,
            width: hasFrame ? 3 : 0,
          ),
          boxShadow: hasFrame
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: CircleAvatar(
          radius: large ? 36 : 26,
          backgroundColor: const Color(0xFF071426),
          child: Icon(
            locked ? Icons.lock_outline : icon,
            color: locked ? Colors.white38 : const Color(0xFFFFD98A),
            size: large ? 40 : 28,
          ),
        ),
      ),
    );
  }

  Widget buildAvatarTab() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1,
      children: avatarOptions.map((avatar) {
        final selected = avatar.id == visibleProgress.selectedAvatarId;
        final locked = avatar.id == 'premium' && !visibleProgress.hasPremium;

        return InkWell(
          onTap: () => selectAvatar(context, avatar.id),
          borderRadius: BorderRadius.circular(22),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected && !locked
                  ? const Color(0xFF132B46)
                  : const Color(0xFF10243B),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: selected && !locked
                    ? const Color(0xFFFFD98A)
                    : locked
                        ? const Color(0x334B5870)
                        : const Color(0x223A5B80),
                width: selected && !locked ? 1.4 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      framedIcon(
                        icon: avatar.fallbackIcon,
                        frameId: visibleProgress.selectedAvatarFrameId,
                        large: true,
                        locked: locked,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        avatarName(avatar.id),
                        style: TextStyle(
                          color: locked ? Colors.white38 : Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (locked) ...[
                        const SizedBox(height: 6),
                        Text(
                          text('lockedFrame'),
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected && !locked)
                  const Positioned(
                    right: 14,
                    top: 14,
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFFFFD98A),
                      size: 22,
                    ),
                  ),
                if (locked)
                  const Positioned(
                    right: 14,
                    top: 14,
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.white38,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildFrameTab(BuildContext context) {
    final frameIds = [
      'none',
      'seven_day',
      'premium_gold',
    ];

    return Column(
      children: frameIds.map((frameId) {
        final selected = visibleProgress.selectedAvatarFrameId == frameId;
        final unlocked = isFrameUnlocked(frameId);
        final color = frameColor(frameId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => selectFrame(context, frameId, unlocked),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF132B46)
                    : const Color(0xFF10243B),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFFD98A)
                      : const Color(0x223A5B80),
                  width: selected ? 1.4 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: frameId == 'none' ? Colors.white24 : color,
                        width: frameId == 'none' ? 1.2 : 3,
                      ),
                      boxShadow: selected && frameId != 'none'
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF071426),
                      child: Icon(
                        unlocked ? frameIcon(frameId) : Icons.lock_outline,
                        color: unlocked ? color : Colors.white30,
                        size: 27,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          frameTitle(frameId),
                          style: TextStyle(
                            color: unlocked ? Colors.white : Colors.white38,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          unlocked
                              ? frameSubtitle(frameId)
                              : text('lockedFrame'),
                          style: TextStyle(
                            color: unlocked ? Colors.white54 : Colors.white30,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    selected
                        ? Icons.check_circle
                        : unlocked
                            ? Icons.chevron_right
                            : Icons.lock_outline,
                    color: selected
                        ? const Color(0xFFFFD98A)
                        : Colors.white38,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: StellaGradientScaffold(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      StellaAudioService.playButtonTap();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text('chooseAvatar'),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD98A),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text('chooseAvatarSubtitle'),
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF071426),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0x223A5B80),
                    ),
                  ),
                  child: TabBar(
                    onTap: (_) => StellaAudioService.playButtonTap(),
                    indicator: BoxDecoration(
                      color: const Color(0xFFFFD98A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: const Color(0xFF071426),
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.face),
                        text: text('avatar'),
                      ),
                      Tab(
                        icon: const Icon(Icons.workspace_premium),
                        text: text('avatarFrames'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: TabBarView(
                    children: [
                      ListView(
                        children: [
                          buildAvatarTab(),
                          const SizedBox(height: 20),
                        ],
                      ),
                      ListView(
                        children: [
                          Text(
                            text('chooseFrame'),
                            style: const TextStyle(
                              color: Colors.white60,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildFrameTab(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}