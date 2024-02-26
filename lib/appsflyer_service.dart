import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class AppsFlyerService {
  AppsFlyerService._internal();

  static final AppsFlyerService instance = AppsFlyerService._internal();

  AppsflyerSdk? appsflyerSdk;

  Future<void> appsFlyerEvent({required String eventName, Map? eventValues}) {
    return appsflyerSdk!.logEvent(eventName, eventValues);
  }

  bool isActive() {
    return appsflyerSdk == null;
  }

  Future<void> initAppsFlyer({
    required String afDevKey,
  }) async {
    final appsFlyerOptions = AppsFlyerOptions(
      afDevKey: afDevKey,
    );

    appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    appsflyerSdk!.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true);
  }
}
