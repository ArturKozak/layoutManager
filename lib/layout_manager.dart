import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LayoutManager {
  static const firebaseKey = 'firebaseKey';
  static const firebaseRemoteKey = 'firebaseRemoteKey';
  static const parseKey = 'parseKey';
  static const parseRemoteKey = 'parseRemoteKey';
  static const parseFunctionKey = 'parseFunctionKey';

  const LayoutManager();

  static Future<void> initPlugin({
    bool firebaseEnabled = false,
    bool firebaseRemoteEnabled = false,
    bool parseEnabled = false,
    bool parseRemoteEnabled = false,
    bool parseFunctionEnabled = false,
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

    print('set configuraton');

    if (firebaseEnabled) {
      await Firebase.initializeApp();

      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.fetch();
      print('firebase init');
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
    }

    return;
  }

  static Future<String?> getValueFromParseRemoteConfig(String key) async {
    print('start remote parse');

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(parseKey) == null || prefs.getBool(parseKey)! == false) {
      return null;
    }

    if (prefs.getBool(parseRemoteKey) == null ||
        prefs.getBool(parseRemoteKey)! == false) {
      print(' remote parse empty');

      return null;
    }

    try {
      final values = await ParseConfig().getConfigs();

      final instance = values.result as Map<String, dynamic>;

      return instance[key];
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<String?> getValueFromParseCloudFunction(
      String functionName, String key) async {
    if (functionName.isEmpty) {
      return null;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(parseKey) == null || prefs.getBool(parseKey)! == false) {
      return null;
    }

    if (prefs.getBool(parseFunctionKey) == null ||
        prefs.getBool(parseFunctionKey)! == false) {
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

  static Future<String?> getValueFromFirebaseRemoteConfig(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(firebaseKey) == null ||
        prefs.getBool(firebaseKey)! == false) {
      return null;
    }

    if (prefs.getBool(firebaseRemoteKey) == null ||
        prefs.getBool(firebaseRemoteKey)! == false) {
      return null;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      print('start remote firebase');

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.fetchAndActivate();

      return remoteConfig.getString(key);
    } on Exception catch (_) {
      return null;
    }
  }

  static Future<String?> configurateLayout(
    String? functionName,
    String uuid,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(parseKey) != null && prefs.getBool(parseKey)! == true) {
      print('parse enabled');

      if (prefs.getBool(parseFunctionKey) != null &&
          prefs.getBool(parseFunctionKey)! == true) {
        print('parse cloud function enabled');

        return getValueFromParseCloudFunction(functionName ?? '', uuid);
      }

      if (prefs.getBool(parseRemoteKey) != null &&
          prefs.getBool(parseRemoteKey)! == true) {
        print('parse remote enabled');

        return getValueFromParseRemoteConfig(uuid);
      }
    }

    if (prefs.getBool(firebaseKey) != null &&
        prefs.getBool(firebaseKey)! == true) {
      print('firebase enabled');

      if (prefs.getBool(firebaseRemoteKey) != null &&
          prefs.getBool(firebaseRemoteKey)! == true) {
        print('firebase remote enabled');

        return getValueFromFirebaseRemoteConfig(uuid);
      }
    }

    return null;
  }
}
