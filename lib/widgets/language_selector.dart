import 'package:flutter/material.dart';

import '../data/languages.dart';
import '../models/player_progress.dart';

class LanguageSelector extends StatelessWidget {
  final PlayerProgress progress;
  final void Function(PlayerProgress updatedProgress) onProgressUpdated;

  const LanguageSelector({
    super.key,
    required this.progress,
    required this.onProgressUpdated,
  });

  void openLanguageMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF071426),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Language',
                  style: TextStyle(
                    color: Color(0xFFFFD98A),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ...appLanguages.map((language) {
                  final selected =
                      language.code == progress.selectedLanguageCode;

                  return Card(
                    color: selected
                        ? const Color(0xFF132B46)
                        : const Color(0xFF10243B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFFFFD98A)
                            : const Color(0x223A5B80),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        final updatedProgress = progress.copyWith(
                          selectedLanguageCode: language.code,
                        );

                        onProgressUpdated(updatedProgress);
                        Navigator.pop(context);
                      },
                      leading: Text(
                        language.flag,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        language.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFFFFD98A),
                            )
                          : null,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = findLanguageByCode(progress.selectedLanguageCode);

    return InkWell(
      onTap: () => openLanguageMenu(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF10243B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0x223A5B80),
          ),
        ),
        child: Text(
          language.flag,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}