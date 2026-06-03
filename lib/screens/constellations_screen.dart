import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/constellation_data.dart';
import '../models/constellation.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import 'constellation_detail_screen.dart';
import 'home_screen.dart';

class ConstellationsScreen extends StatefulWidget {
  final PlayerProgress progress;

  const ConstellationsScreen({
    super.key,
    required this.progress,
  });

  @override
  State<ConstellationsScreen> createState() => _ConstellationsScreenState();
}

class _ConstellationsScreenState extends State<ConstellationsScreen> {
  String searchQuery = '';

  String text(String key) {
    return AppText.get(widget.progress.selectedLanguageCode, key);
  }

  List<Constellation> get filteredConstellations {
    final query = searchQuery.toLowerCase().trim();
    final languageCode = widget.progress.selectedLanguageCode;

    return allConstellations.where((constellation) {
      final localizedName = constellation.nameFor(languageCode).toLowerCase();
      final englishName = constellation.name.toLowerCase();

      return localizedName.contains(query) || englishName.contains(query);
    }).toList();
  }

  void openConstellation(Constellation constellation) {
    StellaAudioService.playButtonTap();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConstellationDetailScreen(
          constellation: constellation,
          languageCode: widget.progress.selectedLanguageCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = widget.progress.selectedLanguageCode;

    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text('starsTitle'),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              text('starsDescription'),
              style: const TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              style: const TextStyle(color: Colors.white),
              onTap: StellaAudioService.playButtonTap,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: text('searchConstellations'),
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF10243B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: filteredConstellations.length,
                itemBuilder: (context, index) {
                  final constellation = filteredConstellations[index];

                  return Card(
                    color: const Color(0xFF10243B),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => openConstellation(constellation),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                color: const Color(0xFF071426),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0x22A5B8E0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Transform.scale(
                                  scale: 1.65,
                                  child: Image.asset(
                                    constellation.iconPath,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.auto_awesome,
                                        color: Color(0xFFFFD98A),
                                        size: 34,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    constellation.nameFor(languageCode),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${constellation.difficultyFor(languageCode)} • ${constellation.bestSeasonFor(languageCode)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white38,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}