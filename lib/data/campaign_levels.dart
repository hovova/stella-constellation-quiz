import '../models/campaign_level.dart';
import 'constellation_data.dart';

final List<CampaignLevel> campaignLevels = List.generate(
  (allConstellations.length / 4).ceil(),
  (index) {
    final levelNumber = index + 1;
    final constellationCount = (levelNumber * 4).clamp(
      1,
      allConstellations.length,
    );

    return CampaignLevel(
      id: 'level_$levelNumber',
      title: 'Level $levelNumber',
      description: levelNumber == 1
          ? 'Start with the first 4 constellations.'
          : 'Adds 4 new constellations while keeping previous ones.',
      levelNumber: levelNumber,
      requiredXp: index * 1000,
      previousLevelId: levelNumber == 1 ? null : 'level_${levelNumber - 1}',
      constellations: allConstellations.take(constellationCount).toList(),
    );
  },
);