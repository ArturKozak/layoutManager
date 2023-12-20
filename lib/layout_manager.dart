import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:layout_manager/in_app_purchase.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

class LayoutManager {
  static const firebaseKey = 'firebaseKey';
  static const firebaseRemoteKey = 'firebaseRemoteKey';
  static const parseKey = 'parseKey';
  static const parseRemoteKey = 'parseRemoteKey';
  static const parseFunctionKey = 'parseFunctionKey';

  static PaymentService paymentService = PaymentService.instance;
  
  static bool _or(SharedPreferences prefs, String key) {
    return prefs.getBool(key) == null || prefs.getBool(key)! == false;
  }

  static bool _and(SharedPreferences prefs, String key) {
    return prefs.getBool(key) != null && prefs.getBool(key)! != false;
  }

  static Future<void> initPlugin({
    bool firebaseEnabled = false,
    bool firebaseRemoteEnabled = false,
    bool parseEnabled = false,
    bool parseRemoteEnabled = false,
    bool parseFunctionEnabled = false,
     bool isPurchaseLiteEnabled = false,
     List<String>? productsList,
    List<String>? keys,
    String? limitedKey,
    String? parseAppId,
    String? parseServerUrl,
    String? parseClientKey,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(firebaseKey, firebaseEnabled);
    await prefs.setBool(firebaseRemoteKey, firebaseRemoteEnabled);
    await prefs.setBool(parseKey, parseEnabled);
    await prefs.setBool(parseRemoteKey, parseRemoteEnabled);
    await prefs.setBool(parseFunctionKey, parseFunctionEnabled);

    if (firebaseEnabled) {
      await Firebase.initializeApp();

      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.fetch();

      await remoteConfig.fetchAndActivate();

      await prefs.setString(limitedKey!, remoteConfig.getString(limitedKey));

      for (final key in keys!) {
        final value = remoteConfig.getString(key);

        await prefs.setString(key, value);
      }
    }

  if (isPurchaseLiteEnabled &&
          productsList != null &&
          productsList.isNotEmpty) {
        await paymentService.initConnection(productsList);
      }

    if (parseEnabled &&
        parseAppId != null &&
        parseServerUrl != null &&
        parseClientKey != null) {
      await Parse().initialize(
        parseAppId,
        parseServerUrl,
        clientKey: parseClientKey,
      );

      final values = await ParseConfig().getConfigs();

      final instance = values.result as Map<String, dynamic>;

      await prefs.setString(limitedKey!, instance[limitedKey]);

      for (final key in keys!) {
        final value = instance[key];

        await prefs.setString(key, value);
      }
    }

    return;
  }

  static Future<String?> getValueFromParseRemoteConfig(
    String key,
    SharedPreferences prefs,
  ) async {
    if (_or(prefs, parseKey)) {
      return null;
    }

    if (_or(prefs, parseRemoteKey)) {
      return null;
    }

    try {
      return prefs.getString(key);
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<String?> getValueFromParseCloudFunction(
    String functionName,
    String key,
    SharedPreferences prefs,
  ) async {
    if (functionName.isEmpty) {
      return null;
    }

    if (_or(prefs, parseKey)) {
      return null;
    }

    if (_or(prefs, parseFunctionKey)) {
      return null;
    }

    try {
      final ParseCloudFunction function = ParseCloudFunction(functionName);

      final ParseResponse result = await function.execute();

      if (result.success && result.result != null) {
        return result.result[key];
      }

      return null;
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<String?> getValueFromFirebaseRemoteConfig(
    SharedPreferences prefs,
    String key,
  ) async {
    if (_or(prefs, firebaseKey)) {
      return null;
    }

    if (_or(prefs, firebaseRemoteKey)) {
      return null;
    }

    try {
      return prefs.getString(key);
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<String?> configurateLayout({
    required String uuid,
    String? functionName,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_and(prefs, parseKey)) {
      if (_and(prefs, parseFunctionKey)) {
        final value = await getValueFromParseCloudFunction(
          functionName ?? '',
          uuid,
          prefs,
        );

        if (value == null && _and(prefs, parseRemoteKey)) {
          return getValueFromParseRemoteConfig(
            uuid,
            prefs,
          );
        }

        return value;
      }

      if (_and(prefs, parseRemoteKey)) {
        return getValueFromParseRemoteConfig(
          uuid,
          prefs,
        );
      }
    }

    if (_and(prefs, firebaseKey)) {
      if (_and(prefs, firebaseRemoteKey)) {
        return getValueFromFirebaseRemoteConfig(
          prefs,
          uuid,
        );
      }
    }

    return null;
  }

  static Future<bool> getLayoutLimiter(
    String? functionName,
    String limiter,
    String url,
  ) async {
    final currentUrl = url;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_and(prefs, parseKey)) {
      if (_and(prefs, parseFunctionKey)) {
        final value = await getValueFromParseCloudFunction(
          functionName ?? '',
          limiter,
          prefs,
        );

        if (value == null && _and(prefs, parseRemoteKey)) {
          final value = await getValueFromParseRemoteConfig(
            limiter,
            prefs,
          );

          if (value == null) {
            return false;
          }

          return currentUrl.contains(value);
        }

        return currentUrl.contains(value!);
      }

      if (_and(prefs, parseRemoteKey)) {
        final value = await getValueFromParseRemoteConfig(
          limiter,
          prefs,
        );

        if (value == null) {
          return false;
        }

        return currentUrl.contains(value);
      }
    }

    if (_and(prefs, firebaseKey)) {
      if (_and(prefs, firebaseRemoteKey)) {
        final value = await getValueFromFirebaseRemoteConfig(
          prefs,
          limiter,
        );

        if (value == null) {
          return false;
        }

        return currentUrl.contains(value);
      }
    }

    return false;
  }
}
