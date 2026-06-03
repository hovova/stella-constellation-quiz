import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/achievements.dart';
import '../data/app_text.dart';
import '../models/player_progress.dart';
import '../services/audio_service.dart';
import '../services/purchase_service.dart';

class PremiumScreen extends StatefulWidget {
  final String languageCode;
  final PlayerProgress? progress;
  final void Function(PlayerProgress updatedProgress)? onProgressUpdated;

  const PremiumScreen({
    super.key,
    this.languageCode = 'en',
    this.progress,
    this.onProgressUpdated,
  });

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;

  bool storeAvailable = false;
  bool loadingProducts = true;
  bool purchaseInProgress = false;

  List<ProductDetails> products = [];

  String text(String key) {
    return AppText.get(widget.languageCode, key);
  }

  String safeText(String key, String fallback) {
    final value = text(key);
    return value == key ? fallback : value;
  }

  bool get canUseDevButtons {
    return widget.progress != null && widget.onProgressUpdated != null;
  }

  ProductDetails? productById(String id) {
    for (final product in products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    purchaseSubscription = PurchaseService.purchaseStream.listen(
      handlePurchaseUpdates,
      onError: (error) {
        if (!mounted) return;
        showMessage('Purchase error: $error');
      },
    );

    loadStoreProducts();
  }

  @override
  void dispose() {
    purchaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadStoreProducts() async {
    if (kIsWeb) {
      setState(() {
        storeAvailable = false;
        loadingProducts = false;
        products = [];
      });
      return;
    }

    try {
      final available = await PurchaseService.isAvailable();

      if (!mounted) return;

      if (!available) {
        setState(() {
          storeAvailable = false;
          loadingProducts = false;
          products = [];
        });
        return;
      }

      final loadedProducts = await PurchaseService.loadProducts();

      if (!mounted) return;

      setState(() {
        storeAvailable = true;
        loadingProducts = false;
        products = loadedProducts;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        storeAvailable = false;
        loadingProducts = false;
        products = [];
      });

      showMessage('Store error: $error');
    }
  }

  Future<void> handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    if (!canUseDevButtons) {
      return;
    }

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        if (mounted) {
          setState(() {
            purchaseInProgress = true;
          });
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        if (mounted) {
          setState(() {
            purchaseInProgress = false;
          });

          showMessage(
            purchase.error?.message ?? 'Purchase failed',
          );
        }

        await PurchaseService.completePurchaseIfNeeded(purchase);
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final updatedProgress = PurchaseService.applyPurchaseToProgress(
          progress: widget.progress!,
          productId: purchase.productID,
        );

        widget.onProgressUpdated!(updatedProgress);

        if (mounted) {
          setState(() {
            purchaseInProgress = false;
          });

          if (purchase.productID == PurchaseProductIds.premium) {
            showMessage('Premium activated');
          } else if (purchase.productID == PurchaseProductIds.noAds) {
            showMessage('No Ads activated');
          } else {
            showMessage('Purchase restored');
          }
        }

        await PurchaseService.completePurchaseIfNeeded(purchase);
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        if (mounted) {
          setState(() {
            purchaseInProgress = false;
          });
        }

        await PurchaseService.completePurchaseIfNeeded(purchase);
      }
    }
  }

  Future<void> buyProduct(ProductDetails? product) async {
    StellaAudioService.playButtonTap();

    if (product == null || purchaseInProgress) {
      return;
    }

    try {
      setState(() {
        purchaseInProgress = true;
      });

      await PurchaseService.buyProduct(product);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        purchaseInProgress = false;
      });

