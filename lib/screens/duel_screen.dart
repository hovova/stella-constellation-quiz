import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../data/app_text.dart';
import '../models/player_progress.dart';
import '../services/bot_service.dart';
import '../services/multiplayer_service.dart';
import 'duel_game_screen.dart';
import 'home_screen.dart';

class DuelScreen extends StatefulWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress)? onProgressUpdated;

  const DuelScreen({
    super.key,
    required this.progress,
    this.onProgressUpdated,
  });

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  StreamSubscription? _roomSubscription;

  String text(String key) {
    return AppText.get(widget.progress.selectedLanguageCode, key);
  }

  void _listenToRoom(String roomCode, StateSetter dialogSetState) {
    _roomSubscription?.cancel();
    _roomSubscription = StellaMultiplayerService.streamDuelState(roomCode).listen((event) {
      if (!event.snapshot.exists) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final status = data['status'] as String? ?? 'waiting';

      if (status == 'playing') {
        _roomSubscription?.cancel();
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DuelGameScreen(
                roomCode: roomCode,
                progress: widget.progress,
                playerName: widget.progress.playerName,
                onProgressUpdated: widget.onProgressUpdated,
              ),
            ),
          );
        }
      }
    });
  }

  void _showSearchingDialog(String title, String subtitle, String roomCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            _listenToRoom(roomCode, dialogSetState);
            return _MatchmakingDialog(
              title: title,
              subtitle: subtitle,
              roomCode: roomCode,
              cancelText: text('cancel'),
              onCancel: () async {
                _roomSubscription?.cancel();
                StellaBotService.cancelTimer();
                
                try {
                  final ref = FirebaseDatabase.instanceFor(
                    app: Firebase.app(),
                    databaseURL: 'https://com-mriyainteractive-stella-default-rtdb.europe-west1.firebasedatabase.app',
                  ).ref('duels/$roomCode');
                  
                  final snap = await ref.get();
                  if (snap.exists) {
                    final data = Map<String, dynamic>.from(snap.value as Map);
                    if (data['status'] == 'waiting') {
                      await ref.remove();
                    }
                  }
                } catch (_) {}

                if (mounted) {
                  Navigator.pop(dialogContext);
                }
              },
            );
          },
        );
      },
    );
  }

  void _handlePlayWithBot() async {
    try {
      final roomCode = await StellaMultiplayerService.createDuelRoom(widget.progress.playerName);
      await StellaBotService.joinBotInstantly(roomCode);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuelGameScreen(
              roomCode: roomCode,
              progress: widget.progress,
              playerName: widget.progress.playerName,
              onProgressUpdated: widget.onProgressUpdated,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleFindRandomOpponent() async {
    try {
      final roomCode = await StellaMultiplayerService.findOrCreateRandomRoom(widget.progress.playerName);
      
      if (mounted) {
        _showSearchingDialog(
          text('findingOpponent'),
          text('searchingChallenger'),
          roomCode,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleCreateFriendRoom() async {
    try {
      final roomCode = await StellaMultiplayerService.createDuelRoom(widget.progress.playerName);

      if (mounted) {
        _showSearchingDialog(
          text('friendRoomCreated'),
          text('shareRoomCode'),
          roomCode,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handleJoinRoom() {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF10243B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0x333A5B80)),
          ),
          title: Text(
            text('joinWithCode'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: codeController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: text('enterRoomCode'),
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0x333A5B80)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFD98A)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(text('cancel'), style: const TextStyle(color: Colors.white60)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD98A),
                foregroundColor: const Color(0xFF071426),
              ),
              onPressed: () async {
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  final success = await StellaMultiplayerService.joinDuelRoom(
                    code,
                    widget.progress.playerName,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);

                    if (success) {
                      StellaBotService.cancelTimer();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DuelGameScreen(
                            roomCode: code,
                            progress: widget.progress,
                            playerName: widget.progress.playerName,
                            onProgressUpdated: widget.onProgressUpdated,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(text('roomNotFound'))),
                      );
                    }
                  }
                }
              },
              child: Text(text('join'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StellaGradientScaffold(
        child: SafeArea(
          child: SizedBox.expand(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text('duelTitle'),
                    style: const TextStyle(
                      color: Color(0xFFFFD98A),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text('duelDescription'),
                    style: const TextStyle(
                      color: Colors.white60,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: const Color(0xFF10243B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0x333A5B80)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.sports_esports, color: Color(0xFFFFD98A), size: 32),
                          const SizedBox(height: 14),
                          Text(
                            text('arenaTitle'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            text('arenaDescription'),
                            style: const TextStyle(
                              color: Colors.white60,
                              height: 1.4,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1F7A4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _handlePlayWithBot,
                      child: Text(
                        text('playWithBot'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD98A),
                        foregroundColor: const Color(0xFF071426),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _handleFindRandomOpponent,
                      child: Text(
                        text('findRandomOpponent'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD98A)),
                        foregroundColor: const Color(0xFFFFD98A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _handleCreateFriendRoom,
                      child: Text(
                        text('createFriendRoom'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0x333A5B80)),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _handleJoinRoom,
                      child: Text(
                        text('joinWithCode'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchmakingDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String roomCode;
  final String cancelText;
  final VoidCallback onCancel;

  const _MatchmakingDialog({
    required this.title,
    required this.subtitle,
    required this.roomCode,
    required this.cancelText,
    required this.onCancel,
  });

  @override
  State<_MatchmakingDialog> createState() => _MatchmakingDialogState();
}

class _MatchmakingDialogState extends State<_MatchmakingDialog> {
  int _iconIndex = 0;
  late Timer _animationTimer;

  final List<IconData> _searchIcons = [
    Icons.person_search,
    Icons.radar,
    Icons.public,
    Icons.sports_esports,
  ];

  @override
  void initState() {
    super.initState();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (mounted) {
        setState(() {
          _iconIndex = (_iconIndex + 1) % _searchIcons.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF10243B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0x333A5B80)),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Icon(
                _searchIcons[_iconIndex],
                key: ValueKey<int>(_iconIndex),
                color: const Color(0xFFFFD98A),
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF071426),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x333A5B80)),
              ),
              child: SelectableText(
                widget.roomCode,
                style: const TextStyle(
                  color: Color(0xFFFFD98A),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD98A)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: widget.onCancel,
              child: Text(
                widget.cancelText,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}