import 'package:gsd_utilities/gsd_utilities.dart';

/// Dummy-Implementierung des UriManager für Nicht-Web-Plattformen.
/// Stellt leere Implementierungen bereit, da URI-Manipulation auf nativen Plattformen normalerweise nicht benötigt wird.
class _GSDWebUriManager extends GSDBaseUriManager {
  /// Konstruktor für Default-URI-Manager
  _GSDWebUriManager();

  /// Gibt eine Mock-URI zurück für native Plattformen
  @override
  Uri getCurrentUri() {
    throw UnimplementedError();
  }

  /// Leere Implementierung für URI-Reset auf nativen Plattformen
  @override
  void resetUri() {
    throw UnimplementedError();
  }

  /// Leere Implementierung für Parameter-Entfernung auf nativen Plattformen
  @override
  void removeQueryParameter(String key) {
    throw UnimplementedError();
  }

  /// Gibt null zurück da keine Query-Parameter auf nativen Plattformen verfügbar sind
  @override
  String? getQueryParameter(String key) {
    throw UnimplementedError();
  }

  /// Gibt leere Map zurück da keine Query-Parameter auf nativen Plattformen verfügbar sind
  @override
  Map<String, String> getAllQueryParameters() {
    throw UnimplementedError();
  }

  /// Leere Implementierung für Parameter-Setzen auf nativen Plattformen
  @override
  void setQueryParameter(String key, String value) {
    throw UnimplementedError();
  }

  /// Leere Implementierung für Parameter-Setzen auf nativen Plattformen
  @override
  void setQueryParameters(Map<String, String> parameters) {
    throw UnimplementedError();
  }

  /// Leere Implementierung für Titel-Updates auf nativen Plattformen
  /// App-Titel wird normalerweise über andere Mechanismen gesteuert
  @override
  void updateTitle(String title) {
    throw UnimplementedError();
  }

  /// Leere Implementierung für Navigation auf nativen Plattformen
  @override
  void navigateToUri(Uri uri) {
    throw UnimplementedError();
  }
}

/// Factory-Funktion zum Erstellen von Instanzen - gibt Basisklassentyp zurück
GSDBaseUriManager createWebUriManager() => _GSDWebUriManager();