      showMessage('Purchase error: $error');
    }
  }

  Future<void> restorePurchases() async {
    StellaAudioService.playButtonTap();

    if (kIsWeb || purchaseInProgress) {
      showMessage('Restore purchases is available on Android/iOS builds.');
      return;
    }

    try {
      setState(() {
        purchaseInProgress = true;
      });

      await PurchaseService.restorePurchases();

      if (!mounted) return;

      showMessage('Checking previous purchases...');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        purchaseInProgress = false;
      });

      showMessage('Restore error: $error');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  void giveNoAds(BuildContext context) {
    StellaAudioService.playButtonTap();

    if (!canUseDevButtons) return;

    final updatedProgress = widget.progress!.copyWith(
      hasNoAds: true,
    );

    widget.onProgressUpdated!(updatedProgress);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('DEV: No Ads activated'),
      ),
    );
  }

  void givePremium(BuildContext context) {
    StellaAudioService.playButtonTap();

    if (!canUseDevButtons) return;

    final updatedProgress = widget.progress!.copyWith(
      hasPremium: true,
      hasNoAds: true,
    );

    widget.onProgressUpdated!(updatedProgress);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('DEV: Premium activated'),
      ),
    );
  }

  void addOneLoginDay(BuildContext context) {
    StellaAudioService.playButtonTap();

    if (!canUseDevButtons) return;

    final preparedProgress = widget.progress!.copyWith(
      lastLoginDate: PlayerProgress.yesterdayKey(),
    );

    var updatedProgress = preparedProgress.recordDailyLogin();

    if (updatedProgress.dailyLoginStreak >= 7) {
      if (!updatedProgress.hasAchievement(AchievementIds.sevenDayLogin)) {
        updatedProgress = updatedProgress.unlockAchievement(
          AchievementIds.sevenDayLogin,
        );
      }

      if (!updatedProgress.unlockedAvatarFrameIds.contains('seven_day')) {
        updatedProgress = updatedProgress.unlockAvatarFrame('seven_day');
      }
    }

    widget.onProgressUpdated!(updatedProgress);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'DEV: Login streak is now ${updatedProgress.dailyLoginStreak}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noAdsActive =
        widget.progress?.hasNoAds == true || widget.progress?.hasPremium == true;
    final premiumActive = widget.progress?.hasPremium == true;

    final noAdsProduct = productById(PurchaseProductIds.noAds);
    final premiumProduct = productById(PurchaseProductIds.premium);

    final storeNote = kIsWeb
        ? 'Purchases are available in Android/iOS builds, not Chrome preview.'
        : loadingProducts
            ? 'Loading store products...'
            : storeAvailable
                ? 'Purchases are connected to the store.'
                : 'Store unavailable. Check Play Console products and test account.';

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
                  Expanded(
                    child: Text(
                      text('chooseUpgrade'),
                      style: const TextStyle(
                        color: Color(0xFFFFD98A),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      StellaAudioService.playButtonTap();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                text('premiumDescription'),
                style: const TextStyle(
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                storeNote,
                style: const TextStyle(
                  color: Colors.white38,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 24),

              _UpgradeCard(
                title: text('noAds'),
                price: noAdsProduct?.price ?? '£1.99 / \$2.49 / ₴49',
                icon: Icons.block,
                active: noAdsActive,
                buttonText: noAdsActive
                    ? text('active')
                    : noAdsProduct == null
                        ? safeText('storeUnavailable', 'Store unavailable')
                        : '${safeText('buy', 'Buy')} ${noAdsProduct.price}',
                buttonEnabled:
                    !noAdsActive && noAdsProduct != null && !purchaseInProgress,
                onButtonPressed: () => buyProduct(noAdsProduct),
                features: [
                  text('noAdsFeature1'),
                  text('noAdsFeature2'),
                  text('noAdsFeature3'),
                ],
                missingFeatures: [
                  text('premiumFeature2'),
                  text('premiumFeature3'),
                  text('premiumFeature4'),
                  text('premiumFeature5'),
                  text('premiumFeature6'),
                ],
              ),

              const SizedBox(height: 18),

              _UpgradeCard(
                title: text('premium'),
                price: premiumProduct?.price ?? '£2.99 / \$4.49 / ₴99',
                icon: Icons.workspace_premium,
                highlighted: true,
                active: premiumActive,
                badgeText: text('bestValue'),
                buttonText: premiumActive
                    ? text('active')
                    : premiumProduct == null
                        ? safeText('storeUnavailable', 'Store unavailable')
                        : '${safeText('buy', 'Buy')} ${premiumProduct.price}',
                buttonEnabled:
                    !premiumActive && premiumProduct != null && !purchaseInProgress,
                onButtonPressed: () => buyProduct(premiumProduct),
                features: [
                  text('premiumFeature1'),
                  text('premiumFeature2'),
                  text('premiumFeature3'),
                  text('premiumFeature4'),
                  text('premiumFeature5'),
                  text('premiumFeature6'),
                ],
                missingFeatures: const [],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: purchaseInProgress ? null : restorePurchases,
                  icon: const Icon(Icons.restore),
                  label: Text(
                    safeText('restorePurchases', 'Restore Purchases'),
                  ),
                ),
              ),

              if (purchaseInProgress) ...[
                const SizedBox(height: 14),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],

              if (canUseDevButtons) ...[
                const SizedBox(height: 22),

                Card(
                  color: const Color(0xFF10243B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0x55FFD98A),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Developer Testing',
                          style: TextStyle(
                            color: Color(0xFFFFD98A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Temporary buttons for testing. Remove before public release.',
                          style: TextStyle(
                            color: Colors.white54,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => giveNoAds(context),
                            icon: const Icon(Icons.block),
                            label: const Text('DEV: Give No Ads'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => givePremium(context),
                            icon: const Icon(Icons.workspace_premium),
                            label: const Text('DEV: Give Premium'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => addOneLoginDay(context),
                            icon: const Icon(Icons.calendar_month),
                            label: const Text('DEV: Add 1 Login Day'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
  final bool active;
  final String? badgeText;
  final String buttonText;
  final bool buttonEnabled;
  final VoidCallback onButtonPressed;
  final List<String> features;
  final List<String> missingFeatures;

  const _UpgradeCard({
    required this.title,
    required this.price,
    required this.icon,
    required this.buttonText,
    required this.buttonEnabled,
    required this.onButtonPressed,
    required this.features,
    required this.missingFeatures,
    this.highlighted = false,
    this.active = false,
    this.badgeText,
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
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: StellaAudioService.playButtonTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (highlighted && badgeText != null)
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
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
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
                  if (active)
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF58D68D),
                      size: 24,
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
                  onPressed: buttonEnabled
                      ? () {
                          StellaAudioService.playButtonTap();
                          onButtonPressed();
                        }
                      : null,
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
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