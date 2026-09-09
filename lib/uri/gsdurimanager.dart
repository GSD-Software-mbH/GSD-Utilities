part of '../gsd_utilities.dart';

/// Plattformübergreifender UriManager, der automatisch die entsprechende Implementierung auswählt.
/// Stellt eine einheitliche Schnittstelle für Web- und Mobile/Desktop-URI-Operationen bereit.
///
/// Features:
/// - Web: Verwendet Browser History API und Document Title API
/// - Mobile/Desktop: Verwendet Fallback-Implementierung (keine Operationen)
class GSDUriManager {
  /// Interne plattformspezifische Uri-Manager-Instanz
  late GSDBaseUriManager _uriManager;

  /// Erstellt eine neue UriManager-Instanz
  /// Wählt automatisch die entsprechende Plattform-Implementierung aus
  GSDUriManager() {
    _uriManager = createWebUriManager();
  }

  /// Gibt die aktuelle URI zurück
  Uri getCurrentUri() {
    return _uriManager.getCurrentUri();
  }

  /// Setzt die URI zurück (entfernt alle Query-Parameter)
  void resetUri() {
    _uriManager.resetUri();
  }

  /// Entfernt einen spezifischen Query-Parameter aus der URI
  ///
  /// [key] Der zu entfernende Query-Parameter-Schlüssel
  void removeQueryParameter(String key) {
    _uriManager.removeQueryParameter(key);
  }

  /// Liest einen spezifischen Query-Parameter aus der URI
  ///
  /// [key] Der Schlüssel des Parameters
  /// Returns: Der Wert des Parameters oder null falls nicht vorhanden
  String? getQueryParameter(String key) {
    return _uriManager.getQueryParameter(key);
  }

  /// Liest alle Query-Parameter aus der URI
  ///
  /// Returns: Map mit allen Query-Parametern
  Map<String, String> getAllQueryParameters() {
    return _uriManager.getAllQueryParameters();
  }

  /// Fügt einen Query-Parameter hinzu oder bearbeitet einen existierenden
  ///
  /// [key] Der Parameter-Schlüssel
  /// [value] Der Parameter-Wert
  void setQueryParameter(String key, String value) {
    _uriManager.setQueryParameter(key, value);
  }

  /// Setzt mehrere Query-Parameter auf einmal
  ///
  /// [parameters] Map mit den zu setzenden Parametern
  void setQueryParameters(Map<String, String> parameters) {
    _uriManager.setQueryParameters(parameters);
  }

  /// Aktualisiert den Titel der Seite/App
  ///
  /// [title] Der neue Titel
  void updateTitle(String title) {
    _uriManager.updateTitle(title);
  }

  /// Navigiert zu einer neuen URI
  ///
  /// [uri] Die neue URI
  void navigateToUri(Uri uri) {
    _uriManager.navigateToUri(uri);
  }
}
