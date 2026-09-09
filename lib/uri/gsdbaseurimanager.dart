part of '../gsd_utilities.dart';

/// Abstrakte Basis-Klasse für UriManager-Implementierungen
abstract class GSDBaseUriManager {
  /// Gibt die aktuelle URI zurück
  Uri getCurrentUri();

  /// Setzt die URI zurück (entfernt alle Query-Parameter)
  void resetUri();

  /// Entfernt einen spezifischen Query-Parameter aus der URI
  ///
  /// [key] Der zu entfernende Query-Parameter-Schlüssel
  void removeQueryParameter(String key);

  /// Liest einen spezifischen Query-Parameter aus der URI
  ///
  /// [key] Der Schlüssel des Parameters
  /// Returns: Der Wert des Parameters oder null falls nicht vorhanden
  String? getQueryParameter(String key);

  /// Liest alle Query-Parameter aus der URI
  ///
  /// Returns: Map mit allen Query-Parametern
  Map<String, String> getAllQueryParameters();

  /// Fügt einen Query-Parameter hinzu oder bearbeitet einen existierenden
  ///
  /// [key] Der Parameter-Schlüssel
  /// [value] Der Parameter-Wert
  void setQueryParameter(String key, String value);

  /// Setzt mehrere Query-Parameter auf einmal
  ///
  /// [parameters] Map mit den zu setzenden Parametern
  void setQueryParameters(Map<String, String> parameters);

  /// Aktualisiert den Titel der Seite/App
  ///
  /// [title] Der neue Titel
  void updateTitle(String title);

  /// Navigiert zu einer neuen URI
  ///
  /// [uri] Die neue URI
  void navigateToUri(Uri uri);
}
