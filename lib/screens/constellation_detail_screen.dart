import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../models/constellation.dart';
import '../services/audio_service.dart';
import 'home_screen.dart';

class ConstellationDetailScreen extends StatelessWidget {
  final Constellation constellation;
  final String languageCode;

  const ConstellationDetailScreen({
    super.key,
    required this.constellation,
    required this.languageCode,
  });

  String text(String key) {
    return AppText.get(languageCode, key);
  }

  void openFullscreenImage(BuildContext context) {
    StellaAudioService.playButtonTap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenConstellationImage(
          constellation: constellation,
          languageCode: languageCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StellaGradientScaffold(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                onPressed: () {
                  StellaAudioService.playButtonTap();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 12),

              Text(
                constellation.nameFor(languageCode),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD98A),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                constellation.descriptionFor(languageCode),
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                height: 330,
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xFF10243B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0x223A5B80),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Center(
                          child: Transform.scale(
                            scale: 1.75,
                            child: Image.asset(
                              constellation.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    text('constellationImageMissing'),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Material(
                        color: const Color(0xCC071426),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => openFullscreenImage(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0x55FFD98A),
                              ),
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Color(0xFFFFD98A),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _InfoCard(
                title: text('difficulty'),
                value: constellation.difficultyFor(languageCode),
                icon: Icons.stacked_bar_chart,
              ),
              _InfoCard(
                title: text('hemisphere'),
                value: constellation.hemisphereFor(languageCode),
                icon: Icons.public,
              ),
              _InfoCard(
                title: text('bestSeason'),
                value: constellation.bestSeasonFor(languageCode),
                icon: Icons.calendar_month,
              ),
              _InfoCard(
                title: text('brightestStar'),
                value: constellation.brightestStar,
                icon: Icons.star,
              ),

              const SizedBox(height: 24),

              Text(
                text('mythology'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                constellation.mythologyFor(languageCode),
                style: const TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullscreenConstellationImage extends StatelessWidget {
  final Constellation constellation;
  final String languageCode;

  const _FullscreenConstellationImage({
    required this.constellation,
    required this.languageCode,
  });

  String text(String key) {
    return AppText.get(languageCode, key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030814),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.7,
                maxScale: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      constellation.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          text('constellationImageMissing'),
                          style: const TextStyle(
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              top: 16,
              child: Material(
                color: const Color(0xCC071426),
                borderRadius: BorderRadius.circular(16),
                child: IconButton(
                  onPressed: () {
                    StellaAudioService.playButtonTap();
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 76,
              right: 16,
              top: 22,
              child: Text(
                constellation.nameFor(languageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF10243B),
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x223A5B80)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFFFFD98A),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}