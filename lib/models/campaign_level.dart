import 'constellation.dart';

class CampaignLevel {
  final String id;
  final String title;
  final String description;
  final int levelNumber;
  final int requiredXp;
  final String? previousLevelId;
  final List<Constellation> constellations;

  const CampaignLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.levelNumber,
    required this.requiredXp,
    required this.previousLevelId,
    required this.constellations,
  });
}