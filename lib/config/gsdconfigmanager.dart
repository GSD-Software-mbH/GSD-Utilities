part of '../gsd_utilities.dart';

/// Abstrakte Basisklasse für Konfigurationsverwaltung auf verschiedenen Plattformen.
/// Wählt automatisch die entsprechende Implementierung basierend auf der aktuellen Plattform aus:
/// - Web: Verwendet LocalStorage mit Verschlüsselung
/// - Mobile/Desktop: Verwendet FlutterSecureStorage
abstract class GSDConfigManager {
  /// Wenn true, werden sensible Daten (Keychain) weder gelesen noch geschrieben.
  /// Wird beim Erstellen des Managers übergeben, z.B. im Notification-Handler,
  /// um zu verhindern, dass leere Secrets die gespeicherten überschreiben.
  final bool backgroundMode;

  GSDConfigManager._({this.backgroundMode = false});

  /// Factory-Konstruktor, der automatisch die korrekte plattformspezifische Implementierung zurückgibt
  ///
  /// [key] Der Speicherschlüssel zur Identifizierung der Konfigurationsdaten
  /// [backgroundMode] Wenn true, werden Keychain-Secrets nicht gelesen/geschrieben
  ///
  /// Gibt zurück:
  /// - [_GSDWebConfigManager] für Web-Plattformen
  /// - [_GSDAppConfigManager] für Mobile/Desktop-Plattformen
  factory GSDConfigManager(
      {String key = "config", bool backgroundMode = false}) {
    if (kIsWeb) {
      return _GSDWebConfigManager(key, backgroundMode: backgroundMode);
    }
    return _GSDAppConfigManager(key, backgroundMode: backgroundMode);
  }

  /// Lädt Konfiguration vom Typ T aus persistentem Speicher.
  ///
  /// [configTemplate] Template-Instanz zur Erstellung neuer Konfigurationsinstanzen
  ///
  /// Gibt ein [GSDConfigResult] zurück, das Folgendes enthält:
  /// - Die geladene Konfiguration (bei Erfolg)
  /// - Erfolgsstatus
  /// - Fehlerinformationen (bei Fehlschlag)
  /// - Log-Nachrichten für Debugging
  Future<GSDConfigResult<T>> loadConfig<T extends GSDBaseConfig>(
      T configTemplate);

  Future<GSDConfigResult<T>> saveConfig<T extends GSDBaseConfig>(T config);

  /// Event-Handler, der aufgerufen wird, wenn Konfigurationsänderungen auftreten.
  /// Speichert automatisch die aktualisierte Konfiguration im persistenten Speicher.
  ///
  /// [args] Event-Argumente mit der geänderten Konfiguration
  void configChangedEvent(GSDConfigChangedEventArgs? args);
}
