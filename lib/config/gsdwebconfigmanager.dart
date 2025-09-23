part of '../gsd_utilities.dart';

/// Konfigurationsmanager-Implementierung für Web-Plattformen.
/// Verwendet LocalStorage mit AES-Verschlüsselung für Konfigurationspersistierung.
/// Behandelt automatisch Verschlüsselung, Entschlüsselung und Speicherung von Konfigurationsdaten.
class _GSDWebConfigManager implements GSDConfigManager {
  /// LocalStorage-Manager für webbasierte Datenpersistierung
  late GSDLocalStorageManager _localStorageManager;

  /// Verschlüsselungsmanager für die Sicherung von Konfigurationsdaten
  late EncryptionManager _encryptionManager;

  /// Speicherschlüssel zur Identifizierung der Konfigurationsdaten im LocalStorage
  late String _key;

  /// Konstruktor, der Storage- und Verschlüsselungsmanager initialisiert
  ///
  /// [key] Der eindeutige Bezeichner für die Konfigurationsdaten im LocalStorage
  _GSDWebConfigManager(String key) {
    _localStorageManager = GSDLocalStorageManager();
    _encryptionManager = EncryptionManager();
    _key = key;
  }

  /// Lädt Konfiguration aus LocalStorage, entschlüsselt und deserialisiert sie
  ///
  /// [configTemplate] Template-Instanz zur Erstellung des tatsächlichen Konfigurationsobjekts
  ///
  /// Gibt ein [GSDConfigResult] zurück mit:
  /// - Geladener und entschlüsselter Konfiguration (bei Erfolg)
  /// - Erfolgsstatus und detaillierten Logs
  /// - Fehlerinformationen bei Lade- oder Entschlüsselungsfehlern
  @override
  Future<GSDConfigResult<T>> loadConfig<T extends GSDBaseConfig>(
      T configTemplate) async {
    String log = "============Load Config============\n";
    bool success = false;
    Exception? error;
    T? config;

    try {
      log += "Local Storage Key: $_key\n";

      String configFileContent = _localStorageManager.readData(_key);

      if (configFileContent.isNotEmpty) {
        log += "Load Config from Local Storage\n";
        String decryptedContent =
            await _encryptionManager.decryptAES(configFileContent);
        config = configTemplate.createInstance() as T;
        config.loadFromJson(decryptedContent);
        log += "Config loaded and decrypted\n";
        success = true;
      } else {
        log += "No config found in local storage\n";
      }
    } catch (e) {
      error = e as Exception;
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

  /// Event-Handler, der automatisch Konfigurationsänderungen verschlüsselt und im LocalStorage speichert
  ///
  /// [args] Event-Argumente mit der geänderten Konfiguration
  /// Verschlüsselt die Konfigurationsdaten vor der Speicherung im LocalStorage
  /// Wirft eine Exception, wenn Verschlüsselung oder Speichern fehlschlägt
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
    String encryptedContent =
        await _encryptionManager.encryptAES(config.toJson());
    _localStorageManager.writeData(_key, encryptedContent);
  }
}
