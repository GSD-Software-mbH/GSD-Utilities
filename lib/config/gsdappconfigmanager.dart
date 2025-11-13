part of '../gsd_utilities.dart';

/// Konfigurationsmanager-Implementierung für Mobile- und Desktop-Plattformen.
/// Verwendet FlutterSecureStorage für sichere Konfigurationspersistierung.
/// Behandelt automatisch Ver- und Entschlüsselung von Konfigurationsdaten.
class _GSDAppConfigManager implements GSDConfigManager {
  /// FlutterSecureStorage-Instanz für sichere Datenpersistierung mit iOS-optimierten Einstellungen
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Fallback-Instanz mit relaxteren iOS-Einstellungen für Fehlerbehandlung
  final FlutterSecureStorage _fallbackSecureStorage =
      const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked,
      synchronizable: false,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Speicherschlüssel zur Identifizierung der Konfigurationsdaten
  late String _key;

  /// Konstruktor, der den Speicherschlüssel initialisiert
  ///
  /// [key] Der eindeutige Bezeichner für die Konfigurationsdaten im sicheren Speicher
  _GSDAppConfigManager(String key) {
    _key = key;
  }

  /// Lädt Konfiguration aus sicherem Speicher und deserialisiert sie
  ///
  /// [configTemplate] Template-Instanz zur Erstellung des tatsächlichen Konfigurationsobjekts
  ///
  /// Gibt ein [GSDConfigResult] zurück mit:
  /// - Geladener Konfiguration (bei Erfolg)
  /// - Erfolgsstatus und detaillierten Logs
  /// - Fehlerinformationen bei Ladefehlern
  @override
  Future<GSDConfigResult<T>> loadConfig<T extends GSDBaseConfig>(
      T configTemplate) async {
    String log = "============Load Config============\n";
    bool success = false;
    Exception? error;
    T? config;

    try {
      log += "Secure Storage Key: $_key\n";

      String? configFileContent;
      int attempts = 0;
      const maxAttempts = 3;

      while (attempts < maxAttempts && configFileContent == null) {
        attempts++;
        try {
          configFileContent = await _secureStorage.read(key: _key);
          if (configFileContent != null) break;
        } catch (e) {
          log += "Attempt $attempts failed: $e\n";

          log += "iOS Security Error detected - trying fallback storage\n";
          try {
            configFileContent = await _fallbackSecureStorage.read(key: _key);
            if (configFileContent != null) {
              log += "Fallback storage successful\n";
              break;
            }
          } catch (fallbackError) {
            log += "Fallback storage also failed: $fallbackError\n";
          }

          if (attempts == maxAttempts) {
            rethrow;
          }

          // Exponential backoff für wiederholte Versuche
          await Future.delayed(Duration(milliseconds: 100 * attempts));
        }
      }

      if (configFileContent != null && configFileContent.isNotEmpty) {
        log += "Load Config from Secure Storage\n";
        config = configTemplate.createInstance() as T;
        config.loadFromJson(configFileContent);
        log += "Config loaded\n";
        success = true;
      } else {
        log += "No config found in secure storage\n";
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

  /// Event-Handler, der automatisch Konfigurationsänderungen im sicheren Speicher speichert
  ///
  /// [args] Event-Argumente mit der geänderten Konfiguration
  /// Wirft eine Exception, wenn das Speichern fehlschlägt
  @override
  Future<void> configChangedEvent(EventArgs? args) async {
    try {
      if (args is GSDConfigChangedEventArgs) {
        _savePlatformConfig(args.config);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _savePlatformConfig(GSDBaseConfig config) async {
    try {
      await _secureStorage.write(key: _key, value: config.toJson());
    } catch (e) {
      // Fallback auf relaxerte iOS-Einstellungen
      try {
        await _fallbackSecureStorage.write(key: _key, value: config.toJson());
      } catch (fallbackError) {
        rethrow;
      }
    }
  }
}
