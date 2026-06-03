import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_service.dart';

class StellaInterstitialAdService {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  static Future<bool> preloadInterstitialAd() async {
    if (!AdService.canLoadRealAds) {
      debugPrint('Interstitial skipped: platform cannot load real ads.');
      return false;
    }

    if (_interstitialAd != null) {
      return true;
    }

    if (_isLoading) {
      return false;
    }

    _isLoading = true;
    final completer = Completer<bool>();

    InterstitialAd.load(
      adUnitId: AdService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial loaded.');

          _interstitialAd = ad;
          _isLoading = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial dismissed.');
              ad.dispose();
              _interstitialAd = null;
              preloadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              preloadInterstitialAd();
            },
          );

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');

          _interstitialAd = null;
          _isLoading = false;

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      ),
    );

    return completer.future;
  }

  static Future<void> showInterstitialAdIfReady() async {
    if (!AdService.canLoadRealAds) {
      debugPrint('Interstitial show skipped: platform cannot load real ads.');
      return;
    }

    if (_interstitialAd == null) {
      final loaded = await preloadInterstitialAd();

      if (!loaded || _interstitialAd == null) {
        debugPrint('Interstitial not ready after preload.');
        return;
      }
    }

    final ad = _interstitialAd;
    _interstitialAd = null;

    if (ad == null) {
      return;
    }

    debugPrint('Showing interstitial.');
    await ad.show();
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoading = false;
  }
}