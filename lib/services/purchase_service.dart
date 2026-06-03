import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/player_progress.dart';

class PurchaseProductIds {
  static const String noAds = 'stella_no_ads';
  static const String premium = 'stella_premium';

  static const Set<String> all = {
    noAds,
    premium,
  };
}

class PurchaseService {
  static final InAppPurchase _iap = InAppPurchase.instance;

  static Stream<List<PurchaseDetails>> get purchaseStream {
    return _iap.purchaseStream;
  }

  static Future<bool> isAvailable() async {
    return _iap.isAvailable();
  }

  static Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails(
      PurchaseProductIds.all,
    );

    final products = response.productDetails.toList();

    products.sort((a, b) {
      if (a.id == PurchaseProductIds.noAds) return -1;
      if (b.id == PurchaseProductIds.noAds) return 1;
      return a.price.compareTo(b.price);
    });

    return products;
  }

  static Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(
      productDetails: product,
    );

    await _iap.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  static Future<void> completePurchaseIfNeeded(
    PurchaseDetails purchase,
  ) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  static PlayerProgress applyPurchaseToProgress({
    required PlayerProgress progress,
    required String productId,
  }) {
    if (productId == PurchaseProductIds.noAds) {
      return progress.copyWith(
        hasNoAds: true,
      );
    }

    if (productId == PurchaseProductIds.premium) {
      return progress.copyWith(
        hasPremium: true,
        hasNoAds: true,
      );
    }

    return progress;
  }
}