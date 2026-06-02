import 'package:flutter/material.dart';

import '../screens/premium_screen.dart';

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key});

  void openPremiumMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PremiumScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openPremiumMenu(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF10243B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0x55FFD98A),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block,
              color: Color(0xFFFFD98A),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'No Ads',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '/',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD98A),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Premium',
              style: TextStyle(
                color: Color(0xFFFFD98A),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}