part of '../../gsd_utilities.dart';

/// Abstrakte Schnittstelle für Konfigurations-Persistierung
///
/// Diese Schnittstelle ermöglicht es, die ausgewählte Sprache
/// persistent zu speichern, damit sie beim nächsten App-Start
/// wiederhergestellt werden kann.
abstract class IGSDMultiLanguageConfigProvider {
  /// Speichert den ausgewählten Sprachcode
  ///
  /// [languageCode] - Der Code der zu speichernden Sprache
  void setSelectedLanguage(String languageCode);

  /// Lädt den aktuell ausgewählten Sprachcode
  ///
  /// Gibt den gespeicherten Sprachcode zurück oder einen
  /// leeren String, wenn noch keine Sprache ausgewählt wurde.
  String get selectedLanguage;
}
