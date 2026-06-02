import 'package:flutter/material.dart';

import '../models/player_progress.dart';
import 'home_screen.dart';
import 'campaign_screen.dart';
import 'constellations_screen.dart';
import 'duel_screen.dart';
import 'profile_screen.dart';
import '../data/achievements.dart';
import '../widgets/achievement_popup.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int selectedIndex = 0;
  PlayerProgress progress = PlayerProgress.initial();

  void updateProgress(PlayerProgress updatedProgress) {
    setState(() {
      progress = updatedProgress;
    });
  }

  void onTabSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      CampaignScreen(
        progress: progress,
        onProgressUpdated: updateProgress,
      ),
      const ConstellationsScreen(),
      const DuelScreen(),
      ProfileScreen(progress: progress),
    ];

    @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!progress.hasAchievement(AchievementIds.firstLogin)) {
        final updatedProgress = progress.unlockAchievement(
          AchievementIds.firstLogin,
        );

        setState(() {
          progress = updatedProgress;
        });

        showAchievementPopup(context, firstLoginAchievement);
      }
    });
  }

    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onTabSelected,
        backgroundColor: const Color(0xFF071426),
        indicatorColor: const Color(0xFFD6A84F).withValues(alpha: 0.25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Campaign',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Stars',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Duel',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}