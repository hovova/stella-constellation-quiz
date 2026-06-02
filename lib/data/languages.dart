class AppLanguage {
  final String code;
  final String name;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });
}

const List<AppLanguage> appLanguages = [
  AppLanguage(
    code: 'en',
    name: 'English',
    flag: '🇬🇧',
  ),
  AppLanguage(
    code: 'uk',
    name: 'Українська',
    flag: '🇺🇦',
  ),
  AppLanguage(
    code: 'ru',
    name: 'Русский',
    flag: '🇷🇺',
  ),
];

AppLanguage findLanguageByCode(String code) {
  return appLanguages.firstWhere(
    (language) => language.code == code,
    orElse: () => appLanguages.first,
  );
}