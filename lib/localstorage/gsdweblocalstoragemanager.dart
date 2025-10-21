import 'dart:js_interop';

import 'package:gsd_utilities/gsd_utilities.dart';

/// JavaScript Interop Bindungen für Browser localStorage API
@JS('window.localStorage')
external JSObject get _localStorage;

/// JavaScript Interop Bindung für Browser Window-Objekt
@JS('window')
external Window get window;

/// JavaScript Interop Klasse für localStorage-Operationen
@JS()
@staticInterop
class Storage {}

/// JavaScript Interop Klasse für Storage-Events
@JS()
@staticInterop
class StorageEvent {}

/// JavaScript Interop Klasse für Browser Window
@JS()
@staticInterop
class Window {}

/// Extension-Methoden für Storage JavaScript-Objekt
extension _GSDStorageExtension on Storage {
  /// Holt ein Element aus localStorage anhand des Schlüssels
  external String? getItem(String key);

  /// Setzt ein Element in localStorage mit Schlüssel-Wert-Paar
  external void setItem(String key, String value);

  /// Anzahl der gespeicherten Items
  external int get length;

  /// Holt den Schlüssel an der angegebenen Index-Position
  external String? key(int index);
}

/// Extension-Methoden für StorageEvent JavaScript-Objekt
extension _GSDStorageEventExtension on StorageEvent {
  /// Der Schlüssel, der in localStorage geändert wurde
  external String? get key;

  /// Der neue Wert, der gesetzt wurde
  external String? get newValue;
}

/// Extension-Methoden für Window JavaScript-Objekt
extension _GSDWindowExtension on Window {
  /// Fügt einen Event-Listener zum Window hinzu
  external void addEventListener(String type, JSFunction listener);

  /// Entfernt einen Event-Listener vom Window
  external void removeEventListener(String type, JSFunction listener);
}

/// Web-spezifische Implementierung des LocalStorageManager mit Browser-localStorage.
/// Stellt localStorage-Zugriff mit automatischer Storage-Event-Überwachung für Tab-übergreifende Kommunikation bereit.
class _GSDWebLocalStorageManager extends GSDBaseLocalStorageManager {
  /// JavaScript-Funktionsreferenz für den Storage-Event-Listener
  JSFunction? _storageListener;

  /// Konstruktor, der Storage-Event-Überwachung einrichtet
  _GSDWebLocalStorageManager() {
    _setupStorageListener();
  }

  /// Richtet einen Storage-Event-Listener ein, um Änderungen von anderen Tabs/Fenstern zu überwachen
  void _setupStorageListener() {
    _storageListener = (JSAny event) {
      final storageEvent = event as StorageEvent;
      final key = storageEvent.key;
      final newValue = storageEvent.newValue;

      // Event mit null-safe Werten auslösen
      storageChanged
          .broadcast(GSDWebLocalStorageEventArgs(key ?? '', newValue ?? ''));
    }.toJS;

    window.addEventListener('storage', _storageListener!);
  }

  /// Bereinigt den Storage-Event-Listener
  void dispose() {
    if (_storageListener != null) {
      window.removeEventListener('storage', _storageListener!);
      _storageListener = null;
    }
  }

  /// Schreibt Daten in Browser-localStorage
  ///
  /// [key] Der Speicherschlüssel-Bezeichner
  /// [data] Die zu speichernden String-Daten
  @override
  void writeData(String key, String data) {
    (_localStorage as Storage).setItem(key, data);
  }

  /// Liest Daten aus Browser-localStorage
  ///
  /// [key] Der Speicherschlüssel-Bezeichner
  ///
  /// Gibt die gespeicherten String-Daten zurück, oder leeren String wenn nicht gefunden
  @override
  String readData(String key) {
    return (_localStorage as Storage).getItem(key) ?? "";
  }

  /// Holt alle Items aus Browser-localStorage
  ///
  /// Gibt eine Map mit allen Schlüssel-Wert-Paaren aus dem localStorage zurück
  @override
  Map<String, String> getAllItems() {
    final storage = _localStorage as Storage;
    final items = <String, String>{};

    // Iteriere durch alle localStorage Keys
    for (int i = 0; i < storage.length; i++) {
      final key = storage.key(i);
      if (key != null) {
        final value = storage.getItem(key);
        if (value != null) {
          items[key] = value;
        }
      }
    }

    return items;
  }
}

/// Factory-Funktion zum Erstellen web-spezifischer LocalStorageManager-Instanzen
/// Gibt den Basisklassentyp für Plattformabstraktion zurück
GSDBaseLocalStorageManager createWebLocalStorageManager() =>
    _GSDWebLocalStorageManager();
