import 'package:flutter/foundation.dart';

import '../models/player_progress.dart';

class AdService {
  static bool shouldShowAds(PlayerProgress progress) {
    return !progress.hasNoAds && !progress.hasPremium;
  }

  static bool shouldShowInterstitialAfterLevel(PlayerProgress progress) {
    return shouldShowAds(progress);
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) {
      return '';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Google official Android test interstitial ad unit.
      return 'ca-app-pub-3940256099942544/1033173712';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Google official iOS test interstitial ad unit.
      return 'ca-app-pub-3940256099942544/4411468910';
    }

    return '';
  }

  static String get bannerAdUnitId {
    if (kIsWeb) {
      return '';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }

    return '';
  }

  static bool get canLoadRealAds {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }
}