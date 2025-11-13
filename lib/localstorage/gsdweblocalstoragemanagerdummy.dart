import 'package:gsd_utilities/gsd_utilities.dart';

/// Dummy-Implementierung des WebLocalStorageManager für Nicht-Web-Plattformen.
/// Wirft UnimplementedError für alle Operationen, da LocalStorage auf nativen Plattformen nicht verfügbar ist.
class _GSDWebLocalStorageManager extends GSDBaseLocalStorageManager {
  _GSDWebLocalStorageManager();

  /// Schreibt Daten in den lokalen Speicher
  /// Wirft UnimplementedError, da nicht auf nativen Plattformen verfügbar
  @override
  void writeData(String key, String data) {
    throw UnimplementedError();
  }

  /// Liest Daten aus dem lokalen Speicher
  /// Wirft UnimplementedError, da nicht auf nativen Plattformen verfügbar
  @override
  String readData(String key) {
    throw UnimplementedError();
  }

  /// Holt alle gespeicherten Items als Map
  /// Wirft UnimplementedError, da nicht auf nativen Plattformen verfügbar
  @override
  Map<String, String> getAllItems() {
    throw UnimplementedError();
  }
}

/// Factory-Funktion zum Erstellen von Instanzen - gibt Basisklassentyp zurück
GSDBaseLocalStorageManager createWebLocalStorageManager() =>
    _GSDWebLocalStorageManager();
