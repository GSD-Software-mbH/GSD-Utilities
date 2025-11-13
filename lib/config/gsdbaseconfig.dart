part of '../gsd_utilities.dart';

/// Abstrakte Basisklasse für Konfigurationsverwaltung.
/// Stellt die Grundlage für die Implementierung von Konfigurationsklassen bereit,
/// die zu/von JSON serialisiert werden können und in anderen Projekten erweitert werden können.
///
/// Verwendungsbeispiel:
/// ```dart
/// class MyConfig extends BaseConfig {
///   String? myProperty;
///
///   MyConfig({this.myProperty});
///
///   // Named constructor für die Erstellung aus JSON
///   MyConfig.fromJson(String jsonString) {
///     loadFromJson(jsonString);
///   }
///
///   @override
///   String toJson() => '{"myProperty": ${myProperty != null ? '"$myProperty"' : 'null'}';
///
///   @override
///   void loadFromJson(String jsonString) {
///     // JSON parsen und Eigenschaften setzen
///     final data = jsonDecode(jsonString);
///     myProperty = data['myProperty'];
///   }
///
///   @override
///   BaseConfig createInstance() => MyConfig();
/// }
/// ```
abstract class GSDBaseConfig {
  /// Event, das ausgelöst wird, wenn sich die Konfiguration ändert
  Event configChangedEvent = Event();

  /// Konstruktor für Unterklassen
  GSDBaseConfig();

  /// Abstrakte Methode zur Konvertierung der Konfiguration in einen JSON-String
  /// Muss von Unterklassen implementiert werden, um deren spezifische Serialisierungslogik zu definieren
  String toJson();

  /// Abstrakte Methode zum Laden der Konfiguration aus einem JSON-String
  /// Muss von Unterklassen implementiert werden, um deren spezifische Deserialisierungslogik zu definieren
  void loadFromJson(String jsonString);

  /// Abstrakte Methode zum Erstellen einer neuen Instanz desselben Typs
  /// Muss von Unterklassen implementiert werden, um eine neue Instanz zurückzugeben
  GSDBaseConfig createInstance();

  /// Löst das Konfigurationsänderungs-Event aus
  /// Sollte aufgerufen werden, wenn Konfigurationseigenschaften geändert werden
  void save() {
    configChangedEvent.broadcast(GSDConfigChangedEventArgs(config: this));
  }
}
