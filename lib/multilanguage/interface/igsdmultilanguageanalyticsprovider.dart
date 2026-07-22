part of '../../gsd_utilities.dart';

/// Abstrakte Schnittstelle für Analytics/Logging
///
/// Diese Schnittstelle ermöglicht es, Sprachwechsel-Ereignisse
/// zu protokollieren, um Analytics und Benutzungsstatistiken
/// zu erstellen.
abstract class IGSDMultiLanguageAnalyticsProvider {
  /// Protokolliert einen Sprachwechsel
  ///
  /// [languageCode] - Der Code der neu ausgewählten Sprache
  ///
  /// Diese Methode wird aufgerufen, wenn der Benutzer eine
  /// neue Sprache auswählt, um das Ereignis zu verfolgen.
  void logLanguageChanged(String languageCode);
}
