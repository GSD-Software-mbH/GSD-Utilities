part of '../gsd_utilities.dart';

/// Konfigurationsmanager-Implementierung für Mobile- und Desktop-Plattformen.
/// Verwendet SharedPreferences (NSUserDefaults/SharedPreferences) für öffentliche Daten
/// und FlutterSecureStorage (Keychain) nur für sensible Daten (Passwörter, Tokens).
class _GSDAppConfigManager extends GSDConfigManager {
  /// FlutterSecureStorage für sensible Daten (Passwörter, Tokens, Keys).
  /// Nur kleine Datenmengen — zuverlässig und stabil.
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
    aOptions: AndroidOptions(),
  );

  /// Legacy-Instanz für einmalige Migration vom alten Keychain-only Ansatz.
  final FlutterSecureStorage _legacySecureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
    aOptions: AndroidOptions(),
  );

  /// Legacy-Instanz für Migration von first_unlock_this_device.
  final FlutterSecureStorage _legacyThisDeviceStorage =
      const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    aOptions: AndroidOptions(),
  );

  /// SharedPreferences für öffentliche Konfigurationsdaten.
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  /// Speicherschlüssel zur Identifizierung der Konfigurationsdaten
  late String _key;

  /// Schlüssel für die sensiblen Daten im Keychain
  String get _secureKey => '${_key}_secure';

  _GSDAppConfigManager(String key, {super.backgroundMode}) : super._() {
    _key = key;
  }

  @override
  Future<GSDConfigResult<T>> loadConfig<T extends GSDBaseConfig>(
      T configTemplate) async {
    String log = "============Load Config============\n";
    bool success = false;
    Exception? error;
    T? config;

    try {
      log += "Storage Key: $_key\n";

      String? configFileContent;

      // Step 1: Try SharedPreferences (primary storage for public data)
      try {
        configFileContent = await _prefs.getString(_key);
        if (configFileContent != null) {
          log += "Config read from SharedPreferences\n";
        } else {
          log += "SharedPreferences returned null\n";
        }
      } catch (e) {
        log += "SharedPreferences error: $e\n";
      }

      // Step 2: Migration from legacy Keychain-only storage
      if (configFileContent == null) {
        try {
          // Try first_unlock
          configFileContent = await _legacySecureStorage.read(key: _key);
          // Try first_unlock_this_device
          configFileContent ??= await _legacyThisDeviceStorage.read(key: _key);

          if (configFileContent != null) {
            log += "Config migrated from legacy secure storage\n";
            // Migrate to SharedPreferences
            try {
              await _prefs.setString(_key, configFileContent);
              // Clean up legacy keychain entries
              await _legacySecureStorage.delete(key: _key);
              await _legacyThisDeviceStorage.delete(key: _key);
              log += "Migration to SharedPreferences completed\n";
            } catch (e) {
              log += "Migration write failed: $e\n";
            }
          } else {
            log += "No legacy config found\n";
          }
        } catch (e) {
          log += "Legacy storage error: $e\n";
        }
      }

      if (configFileContent != null && configFileContent.isNotEmpty) {
        log += "Load Config from storage\n";
        config = configTemplate.createInstance() as T;
        config.loadFromJson(configFileContent);

        // Load secure data (passwords, tokens) from Keychain
        if (!backgroundMode) {
          try {
            String? secureContent = await _secureStorage.read(key: _secureKey);
            if (secureContent != null && secureContent.isNotEmpty) {
              config.loadSecureJson(secureContent);
              log += "Secure data loaded from Keychain\n";
            } else {
              log += "No secure data in Keychain\n";
            }
          } catch (e) {
            log += "Secure data load error: $e\n";
          }
        } else {
          log += "Background mode: skipping secure data load\n";
        }

        log += "Config loaded\n";
        success = true;
      } else {
        log += "No config found in any storage\n";
      }
    } catch (e) {
      error = Exception(e.toString());
      log += "Exception: $error\n";
    }
    log += "==============================\n";

    config?.configChangedEvent.subscribe(configChangedEvent);

    return GSDConfigResult<T>(
        isSuccess: success, log: log, error: error, config: config);
  }

  @override
  Future<GSDConfigResult<T>> saveConfig<T extends GSDBaseConfig>(
      T config) async {
    await _savePlatformConfig(config);
    return loadConfig(config);
  }

  @override
  Future<void> configChangedEvent(EventArgs? args) async {
    try {
      if (args is GSDConfigChangedEventArgs) {
        await _savePlatformConfig(args.config);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _savePlatformConfig(GSDBaseConfig config) async {
    // Save public data to SharedPreferences
    await _prefs.setString(_key, config.toJson());

    // Save secrets to Keychain (skip in background mode to prevent overwriting with empty data)
    if (!backgroundMode) {
      String secureJson = config.toSecureJson();
      if (secureJson != "{}") {
        await _secureStorage.write(key: _secureKey, value: secureJson);
      }
    }
  }
}
