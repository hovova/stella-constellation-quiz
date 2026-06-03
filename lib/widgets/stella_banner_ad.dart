import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

class StellaBannerAd extends StatefulWidget {
  const StellaBannerAd({super.key});

  @override
  State<StellaBannerAd> createState() => _StellaBannerAdState();
}

class _StellaBannerAdState extends State<StellaBannerAd> {
  BannerAd? bannerAd;
  bool isLoaded = false;
  bool hasFailed = false;

  @override
  void initState() {
    super.initState();

    if (!AdService.canLoadRealAds) {
      return;
    }

    loadBannerAd();
  }

  void loadBannerAd() {
    final ad = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted) return;

          setState(() {
            bannerAd = loadedAd as BannerAd;
            isLoaded = true;
            hasFailed = false;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();

          if (!mounted) return;

          setState(() {
            hasFailed = true;
            isLoaded = false;
          });

          debugPrint('Banner ad failed to load: $error');
        },
      ),
    );

    ad.load();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const _AdPlaceholder(
        label: 'Ad banner preview',
      );
    }

    if (hasFailed) {
      return const _AdPlaceholder(
        label: 'Ad unavailable',
      );
    }

    if (!isLoaded || bannerAd == null) {
      return const _AdPlaceholder(
        label: 'Loading ad...',
      );
    }

    return Center(
      child: Container(
        width: bannerAd!.size.width.toDouble(),
        height: bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF10243B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0x223A5B80),
          ),
        ),
        child: AdWidget(ad: bannerAd!),
      ),
    );
  }
}

class _AdPlaceholder extends StatelessWidget {
  final String label;

  const _AdPlaceholder({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF10243B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x223A5B80),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}