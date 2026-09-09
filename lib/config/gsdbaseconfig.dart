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

  /// Konvertiert die gesamte Konfiguration in einen JSON-String (öffentliche Daten).
  /// Wird in SharedPreferences/LocalStorage gespeichert.
  String toJson();

  /// Lädt die Konfiguration aus einem JSON-String (öffentliche Daten).
  /// Wird nach loadSecureJson aufgerufen falls Secrets vorhanden sind.
  void loadFromJson(String jsonString);

  /// Erstellt eine neue Instanz desselben Typs.
  GSDBaseConfig createInstance();

  /// Konvertiert sensible Daten (Passwörter, Tokens, Keys) in einen JSON-String.
  /// Wird separat im Keychain gespeichert.
  /// Unterklassen überschreiben dies um ihre geheimen Felder zu definieren.
  String toSecureJson() => "{}";

  /// Lädt sensible Daten aus einem JSON-String und wendet sie auf die Config an.
  /// Wird nach loadFromJson aufgerufen um Secrets in die bereits geladene Config einzufügen.
  void loadSecureJson(String jsonString) {}

  /// Löst das Konfigurationsänderungs-Event aus
  /// Sollte aufgerufen werden, wenn Konfigurationseigenschaften geändert werden
  void save() {
    configChangedEvent.broadcast(GSDConfigChangedEventArgs(config: this));
  }
}
