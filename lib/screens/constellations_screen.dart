import 'package:flutter/material.dart';

import '../data/constellation_data.dart';
import '../models/constellation.dart';
import 'constellation_detail_screen.dart';
import 'home_screen.dart';

class ConstellationsScreen extends StatefulWidget {
  const ConstellationsScreen({super.key});

  @override
  State<ConstellationsScreen> createState() => _ConstellationsScreenState();
}

class _ConstellationsScreenState extends State<ConstellationsScreen> {
  String searchQuery = '';

  List<Constellation> get filteredConstellations {
    return allConstellations.where((constellation) {
      return constellation.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
    }).toList();
  }

  void openConstellation(Constellation constellation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConstellationDetailScreen(
          constellation: constellation,
        ),
      ),
    );
  }

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
              'Browse the constellation encyclopedia and learn the stories behind the night sky.',
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
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
                itemCount: filteredConstellations.length,
                itemBuilder: (context, index) {
                  final constellation = filteredConstellations[index];

                  return Card(
                    color: const Color(0xFF10243B),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      onTap: () => openConstellation(constellation),
                      leading: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFFFD98A),
                      ),
                      title: Text(
                        constellation.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${constellation.difficulty} • ${constellation.bestSeason}',
                        style: const TextStyle(color: Colors.white38),
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