import 'package:flutter/material.dart';

void main() {
  runApp(const StellaApp());
}

class StellaApp extends StatelessWidget {
  const StellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stella',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF071426),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6A84F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const StellaHomePage(),
    );
  }
}

class StellaHomePage extends StatelessWidget {
  const StellaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              const Text(
                'STELLA',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFFFFD98A),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Learn the stars. Master the sky.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  child: Text('Start Campaign'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: null,
                  child: Text('Constellations'),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: null,
                  child: Text('Duel with Friends'),
                ),
              ),

              const Spacer(),

              const Center(
                child: Text(
                  'Mriya Interactive',
                  style: TextStyle(
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}