// ignore_for_file: use_build_context_synchronously, unused_local_variable
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:layout_manager/notification_service.dart';
import 'package:layout_manager/in_app_purchase.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';

class LayoutManager {
  static const firebaseKey = 'firebaseKey';
  static const firebaseRemoteKey = 'firebaseRemoteKey';
  static const parseKey = 'parseKey';
  static const parseRemoteKey = 'parseRemoteKey';
  static const integrationKey = 'integrationKey';
  static const limitedKey = 'limitedKey';
  static const notificationTitleKey = 'notificationTitleKey';
  static const notificationBodyKey = 'notificationBodyKey';
  static const notificationIntervalKey = 'notificationIntervalKey';
  static const notificationEnabledKey = 'notificationEnabledKey';

  LayoutManager._internal();

  static final LayoutManager instance = LayoutManager._internal();

  PaymentService paymentService = PaymentService.instance;
  NotificationHelper notificationHelper = NotificationHelper.instance;

  Future<String?> _getByKey(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_and(prefs, parseKey)) {
      if (_and(prefs, parseRemoteKey)) {
        return getValueFromParseRemoteConfig(
          key,
          prefs,
        );
      }
    }

    if (_and(prefs, firebaseKey)) {
      if (_and(prefs, firebaseRemoteKey)) {
        return getValueFromFirebaseRemoteConfig(
          prefs,
          key,
        );
      }
    }

