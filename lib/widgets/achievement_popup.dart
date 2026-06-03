import 'dart:async';

import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../models/achievement.dart';
import '../services/audio_service.dart';

void showAchievementPopup(
  BuildContext context,
  Achievement achievement, {
  required String languageCode,
}) {
  final shouldPlayAchievementSound = achievement.id != 'first_login';

  if (shouldPlayAchievementSound) {
    unawaited(StellaAudioService.playAchievementUnlock());
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF10243B),
      duration: const Duration(seconds: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFFFD98A),
        ),
      ),
      content: Row(
        children: [
          Text(
            achievement.emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.get(languageCode, 'achievementUnlocked'),
                  style: const TextStyle(
                    color: Color(0xFFFFD98A),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  localizedAchievementTitle(
                    achievement: achievement,
                    languageCode: languageCode,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  localizedAchievementDescription(
                    achievement: achievement,
                    languageCode: languageCode,
                  ),
                  style: const TextStyle(
                    color: Colors.white60,
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

String localizedAchievementTitle({
  required Achievement achievement,
  required String languageCode,
}) {
  switch (achievement.id) {
    case 'first_login':
      return AppText.get(languageCode, 'firstLoginTitle');
    case 'first_quiz':
      return AppText.get(languageCode, 'firstQuizTitle');
    case 'gold_stargazer':
      return AppText.get(languageCode, 'goldStargazerTitle');
    case 'diamond_sky_master':
      return AppText.get(languageCode, 'diamondSkyMasterTitle');
    case 'seven_day_login':
      return AppText.get(languageCode, 'sevenDayLoginTitle');
    default:
      return achievement.title;
  }
}

String localizedAchievementDescription({
  required Achievement achievement,
  required String languageCode,
}) {
  switch (achievement.id) {
    case 'first_login':
      return AppText.get(languageCode, 'firstLoginDescription');
    case 'first_quiz':
      return AppText.get(languageCode, 'firstQuizDescription');
    case 'gold_stargazer':
      return AppText.get(languageCode, 'goldStargazerDescription');
    case 'diamond_sky_master':
      return AppText.get(languageCode, 'diamondSkyMasterDescription');
    case 'seven_day_login':
      return AppText.get(languageCode, 'sevenDayLoginDescription');
    default:
      return achievement.description;
  }
}