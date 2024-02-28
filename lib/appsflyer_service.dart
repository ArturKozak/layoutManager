import 'dart:convert';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:dio/dio.dart';

class AppsFlyerService {
  AppsFlyerService._internal();

  static final AppsFlyerService instance = AppsFlyerService._internal();

  AppsflyerSdk? appsflyerSdk;

  Future<void> appsFlyerEvent(
      {required String bundleId, required String eventName}) async {
    if (Platform.isAndroid) {
      final uid = await appsflyerSdk!.getAppsFlyerUID();

      var dio = Dio();
      var response = await dio.request(
        'http://209.38.214.119/postback?uid=$uid&bundle_id=$bundleId&event=$eventName',
        options: Options(
          method: 'POST',
        ),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
      } else {
        print(response.statusMessage);
      }
    }
  }

  bool isActive() {
    return appsflyerSdk == null;
  }

  Future<void> initAppsFlyer({
    required String afDevKey,
  }) async {
    final appsFlyerOptions = AppsFlyerOptions(
        afDevKey: afDevKey, appId: '' //Add a unique identifier to the client
        );

    appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    appsflyerSdk!.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true);
  }
}
