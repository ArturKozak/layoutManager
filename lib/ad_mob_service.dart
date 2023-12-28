import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  //
  AdMobService._internal();

  static final AdMobService instance = AdMobService._internal();

  late InitializationStatus initAdFuture;

  Future<void> init() async {
    initAdFuture = await MobileAds.instance.initialize();
  }

  Widget showAdsBanner({String? ios, String? android}) {
    final banner = BannerAd(
      adUnitId: ios ?? android ?? '',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: bannerListener,
    )..load();

    return AdWidget(ad: banner);
  }

  final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      ad.dispose();
      print('Ad failed to load: $error');
    },
    onAdOpened: (Ad ad) => print('Ad opened.'),
    onAdClosed: (Ad ad) => print('Ad closed.'),
  );
}
