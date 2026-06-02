import '../models/campaign_level.dart';
import 'constellation_data.dart';

final List<CampaignLevel> campaignLevels = [
  CampaignLevel(
    id: 'beginner_level_1',
    title: 'Level 1: Famous Shapes',
    description: 'Start with the most recognisable constellations.',
    levelNumber: 1,
    requiredXp: 0,
    previousLevelId: null,
    constellations: beginnerConstellations.take(5).toList(),
  ),
  CampaignLevel(
    id: 'beginner_level_2',
    title: 'Level 2: Northern Guides',
    description: 'Unlock by earning 1000 XP or getting 100% on Level 1.',
    levelNumber: 2,
    requiredXp: 1000,
    previousLevelId: 'beginner_level_1',
    constellations: beginnerConstellations.skip(2).take(5).toList(),
  ),
  CampaignLevel(
    id: 'beginner_level_3',
    title: 'Level 3: Zodiac Basics',
    description: 'Unlock by earning 2000 XP or getting 100% on Level 2.',
    levelNumber: 3,
    requiredXp: 2000,
    previousLevelId: 'beginner_level_2',
    constellations: beginnerConstellations.skip(5).take(5).toList(),
  ),
];