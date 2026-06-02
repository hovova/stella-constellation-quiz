import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF071426),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Choose Your Upgrade',
                      style: TextStyle(
                        color: Color(0xFFFFD98A),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Compare No Ads and Premium. Purchases will be connected later through Google Play Billing.',
                style: TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              const _UpgradeCard(
                title: 'No Ads',
                price: '£1.99 / \$2.49 / ₴49',
                icon: Icons.block,
                features: [
                  'Removes interstitial ads after quizzes',
                  'Cleaner quiz experience',
                  'Keeps free campaign access',
                ],
                missingFeatures: [
                  'Offline quizzes',
                  'Premium avatars and themes',
                  'Advanced challenge modes',
                ],
              ),

              const SizedBox(height: 18),

              const _UpgradeCard(
                title: 'Premium',
                price: '£2.99 / \$4.49 / ₴99',
                icon: Icons.workspace_premium,
                highlighted: true,
                features: [
                  'Removes all ads',
                  'Offline quiz packs',
                  'Premium avatars',
                  'Premium themes',
                  'All 88 constellations challenge',
                  'Advanced quiz modes',
                  'Extra achievement badges',
                  'Detailed statistics',
                  'Early access to new learning modes',
                ],
                missingFeatures: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final String title;
  final String price;
  final IconData icon;
  final bool highlighted;
  final List<String> features;
  final List<String> missingFeatures;

  const _UpgradeCard({
    required this.title,
    required this.price,
    required this.icon,
    this.highlighted = false,
    required this.features,
    required this.missingFeatures,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlighted ? const Color(0xFF132B46) : const Color(0xFF10243B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: highlighted
              ? const Color(0xFFFFD98A)
              : const Color(0x223A5B80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlighted)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD98A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: Color(0xFF071426),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFFFD98A),
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFFFD98A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...features.map(
              (feature) => _FeatureRow(
                text: feature,
                enabled: true,
              ),
            ),

            ...missingFeatures.map(
              (feature) => _FeatureRow(
                text: feature,
                enabled: false,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: null,
                child: Text(
                  highlighted ? 'Unlock Premium Soon' : 'Remove Ads Soon',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  final bool enabled;

  const _FeatureRow({
    required this.text,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? const Color(0xFF58D68D) : Colors.white30,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: enabled ? Colors.white70 : Colors.white30,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}