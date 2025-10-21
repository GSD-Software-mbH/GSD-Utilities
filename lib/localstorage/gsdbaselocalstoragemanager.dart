part of '../gsd_utilities.dart';

/// Abstrakte Basis-Klasse für LocalStorage-Manager-Implementierungen
abstract class GSDBaseLocalStorageManager {
  /// Event-Broadcaster für Storage-Change-Benachrichtigungen (nur Web)
  /// Wird ausgelöst, wenn localStorage von anderen Tabs/Fenstern geändert wird
  Event<GSDWebLocalStorageEventArgs> storageChanged = Event();

  /// Schreibt Daten in den lokalen Speicher
  ///
  /// [key] Der Speicherschlüssel-Bezeichner
  /// [data] Die zu speichernden String-Daten
  void writeData(String key, String data);

  /// Liest Daten aus dem lokalen Speicher
  ///
  /// [key] Der Speicherschlüssel-Bezeichner
  ///
  /// Gibt die gespeicherten String-Daten zurück, oder einen leeren String wenn nicht gefunden
  String readData(String key);

  /// Holt alle gespeicherten Items als Map
  ///
  /// Gibt eine Map mit allen Schlüssel-Wert-Paaren zurück
  Map<String, String> getAllItems();
}
