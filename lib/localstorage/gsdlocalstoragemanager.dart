part of '../gsd_utilities.dart';

/// Plattformübergreifender LocalStorage-Manager, der automatisch die entsprechende Implementierung auswählt.
/// Stellt eine einheitliche Schnittstelle für Web- und Mobile/Desktop-LocalStorage-Operationen bereit.
///
/// Features:
/// - Web: Verwendet Browser-localStorage mit Storage-Events
/// - Mobile/Desktop: Verwendet Fallback-Implementierung
/// - Storage-Change-Events (nur Web)
class GSDLocalStorageManager {
  /// Interne plattformspezifische Storage-Manager-Instanz
  late GSDBaseLocalStorageManager _storageManager;

  /// Event-Broadcaster für Storage-Change-Benachrichtigungen (nur Web)
  /// Wird ausgelöst, wenn localStorage von anderen Tabs/Fenstern geändert wird
  Event<GSDWebLocalStorageEventArgs> get storageChanged =>
      _storageManager.storageChanged;

  /// Erstellt eine neue LocalStorageManager-Instanz
  /// Wählt automatisch die entsprechende Plattform-Implementierung aus
  GSDLocalStorageManager() {
    _storageManager = createWebLocalStorageManager();
  }

  /// Schreibt Daten in den lokalen Speicher
  ///
  /// [key] Der Speicherschlüssel-Bezeichner
  /// [data] Die zu speichernden String-Daten
  void writeData(String key, String data) {
    _storageManager.writeData(key, data);
  }

  /// Liest Daten aus dem lokalen Speicher
  ///
  /// [key] Der Speicherschlüssel-Bezeichner
  ///
  /// Gibt die gespeicherten String-Daten zurück, oder einen leeren String wenn nicht gefunden
  String readData(String key) {
    return _storageManager.readData(key);
  }

  /// Holt alle gespeicherten Items als Map
  ///
  /// Gibt eine Map mit allen Schlüssel-Wert-Paaren zurück
  Map<String, String> getAllItems() {
    return _storageManager.getAllItems();
  }
}
