import 'package:flutter/material.dart';
import 'home_screen.dart';

class ConstellationsScreen extends StatelessWidget {
  const ConstellationsScreen({super.key});

  final List<String> constellations = const [
    'Orion',
    'Ursa Major',
    'Ursa Minor',
    'Cassiopeia',
    'Scorpius',
    'Leo',
    'Cygnus',
    'Lyra',
    'Taurus',
    'Gemini',
  ];

  @override
  Widget build(BuildContext context) {
    return StellaGradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Constellations',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD98A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse the constellation encyclopedia. Full details will be added soon.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: 'Search constellations',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF10243B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: constellations.length,
                itemBuilder: (context, index) {
                  final constellation = constellations[index];

                  return Card(
                    color: const Color(0xFF10243B),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFFFD98A),
                      ),
                      title: Text(
                        constellation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Tap to view details soon',
                        style: TextStyle(color: Colors.white38),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white38,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}