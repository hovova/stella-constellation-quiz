class Constellation {
  final String id;
  final String name;
  final String difficulty;
  final String hemisphere;
  final String bestSeason;
  final String brightestStar;
  final String imagePath;
  final String description;
  final String mythology;
  final String iconPath;

  final Map<String, String> localizedNames;
  final Map<String, String> localizedDescriptions;
  final Map<String, String> localizedMythologies;
  final Map<String, String> localizedDifficulties;
  final Map<String, String> localizedHemispheres;
  final Map<String, String> localizedBestSeasons;

  const Constellation({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.hemisphere,
    required this.bestSeason,
    required this.brightestStar,
    required this.imagePath,
    required this.description,
    required this.mythology,
    required this.iconPath,
    this.localizedNames = const {},
    this.localizedDescriptions = const {},
    this.localizedMythologies = const {},
    this.localizedDifficulties = const {},
    this.localizedHemispheres = const {},
    this.localizedBestSeasons = const {},
  });

  String nameFor(String languageCode) {
    return localizedNames[languageCode] ?? name;
  }

  String descriptionFor(String languageCode) {
    return localizedDescriptions[languageCode] ?? description;
  }

  String mythologyFor(String languageCode) {
    return localizedMythologies[languageCode] ?? mythology;
  }

  String difficultyFor(String languageCode) {
    return localizedDifficulties[languageCode] ?? difficulty;
  }

  String hemisphereFor(String languageCode) {
    return localizedHemispheres[languageCode] ?? hemisphere;
  }

  String bestSeasonFor(String languageCode) {
    return localizedBestSeasons[languageCode] ?? bestSeason;
  }
}