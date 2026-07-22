import 'dart:js_interop';

import 'package:gsd_utilities/gsd_utilities.dart';

/// JavaScript Interop Bindung für Browser History API
@JS('window.history')
external JSObject get _history;

/// JavaScript Interop Bindung für Browser Document API
@JS('window.document')
external JSObject get _document;

/// JavaScript Interop Klasse für History-Operationen
@JS()
@staticInterop
class History {}

/// JavaScript Interop Klasse für Document-Operationen
@JS()
@staticInterop
class Document {}

/// Extension-Methoden für History JavaScript-Objekt
extension _GSDHistoryExtension on History {
  /// Ersetzt den aktuellen History-Eintrag ohne Seitenreload
  external void replaceState(JSAny? data, String title, String url);
}

/// Extension-Methoden für Document JavaScript-Objekt
extension _GSDDocumentExtension on Document {
  /// Setzt den Titel des Dokuments
  external set title(String title);
}

/// Web-spezifische Implementierung des UriManager mit Browser History API und Document API.
/// Stellt URI-Manipulation und Titel-Updates für Web-Plattformen bereit.
class _GSDWebUriManager extends GSDBaseUriManager {
  /// Konstruktor für Web-URI-Manager
  _GSDWebUriManager();

  /// Gibt die aktuelle URI des Browsers zurück
  @override
  Uri getCurrentUri() {
    return Uri.base;
  }

  /// Setzt die URI zurück (entfernt alle Query-Parameter)
  @override
  void resetUri() {
    final currentUri = getCurrentUri();
    final newUri = currentUri.replace(queryParameters: <String, String>{});
    _updateBrowserUrl(newUri);
  }

  /// Entfernt einen spezifischen Query-Parameter aus der URI
  @override
  void removeQueryParameter(String key) {
    final currentUri = getCurrentUri();
    if (currentUri.queryParameters.containsKey(key)) {
      final newQueryParameters =
          Map<String, String>.from(currentUri.queryParameters);
      newQueryParameters.remove(key);
      final newUri = currentUri.replace(queryParameters: newQueryParameters);
      _updateBrowserUrl(newUri);
    }
  }

  /// Liest einen spezifischen Query-Parameter aus der URI
  @override
  String? getQueryParameter(String key) {
    return getCurrentUri().queryParameters[key];
  }

  /// Liest alle Query-Parameter aus der URI
  @override
  Map<String, String> getAllQueryParameters() {
    return Map<String, String>.from(getCurrentUri().queryParameters);
  }

  /// Fügt einen Query-Parameter hinzu oder bearbeitet einen existierenden
  @override
  void setQueryParameter(String key, String value) {
    final currentUri = getCurrentUri();
    final newQueryParameters =
        Map<String, String>.from(currentUri.queryParameters);
    newQueryParameters[key] = value;
    final newUri = currentUri.replace(queryParameters: newQueryParameters);
    _updateBrowserUrl(newUri);
  }

  /// Setzt mehrere Query-Parameter auf einmal
  @override
  void setQueryParameters(Map<String, String> parameters) {
    final currentUri = getCurrentUri();
    final newQueryParameters =
        Map<String, String>.from(currentUri.queryParameters);
    newQueryParameters.addAll(parameters);
    final newUri = currentUri.replace(queryParameters: newQueryParameters);
    _updateBrowserUrl(newUri);
  }

  /// Aktualisiert den Titel der Web-Seite
  /// Verwendet die Browser Document API
  ///
  /// [title] Der neue Titel der Seite
  @override
  void updateTitle(String title) {
    final document = _document as Document;
    document.title = title;
  }

  /// Navigiert zu einer neuen URI
  @override
  void navigateToUri(Uri uri) {
    _updateBrowserUrl(uri);
  }

  /// Private Hilfsmethode zum Aktualisieren der Browser-URL
  void _updateBrowserUrl(Uri uri) {
    final history = _history as History;
    history.replaceState(null, '', uri.toString());
  }
}

/// Factory-Funktion zum Erstellen web-spezifischer UriManager-Instanzen
/// Gibt den Basisklassentyp für Plattformabstraktion zurück
GSDBaseUriManager createWebUriManager() => _GSDWebUriManager();
