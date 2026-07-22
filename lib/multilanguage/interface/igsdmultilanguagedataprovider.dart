part of '../../gsd_utilities.dart';

/// Abstrakte Schnittstelle für Sprachdaten-Speicher
///
/// Diese Schnittstelle definiert die Methoden, die ein Datenanbieter
/// implementieren muss, um Sprachdaten bereitzustellen. Dies kann
/// von lokalen Dateien, APIs oder Datenbanken sein.
abstract class IGSDMultiLanguageDataProvider {
  /// Initialisiert den Datenanbieter
  ///
  /// Diese Methode sollte alle notwendigen Vorbereitungen treffen,
  /// wie das Laden von Konfigurationen oder das Herstellen von Verbindungen.
  Future<void> initialize();

  /// Lädt die Sprachdaten für einen bestimmten Sprachcode
  ///
  /// [languageCode] - Der Code der Sprache (z.B. "de", "en")
  ///
  /// Gibt eine Map mit Schlüssel-Wert-Paaren für die Übersetzungen zurück,
  /// oder null wenn die Sprache nicht gefunden wurde.
  Future<Map<String, dynamic>?> getLanguageData(String languageCode);

  /// Lädt die Liste aller unterstützten Sprachen
  ///
  /// Gibt eine Liste von Maps zurück, die jeweils die Metadaten
  /// einer unterstützten Sprache enthalten.
  Future<List<Map<String, dynamic>>> getSupportedLanguages();
}
