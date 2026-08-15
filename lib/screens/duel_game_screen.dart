import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../data/constellation_data.dart';
import '../models/constellation.dart';
import '../models/player_progress.dart';
import '../quiz/quiz_question.dart';
import '../services/audio_service.dart';
import '../services/multiplayer_service.dart';
import 'home_screen.dart';

class DuelGameScreen extends StatefulWidget {
  final String roomCode;
  final PlayerProgress progress;
  final String playerName;
  final void Function(PlayerProgress)? onProgressUpdated;

  const DuelGameScreen({
    super.key,
    required this.roomCode,
    required this.progress,
    required this.playerName,
    this.onProgressUpdated,
  });

  @override
  State<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends State<DuelGameScreen> {
  late final List<QuizQuestion> questions;

  static const int secondsPerQuestion = 10;
  static const int startingLives = 3;

  int currentQuestionIndex = 0;
  int score = 0;
  int lives = startingLives;
  int opponentLives = startingLives;
  String opponentName = 'Opponent';
  String opponentSelectedOptionId = '';
  String opponentAvatarFrameId = 'none';

  bool isHost = false;
  int secondsLeft = secondsPerQuestion;

  Timer? questionTimer;
  Timer? opponentDisconnectTimer;
  Constellation? selectedAnswer;
  bool hasAnswered = false;
  bool timedOut = false;
  bool isGameOver = false;
  bool isShowingTransition = false;
  
  bool isWaitingForMatch = true;
  bool isMatchIntro = false;
  
  int introCountdown = 3;
  Timer? introTimer;
  bool _hasProcessedWin = false;

  String text(String key) {
    return AppText.get(widget.progress.selectedLanguageCode, key);
  }

  @override
  void initState() {
    super.initState();
    questions = generateFixedQuestions();
    StellaAudioService.pauseMusicForGame();
  }

  @override
  void dispose() {
    introTimer?.cancel();
    questionTimer?.cancel();
    opponentDisconnectTimer?.cancel();
    StellaAudioService.resumeMusicForMenu();
    super.dispose();
  }

  List<QuizQuestion> generateFixedQuestions() {
    final random = Random(widget.roomCode.hashCode);
    final shuffled = [...allConstellations]..shuffle(random);

    return shuffled.take(10).map((correctConstellation) {
      final wrongOptions = allConstellations
          .where((item) => item.id != correctConstellation.id)
          .toList()
        ..shuffle(random);

      final options = [
        correctConstellation,
        ...wrongOptions.take(3),
      ]..shuffle(random);

      return QuizQuestion(
        questionText: 'whichConstellationShown',
        correctAnswer: correctConstellation,
        options: options,
      );
    }).toList();
  }

  void _startIntroSequence() {
    introTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (introCountdown <= 1) {
        timer.cancel();
        setState(() {
          isMatchIntro = false;
        });
        startQuestionTimer();
      } else {
        setState(() {
          introCountdown--;
        });
      }
    });
  }

  void startQuestionTimer() {
    questionTimer?.cancel();
    if (!mounted) return;

    setState(() {
      secondsLeft = secondsPerQuestion;
      timedOut = false;
      isShowingTransition = false;
      selectedAnswer = null;
      hasAnswered = false;
      opponentSelectedOptionId = '';
    });

    questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || hasAnswered || isGameOver || isShowingTransition || isMatchIntro || isWaitingForMatch) {
        timer.cancel();
        return;
      }

      if (secondsLeft <= 1) {
        timer.cancel();
        handleTimeout();
        return;
      }

      if (mounted) {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  void _startOpponentDisconnectTimer() {
    opponentDisconnectTimer?.cancel();
    opponentDisconnectTimer = Timer(const Duration(seconds: 15), () {
      if (mounted && hasAnswered && !isShowingTransition && !isGameOver) {
        triggerOpponentDisconnect();
      }
    });
  }

  void triggerOpponentDisconnect() {
    if (isGameOver) return;
    setState(() {
      opponentLives = 0;
    });
    triggerGameOver();
  }

  void handleTimeout() async {
    if (hasAnswered || isGameOver) return;

    setState(() {
      hasAnswered = true;
      timedOut = true;
      lives--;
    });
    
    _startOpponentDisconnectTimer();
    StellaAudioService.playWrongAnswer();

    await StellaMultiplayerService.submitAnswer(
      roomCode: widget.roomCode,
      playerName: widget.playerName,
      isCorrect: false,
      currentLives: lives,
      questionIndex: currentQuestionIndex,
      selectedOptionId: '',
    );
  }

  void selectAnswer(Constellation answer) async {
    if (hasAnswered || isGameOver || isShowingTransition || isMatchIntro || isWaitingForMatch) return;

    questionTimer?.cancel();

    final isCorrect = answer.id == questions[currentQuestionIndex].correctAnswer.id;

    setState(() {
      selectedAnswer = answer;
      hasAnswered = true;
      if (isCorrect) {
        score += 100;
      } else {
        lives--;
      }
    });
    
    _startOpponentDisconnectTimer();

    if (isCorrect) {
      StellaAudioService.playCorrectAnswer();
    } else {
      StellaAudioService.playWrongAnswer();
    }

    await StellaMultiplayerService.submitAnswer(
      roomCode: widget.roomCode,
      playerName: widget.playerName,
      isCorrect: isCorrect,
      currentLives: lives,
      questionIndex: currentQuestionIndex,
      selectedOptionId: answer.id,
    );
  }

  void checkRoundProgression(Map<String, dynamic> playersMap) {
    if (isShowingTransition || isGameOver || isMatchIntro || isWaitingForMatch) return;

    if (playersMap.length < 2) return;

    bool allSubmitted = true;
    playersMap.forEach((_, pData) {
      final data = Map<String, dynamic>.from(pData as Map);
      final answeredIdx = (data['answeredIndex'] ?? -1) as int;
      if (answeredIdx < currentQuestionIndex) {
        allSubmitted = false;
      }
    });

    if (allSubmitted) {
      questionTimer?.cancel();
      opponentDisconnectTimer?.cancel();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || isShowingTransition || isGameOver) return;
        setState(() {
          isShowingTransition = true;
        });

        Timer(const Duration(seconds: 2), () async {
          if (!mounted || isGameOver) return;

          if (currentQuestionIndex >= questions.length - 1 || lives <= 0 || opponentLives <= 0) {
            triggerGameOver();
          } else if (isHost) {
            final nextIndex = currentQuestionIndex + 1;
            await StellaMultiplayerService.advanceToNextRound(widget.roomCode, nextIndex);
          }
        });
      });
    }
  }

  void triggerGameOver() {
    if (isGameOver) return;
    isGameOver = true;
    questionTimer?.cancel();
    opponentDisconnectTimer?.cancel();
    
    FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://com-mriyainteractive-stella-default-rtdb.europe-west1.firebasedatabase.app',
    ).ref('duels/${widget.roomCode}').update({'status': 'finished'});
  }

  Color getOptionColor(Constellation option) {
    final correctAnswer = questions[currentQuestionIndex].correctAnswer;

    if (isShowingTransition) {
      if (option.id == correctAnswer.id) {
        return const Color(0xFF1F7A4D); 
      }
      if (selectedAnswer?.id == option.id) {
        return const Color(0xFF8A2F2F); 
      }
      return const Color(0xFF10243B); 
    }

    if (hasAnswered) {
      if (selectedAnswer?.id == option.id) {
        return option.id == correctAnswer.id 
            ? const Color(0xFF1F7A4D) 
            : const Color(0xFF8A2F2F);
      }
      return const Color(0xFF10243B);
    }

    return const Color(0xFF10243B);
  }

  Color getFrameColor(String frameId) {
    switch (frameId) {
      case 'seven_day':
        return const Color(0xFFFFD98A);
      case 'premium_gold':
        return const Color(0xFFB78CFF);
      case 'crown':
        return const Color(0xFFFFB300);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: StellaMultiplayerService.streamDuelState(widget.roomCode),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final roomData = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final status = roomData['status'] as String? ?? 'waiting';
          final serverRound = (roomData['currentRound'] ?? 0) as int;
          final playersMap = Map<String, dynamic>.from(roomData['players'] as Map? ?? {});

          playersMap.forEach((name, pData) {
            final details = Map<String, dynamic>.from(pData as Map);
            if (name == widget.playerName) {
              isHost = (details['isHost'] ?? false) as bool;
            } else {
              opponentName = name;
              opponentLives = (details['lives'] ?? 3) as int;
              opponentAvatarFrameId = details['selectedAvatarFrameId'] ?? 'none';
              
              if (isShowingTransition) {
                opponentSelectedOptionId = details['selectedOptionId'] ?? '';
                if (opponentSelectedOptionId.isEmpty) {
                  bool opCorrect = details['lastAnswerCorrect'] ?? false;
                  if (opCorrect) {
                    opponentSelectedOptionId = questions[currentQuestionIndex].correctAnswer.id;
                  } else {
                    opponentSelectedOptionId = questions[currentQuestionIndex].options.firstWhere((o) => o.id != questions[currentQuestionIndex].correctAnswer.id).id;
                  }
                }
              }
            }
          });

          if (status == 'waiting') {
            return Scaffold(
              body: StellaGradientScaffold(
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () {
                          StellaAudioService.playButtonTap();
                          triggerGameOver();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Color(0xFFFFD98A)),
                          const SizedBox(height: 24),
                          const Text(
                            'Searching for opponent...',
                            style: TextStyle(color: Colors.white70, fontSize: 18, decoration: TextDecoration.none),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (status == 'playing' && isWaitingForMatch) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && isWaitingForMatch) {
                setState(() {
                  isWaitingForMatch = false;
                  isMatchIntro = true;
                });
                _startIntroSequence();
              }
            });
          }

          if (serverRound > currentQuestionIndex && !isGameOver && !isMatchIntro && !isWaitingForMatch) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && currentQuestionIndex != serverRound) {
                setState(() {
                  currentQuestionIndex = serverRound;
                });
                startQuestionTimer();
              }
            });
          }

          if (status == 'playing' && !isWaitingForMatch) {
            checkRoundProgression(playersMap);
          }

          if (status == 'finished' || (hasAnswered && (opponentLives <= 0 || lives <= 0))) {
            return _buildGameOverScreen();
          }
        }

        if (isMatchIntro) {
          return _buildMatchIntroScreen();
        }

        final question = questions[currentQuestionIndex];
        final correctConstellation = question.correctAnswer;
        final progressText = '${currentQuestionIndex + 1} / ${questions.length}';

        Widget answerButton(Constellation option) {
          bool isMyPick = hasAnswered && selectedAnswer?.id == option.id;
          bool isOppPick = isShowingTransition && opponentSelectedOptionId == option.id;

          return Expanded(
            child: SizedBox.expand(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: getOptionColor(option),
                  disabledBackgroundColor: getOptionColor(option), 
                  disabledForegroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: (hasAnswered || isShowingTransition || isWaitingForMatch) ? null : () => selectAnswer(option),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        option.nameFor(widget.progress.selectedLanguageCode),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, decoration: TextDecoration.none),
                      ),
                    ),
                    if (isMyPick)
                      const Positioned(
                        top: 0,
                        left: 0,
                        child: Icon(Icons.person, color: Colors.white, size: 18),
                      ),
                    if (isOppPick)
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(Icons.sports_esports, color: Colors.white70, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: StellaGradientScaffold(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 34,
                    child: IconButton(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        StellaAudioService.playButtonTap();
                        triggerGameOver();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.playerName}: $lives', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                        ],
                      ),
                      const Text(
                        'VS',
                        style: TextStyle(color: Color(0xFFFFD98A), fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none),
                      ),
                      Row(
                        children: [
                          Text('$opponentName: $opponentLives', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                          const SizedBox(width: 4),
                          const Icon(Icons.favorite, color: Colors.redAccent, size: 16),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${text('question')} $progressText • ${text('score')} $score',
                        style: const TextStyle(color: Colors.white54, fontSize: 14, decoration: TextDecoration.none),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Color(0xFFFFD98A), size: 17),
                          const SizedBox(width: 4),
                          Text(
                            isShowingTransition ? '...' : '$secondsLeft${text('secondsShort')}',
                            style: TextStyle(
                              color: secondsLeft <= 3 ? const Color(0xFFFF6B6B) : Colors.white70,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    minHeight: 4,
                    backgroundColor: const Color(0xFF10243B),
                    color: const Color(0xFFFFD98A),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text(question.questionText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10243B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0x223A5B80)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              correctConstellation.imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (hasAnswered && !isShowingTransition)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              text('waitingForOpponent'), 
                              style: const TextStyle(color: Colors.white70, fontSize: 13, decoration: TextDecoration.none),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              answerButton(question.options[0]),
                              const SizedBox(width: 12),
                              answerButton(question.options[1]),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Row(
                            children: [
                              answerButton(question.options[2]),
                              const SizedBox(width: 12),
                              answerButton(question.options[3]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchIntroScreen() {
    final myFrameId = widget.progress.selectedAvatarFrameId;
    final myFrameColor = getFrameColor(myFrameId);
    final oppFrameColor = getFrameColor(opponentAvatarFrameId);

    return Scaffold(
      body: StellaGradientScaffold(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text('opponentFound'), 
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: myFrameColor, width: myFrameId == 'none' ? 0 : 3),
                            ),
                            child: const CircleAvatar(
                              radius: 36,
                              backgroundColor: Color(0xFF10243B),
                              child: Icon(Icons.person, color: Color(0xFFFFD98A), size: 36),
                            ),
                          ),
                          if (myFrameId == 'crown')
                            const Positioned(top: -10, right: -6, child: Text('👑', style: TextStyle(fontSize: 22))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(widget.playerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('VS', style: TextStyle(color: Color(0xFFFFD98A), fontWeight: FontWeight.w900, fontSize: 24, decoration: TextDecoration.none)),
                  ),
                  Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: oppFrameColor, width: opponentAvatarFrameId == 'none' ? 0 : 3),
                            ),
                            child: const CircleAvatar(
                              radius: 36,
                              backgroundColor: Color(0xFF10243B),
                              child: Icon(Icons.sports_esports, color: Color(0xFFFFD98A), size: 36),
                            ),
                          ),
                          if (opponentAvatarFrameId == 'crown')
                            const Positioned(top: -10, right: -6, child: Text('👑', style: TextStyle(fontSize: 22))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(opponentName, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Text(
                '${text('startingIn')} $introCountdown...', 
                style: const TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    String outcomeTitle;
    String outcomeDesc;
    bool isWinner = lives > opponentLives;
    bool isLoser = lives < opponentLives;

    if (isWinner) {
      outcomeTitle = text('victoryTitle');
      outcomeDesc = text('victoryDescription');
      
      if (!_hasProcessedWin) {
         _hasProcessedWin = true;
         final updatedProgress = widget.progress.recordDuelWin();
         if (widget.onProgressUpdated != null) {
           widget.onProgressUpdated!(updatedProgress);
         }
      }
    } else if (isLoser) {
      outcomeTitle = text('defeatTitle');
      outcomeDesc = text('defeatDescription');
    } else {
      outcomeTitle = 'Tie Game!';
      outcomeDesc = 'Both players finished with equal hearts.';
    }

    final myFrameId = widget.progress.selectedAvatarFrameId;
    final myFrameColor = getFrameColor(myFrameId);
    final oppFrameColor = getFrameColor(opponentAvatarFrameId);

    return Scaffold(
      body: StellaGradientScaffold(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWinner ? Icons.emoji_events : (isLoser ? Icons.sentiment_dissatisfied : Icons.balance),
                  color: const Color(0xFFFFD98A),
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  outcomeTitle,
                  style: const TextStyle(color: Color(0xFFFFD98A), fontSize: 28, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                ),
                const SizedBox(height: 8),
                Text(
                  outcomeDesc,
                  style: const TextStyle(color: Colors.white70, fontSize: 15, decoration: TextDecoration.none),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10243B),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0x223A5B80)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: myFrameColor, width: myFrameId == 'none' ? 0 : 3),
                                ),
                                child: const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xFF071426),
                                  child: Icon(Icons.person, color: Color(0xFFFFD98A), size: 30),
                                ),
                              ),
                              if (myFrameId == 'crown')
                                const Positioned(top: -8, right: -4, child: Text('👑', style: TextStyle(fontSize: 18))),
                              if (isWinner)
                                const Positioned(bottom: -4, right: -4, child: Icon(Icons.workspace_premium, color: Color(0xFFFFD98A), size: 22)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(widget.playerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Color(0xFFFF6B6B), size: 14),
                              const SizedBox(width: 4),
                              Text('$lives hearts', style: const TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.none)),
                            ],
                          ),
                        ],
                      ),

                      const Text('VS', style: TextStyle(color: Color(0xFFFFD98A), fontWeight: FontWeight.w900, fontSize: 20, decoration: TextDecoration.none)),

                      Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: oppFrameColor, width: opponentAvatarFrameId == 'none' ? 0 : 3),
                                ),
                                child: const CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Color(0xFF071426),
                                  child: Icon(Icons.sports_esports, color: Color(0xFFFFD98A), size: 30),
                                ),
                              ),
                              if (opponentAvatarFrameId == 'crown')
                                const Positioned(top: -8, right: -4, child: Text('👑', style: TextStyle(fontSize: 18))),
                              if (isLoser && lives < opponentLives)
                                const Positioned(bottom: -4, right: -4, child: Icon(Icons.workspace_premium, color: Color(0xFFFFD98A), size: 22)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(opponentName, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
                              const SizedBox(width: 4),
                              Text('$opponentLives hearts', style: const TextStyle(color: Colors.white70, fontSize: 12, decoration: TextDecoration.none)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD98A),
                      foregroundColor: const Color(0xFF071426),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(text('backToMenu'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}