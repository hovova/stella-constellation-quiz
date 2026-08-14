import '../models/achievement.dart';

class AchievementIds {
  static const firstLogin = 'first_login';
  static const firstQuiz = 'first_quiz';
  static const goldStargazer = 'gold_stargazer';
  static const diamondSkyMaster = 'diamond_sky_master';
  static const sevenDayLogin = 'seven_day_login';
  // New Duel Achievements
  static const win10Duels = 'win_10_duels';
  static const win100Duels = 'win_100_duels';
  static const win1000Duels = 'win_1000_duels';
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

const Achievement sevenDayLoginAchievement = Achievement(
  id: AchievementIds.sevenDayLogin,
  title: '7-Day Stargazer',
  description: 'Log in for 7 days in a row and unlock a special avatar frame.',
  emoji: '📅',
);

// New Duel Achievements
const Achievement win10DuelsAchievement = Achievement(
  id: AchievementIds.win10Duels,
  title: 'Duelist Novice',
  description: 'Win 10 live multiplayer duels.',
  emoji: '⚔️',
);

const Achievement win100DuelsAchievement = Achievement(
  id: AchievementIds.win100Duels,
  title: 'Arena Veteran',
  description: 'Win 100 live multiplayer duels.',
  emoji: '🛡️',
);

const Achievement win1000DuelsAchievement = Achievement(
  id: AchievementIds.win1000Duels,
  title: 'Grand Champion',
  description: 'Win 1000 live multiplayer duels.',
  emoji: '👑',
);

const List<Achievement> allAchievements = [
  firstLoginAchievement,
  firstQuizAchievement,
  goldStargazerAchievement,
  diamondSkyMasterAchievement,
  sevenDayLoginAchievement,
  win10DuelsAchievement,
  win100DuelsAchievement,
  win1000DuelsAchievement,
];