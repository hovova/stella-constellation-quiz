import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class StellaMultiplayerService {
  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://com-mriyainteractive-stella-default-rtdb.europe-west1.firebasedatabase.app',
  );

  static final Random _random = Random();

  static String _generate6DigitCode() {
    return (100000 + _random.nextInt(900000)).toString();
  }

  static Future<String> createDuelRoom(String hostName) async {
    try {
      String roomCode = _generate6DigitCode();
      DatabaseReference roomRef = _db.ref('duels/$roomCode');

      var snapshot = await roomRef.get();
      while (snapshot.exists) {
        roomCode = _generate6DigitCode();
        roomRef = _db.ref('duels/$roomCode');
        snapshot = await roomRef.get();
      }

      await roomRef.set({
        'status': 'waiting',
        'isPublic': false,
        'currentRound': 0,
        'roundStartTime': ServerValue.timestamp,
        'players': {
          hostName: {
            'lives': 3,
            'score': 0,
            'isHost': true,
            'answeredIndex': -1,
            'lastAnswerCorrect': false,
            'selectedOptionId': '',
          }
        }
      });

      return roomCode;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> findOrCreateRandomRoom(String playerName) async {
    try {
      final duelsRef = _db.ref('duels');
      final snapshot = await duelsRef.get();

      if (snapshot.exists) {
        final now = DateTime.now().millisecondsSinceEpoch;

        for (var child in snapshot.children) {
          final data = Map<String, dynamic>.from(child.value as Map);
          if (data['status'] == 'waiting' && data['isPublic'] == true) {
            int startTime = data['roundStartTime'] ?? 0;

            if (now - startTime > 60000) {
              await duelsRef.child(child.key!).remove();
              continue;
            }

            final players = Map<String, dynamic>.from(data['players'] as Map? ?? {});

            if (players.length == 1 && !players.containsKey(playerName)) {
              final roomCode = child.key!;

              await duelsRef.child('$roomCode/players/$playerName').set({
                'lives': 3,
                'score': 0,
                'isHost': false,
                'answeredIndex': -1,
                'lastAnswerCorrect': false,
                'selectedOptionId': '',
              });

              await duelsRef.child(roomCode).update({
                'status': 'playing',
                'currentRound': 0,
              });

              return roomCode;
            }
          }
        }
      }

      String roomCode = _generate6DigitCode();
      DatabaseReference newRoomRef = duelsRef.child(roomCode);

      await newRoomRef.set({
        'status': 'waiting',
        'isPublic': true,
        'currentRound': 0,
        'roundStartTime': ServerValue.timestamp,
        'players': {
          playerName: {
            'lives': 3,
            'score': 0,
            'isHost': true,
            'answeredIndex': -1,
            'lastAnswerCorrect': false,
            'selectedOptionId': '',
          }
        }
      });

      return roomCode;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> joinDuelRoom(String roomCode, String playerName) async {
    try {
      final roomRef = _db.ref('duels/$roomCode');
      final snapshot = await roomRef.get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        if (data['status'] == 'waiting') {
          await roomRef.child('players/$playerName').set({
            'lives': 3,
            'score': 0,
            'isHost': false,
            'answeredIndex': -1,
            'lastAnswerCorrect': false,
            'selectedOptionId': '',
          });
          await roomRef.update({
            'status': 'playing',
            'currentRound': 0,
          });
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> submitAnswer({
    required String roomCode,
    required String playerName,
    required bool isCorrect,
    required int currentLives,
    required int questionIndex,
    required String selectedOptionId,
  }) async {
    try {
      final playerRef = _db.ref('duels/$roomCode/players/$playerName');

      await playerRef.update({
        'answeredIndex': questionIndex,
        'lastAnswerCorrect': isCorrect,
        'selectedOptionId': selectedOptionId,
        'lives': currentLives,
      });

      if (isCorrect) {
        await playerRef.child('score').runTransaction((Object? value) {
          int score = (value as int? ?? 0) + 100;
          return Transaction.success(score);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> advanceToNextRound(String roomCode, int nextRoundIndex) async {
    try {
      await _db.ref('duels/$roomCode').update({
        'currentRound': nextRoundIndex,
        'roundStartTime': ServerValue.timestamp,
      });
    } catch (e) {
      rethrow;
    }
  }

  static Stream<DatabaseEvent> streamDuelState(String roomCode) {
    return _db.ref('duels/$roomCode').onValue;
  }
}