import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/root_screen.dart';
import 'services/audio_service.dart';
import 'services/interstitial_ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    await StellaInterstitialAdService.preloadInterstitialAd();
  }

  runApp(const StellaApp());
}

class StellaApp extends StatefulWidget {
  const StellaApp({super.key});

  @override
  State<StellaApp> createState() => _StellaAppState();
}

class _StellaAppState extends State<StellaApp> with WidgetsBindingObserver {
  bool musicWasEnabledBeforePause = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    StellaAudioService.pauseAllAudioForAppBackground();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      musicWasEnabledBeforePause = StellaAudioService.musicEnabled;
      StellaAudioService.pauseAllAudioForAppBackground();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (musicWasEnabledBeforePause) {
        StellaAudioService.resumeAudioAfterAppForeground();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stella',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF071426),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6A84F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}