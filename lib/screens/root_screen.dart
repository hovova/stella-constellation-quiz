import 'package:flutter/material.dart';

import '../data/achievements.dart';
import '../data/app_text.dart';
import '../models/achievement.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import '../services/progress_storage_service.dart';
import '../widgets/achievement_popup.dart';
import 'campaign_screen.dart';
import 'constellations_screen.dart';
import 'duel_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final ProgressStorageService storageService = ProgressStorageService();

  int selectedIndex = 0;
  bool isLoading = true;
  bool hasTriedStartingMusicFromTap = false;

  PlayerProgress progress = PlayerProgress.initial();

  @override
  void initState() {
    super.initState();
    loadProgressWithSplash();
  }

  Future<void> loadProgressWithSplash() async {
    final results = await Future.wait([
      storageService.loadProgress(),
      Future.delayed(const Duration(milliseconds: 1800)),
    ]);

    final loadedProgress = results.first as PlayerProgress;

    if (!mounted) return;

    setState(() {
      progress = loadedProgress;
      isLoading = false;
    });

    await StellaAudioService.updateSoundState(
      soundEnabled: loadedProgress.soundEnabled,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      handleLoginAchievements();

      await Future.delayed(const Duration(milliseconds: 350));

      if (!mounted) return;

      await StellaAudioService.updateMusicState(
        musicEnabled: progress.musicEnabled,
      );
    });
  }

  void handleLoginAchievements() {
    var updatedProgress = progress;
    final List<Achievement> achievementsToShow = [];

    if (!updatedProgress.hasAchievement(AchievementIds.firstLogin)) {
      updatedProgress = updatedProgress.unlockAchievement(
        AchievementIds.firstLogin,
      );

      achievementsToShow.add(firstLoginAchievement);
    }

    updatedProgress = updatedProgress.recordDailyLogin();

    if (updatedProgress.dailyLoginStreak >= 7 &&
        !updatedProgress.hasAchievement(AchievementIds.sevenDayLogin)) {
      updatedProgress = updatedProgress
          .unlockAchievement(AchievementIds.sevenDayLogin)
          .unlockAvatarFrame('seven_day');

      achievementsToShow.add(sevenDayLoginAchievement);
    }

    if (updatedProgress != progress) {
      updateProgress(updatedProgress);
    }

    for (final achievement in achievementsToShow) {
      showAchievementPopup(
        context,
        achievement,
        languageCode: updatedProgress.selectedLanguageCode,
      );
    }
  }

  void updateProgress(PlayerProgress updatedProgress) {
    setState(() {
      progress = updatedProgress;
    });

    storageService.saveProgress(updatedProgress);

    StellaAudioService.updateSoundState(
      soundEnabled: updatedProgress.soundEnabled,
    );
  }

  void onTabSelected(int index) {
    StellaAudioService.startMusicAfterUserGesture();
    StellaAudioService.playButtonTap();

    setState(() {
      selectedIndex = index;
    });
  }

  void tryStartMusicFromFirstTap() {
    if (hasTriedStartingMusicFromTap) {
      return;
    }

    hasTriedStartingMusicFromTap = true;
    StellaAudioService.startMusicAfterUserGesture();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SplashScreen();
    }

    final languageCode = progress.selectedLanguageCode;
    String text(String key) => AppText.get(languageCode, key);

    final screens = [
      HomeScreen(
        progress: progress,
        onProgressUpdated: updateProgress,
        onNavigateToCampaign: () => onTabSelected(1),
      ),
      CampaignScreen(
        progress: progress,
        onProgressUpdated: updateProgress,
      ),
      ConstellationsScreen(
        progress: progress,
      ),
      DuelScreen(
        progress: progress,
      ),
      ProfileScreen(
        progress: progress,
        onProgressUpdated: updateProgress,
      ),
    ];

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => tryStartMusicFromFirstTap(),
      child: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onTabSelected,
          backgroundColor: const Color(0xFF071426),
          indicatorColor: const Color(0xFFD6A84F).withValues(alpha: 0.25),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: text('bottomHome'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map),
              label: text('bottomCampaign'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: const Icon(Icons.auto_awesome),
              label: text('bottomStars'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.sports_esports_outlined),
              selectedIcon: const Icon(Icons.sports_esports),
              label: text('bottomDuel'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: text('bottomProfile'),
            ),
          ],
        ),
      ),
    );
  }
}