    return null;
  }

  bool _or(SharedPreferences prefs, String key) {
    return prefs.getBool(key) == null || prefs.getBool(key)! == false;
  }

  bool _and(SharedPreferences prefs, String key) {
    return prefs.getBool(key) != null && prefs.getBool(key)! != false;
  }

  bool _isStringOnlyLetters(String str) {
    return str.trim().isNotEmpty &&
        str.split('').every((char) => RegExp(r'^[a-zA-Z]+$').hasMatch(char));
  }

  Future<void> _initLocalNotificationIfNeeeded() async {
    final notificationEnabled = await _getByKey(notificationEnabledKey);
    final notificationTitle = await _getByKey(notificationTitleKey);
    final notificationBody = await _getByKey(notificationBodyKey);
    final notificationIntervalRaw = await _getByKey(notificationIntervalKey);

    RepeatInterval notificationInterval = RepeatInterval.daily;

    switch (notificationIntervalRaw) {
      case 'minute':
        notificationInterval = RepeatInterval.everyMinute;

        break;
      case 'day':
        notificationInterval = RepeatInterval.daily;

        break;
      case 'week':
        notificationInterval = RepeatInterval.weekly;

        break;
    }

    if (notificationEnabled != null && notificationEnabled == 'true') {
      await notificationHelper.initializeNotification();

      if (notificationTitle != null &&
          notificationTitle.isNotEmpty &&
          notificationBody != null &&
          notificationBody.isNotEmpty &&
          notificationIntervalRaw != null &&
          notificationIntervalRaw.isNotEmpty) {
        await notificationHelper.scheduledNotification(
            notificationTitle: notificationTitle,
            notificationBody: notificationBody,
            interval: notificationInterval);
      }
    }
  }

  Future<void> _getDataFromParse(
      bool parseEnabled,
      String? parseAppId,
      String? parseServerUrl,
      String? parseClientKey,
      SharedPreferences prefs) async {
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

      await prefs.setString(
        limitedKey,
        instance[instance.keys.where((element) {
          return _isStringOnlyLetters(element) &&
              !element.contains('notification');
        }).first],
      );

      for (var key in instance.keys) {
        if (key.startsWith('_')) {
          await prefs.setString(
            integrationKey,
            instance[key],
          );
        }

        if (key.contains('notificationTitle')) {
          final value = instance[key];

          await prefs.setString(notificationTitleKey, value);
        }

        if (key.contains('notificationBody')) {
          final value = instance[key];

          await prefs.setString(notificationBodyKey, value);
        }

        if (key.contains('notificationInterval')) {
          final value = instance[key];

          await prefs.setString(notificationIntervalKey, value);
        }

        if (key.contains('notificationEnabled')) {
          final value = instance[key];

          await prefs.setString(notificationEnabledKey, value);
        }
      }
    }
  }

  Future<void> _getDataFromFB(
      bool firebaseEnabled, SharedPreferences prefs) async {
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

      if (remoteConfig.getAll().isNotEmpty &&
          remoteConfig.getAll().keys.isNotEmpty &&
          remoteConfig.getAll().values.isNotEmpty) {
        await prefs.setString(
          limitedKey,
          remoteConfig.getString(
            remoteConfig.getAll().keys.firstWhere(
                  (element) =>
                      _isStringOnlyLetters(element) &&
                      !element.contains('notification'),
                  orElse: () => '',
                ),
          ),
        );

        for (final key in remoteConfig.getAll().keys) {
          if (key.startsWith('_')) {
            final value = remoteConfig.getString(key);

            await prefs.setString(integrationKey, value);
          }

          if (key.contains('notificationTitle')) {
            final value = remoteConfig.getString(key);

            await prefs.setString(notificationTitleKey, value);
          }

          if (key.contains('notificationBody')) {
            final value = remoteConfig.getString(key);

            await prefs.setString(notificationBodyKey, value);
          }

          if (key.contains('notificationInterval')) {
            final value = remoteConfig.getString(key);

            await prefs.setString(notificationIntervalKey, value);
          }

          if (key.contains('notificationEnabled')) {
            final value = remoteConfig.getString(key);

            await prefs.setString(notificationEnabledKey, value);
          }
        }
      }
    }
  }

  Future<void> initPlugin({
    bool firebaseEnabled = false,
    bool firebaseRemoteEnabled = false,
    bool parseEnabled = false,
    bool parseRemoteEnabled = false,
    bool appsFlyerEnabled = false,
    bool isPurchaseEnabled = false,
    String? afDevKey,
    List<String>? productsList,
    String? parseAppId,
    String? parseServerUrl,
    String? parseClientKey,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(firebaseKey, firebaseEnabled);
    await prefs.setBool(firebaseRemoteKey, firebaseRemoteEnabled);
    await prefs.setBool(parseKey, parseEnabled);
    await prefs.setBool(parseRemoteKey, parseRemoteEnabled);

    await _getDataFromFB(
      firebaseEnabled,
      prefs,
    );

    await _getDataFromParse(
      parseEnabled,
      parseAppId,
      parseServerUrl,
      parseClientKey,
      prefs,
    );

    if (isPurchaseEnabled && productsList != null && productsList.isNotEmpty) {
      await paymentService.initConnection(productsList);
    }

    await _initLocalNotificationIfNeeeded();

    return;
  }

  Future<String?> getValueFromParseRemoteConfig(
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

  Future<String?> getValueFromFirebaseRemoteConfig(
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

  Future<String?> configurateLayout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_and(prefs, parseKey)) {
      if (_and(prefs, parseRemoteKey)) {
        return getValueFromParseRemoteConfig(
          integrationKey,
          prefs,
        );
      }
    }

    if (_and(prefs, firebaseKey)) {
      if (_and(prefs, firebaseRemoteKey)) {
        return getValueFromFirebaseRemoteConfig(
          prefs,
          integrationKey,
        );
      }
    }

    return null;
  }

  Future<bool> getLayoutLimiter(
    String url,
  ) async {
    final currentUrl = url;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_and(prefs, parseKey)) {
      if (_and(prefs, parseRemoteKey)) {
        final value = await getValueFromParseRemoteConfig(
          limitedKey,
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
          limitedKey,
        );

        if (value == null) {
          return false;
        }

        return currentUrl.contains(value);
      }
    }

    return false;
  }

  Future<void> loadDialog({
    required BuildContext context,
    required Widget dialog,
    required String? bundleId,
  }) async {
    bool statusLoad = false;
    final fetchData = await LayoutManager.instance.configurateLayout();

    if (fetchData != null) {
      final webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(fetchData))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => Future.delayed(
              const Duration(seconds: 2),
            ),
            onPageFinished: (String url) async {
              final status = await LayoutManager.instance.getLayoutLimiter(
                url,
              );

              statusLoad = status;
            },
          ),
        );

      if (!statusLoad) {
        return showDialog(
          context: context,
          builder: (context) => dialog,
        );
      }

      return;
    }

    return;
  }

  Future<Map<String, RemoteConfigValue>> getRemoteFB() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await remoteConfig.fetch();

    await remoteConfig.fetchAndActivate();

    return remoteConfig.getAll();
  }
}
