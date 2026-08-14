import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'multiplayer_service.dart';

class StellaBotService {
  static Timer? _matchmakingTimer;
  static final Random _random = Random();
  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://com-mriyainteractive-stella-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static const List<String> _botNames = [
    'AstraBot',
    'OrionAI',
    'NebulaDroid',
    'CosmicSim',
    'StarlightBot',
  ];

  static Future<void> joinBotInstantly(String roomCode) async {
    final roomRef = _db.ref('duels/$roomCode');
    final botName = _botNames[_random.nextInt(_botNames.length)];

    await roomRef.child('players/$botName').set({
      'lives': 3,
      'score': 0,
      'isHost': false,
      'isBot': true,
      'answeredIndex': -1,
      'lastAnswerCorrect': false,
      'selectedOptionId': '',
    });

    await roomRef.update({
      'status': 'playing',
      'currentRound': 0,
    });

    _simulateBotGameplay(roomCode, botName);
  }

  static void _simulateBotGameplay(String roomCode, String botName) {
    final roomRef = _db.ref('duels/$roomCode');

    roomRef.child('currentRound').onValue.listen((event) async {
      if (!event.snapshot.exists) return;
      final roundIndex = event.snapshot.value as int;

      final statusSnap = await roomRef.child('status').get();
      if (statusSnap.value != 'playing') return;

      final botSnap = await roomRef.child('players/$botName').get();
      if (!botSnap.exists) return;

      final botData = Map<String, dynamic>.from(botSnap.value as Map);
      final currentLives = (botData['lives'] ?? 3) as int;
      if (currentLives <= 0) return;

      final thinkTime = 3 + _random.nextInt(4);

      Future.delayed(Duration(seconds: thinkTime), () async {
        final currentRoundSnap = await roomRef.child('currentRound').get();
        if (currentRoundSnap.value != roundIndex) return;

        final statusCheck = await roomRef.child('status').get();
        if (statusCheck.value != 'playing') return;

        final isCorrect = _random.nextDouble() < 0.70;

        await StellaMultiplayerService.submitAnswer(
          roomCode: roomCode,
          playerName: botName,
          isCorrect: isCorrect,
          currentLives: currentLives,
          questionIndex: roundIndex,
          selectedOptionId: '', // Empty string for bot
        );
      });
    });
  }

  static void cancelTimer() {
    _matchmakingTimer?.cancel();
  }
}