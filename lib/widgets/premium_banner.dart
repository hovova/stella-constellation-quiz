import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../models/player_progress.dart';
import '../screens/premium_screen.dart';
import '../services/audio_service.dart';

class PremiumBanner extends StatelessWidget {
  final String languageCode;
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const PremiumBanner({
    super.key,
    required this.languageCode,
    required this.progress,
    required this.onProgressUpdated,
  });

  void openPremiumMenu(BuildContext context) {
    StellaAudioService.playButtonTap();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PremiumScreen(
        languageCode: languageCode,
        progress: progress,
        onProgressUpdated: onProgressUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noAdsText = AppText.get(languageCode, 'noAds');
    final premiumText = AppText.get(languageCode, 'premium');

    return InkWell(
      onTap: () => openPremiumMenu(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF10243B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0x55FFD98A),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.block,
              color: Color(0xFFFFD98A),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              noAdsText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '/',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD98A),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              premiumText,
              style: const TextStyle(
                color: Color(0xFFFFD98A),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}