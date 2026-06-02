import '../models/achievement.dart';

class AchievementIds {
  static const firstLogin = 'first_login';
  static const firstQuiz = 'first_quiz';
  static const goldStargazer = 'gold_stargazer';
  static const diamondSkyMaster = 'diamond_sky_master';
}

const Achievement firstLoginAchievement = Achievement(
  id: AchievementIds.firstLogin,
  title: 'First Login',
  description: 'Welcome to Stella.',
  emoji: '✨',
);

const Achievement firstQuizAchievement = Achievement(
  id: AchievementIds.firstQuiz,
  title: 'First Quiz',
  description: 'Complete your first constellation quiz.',
  emoji: '🚀',
);

const Achievement goldStargazerAchievement = Achievement(
  id: AchievementIds.goldStargazer,
  title: 'Gold Stargazer',
  description: 'Earn your first Gold Award by scoring 100%.',
  emoji: '🏆',
);

const Achievement diamondSkyMasterAchievement = Achievement(
  id: AchievementIds.diamondSkyMaster,
  title: 'Diamond Sky Master',
  description: 'Earn Gold Awards on every campaign level.',
  emoji: '💎',
);

const List<Achievement> allAchievements = [
  firstLoginAchievement,
  firstQuizAchievement,
  goldStargazerAchievement,
  diamondSkyMasterAchievement,
];