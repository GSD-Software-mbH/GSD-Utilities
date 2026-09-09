import 'package:gsd_utilities/gsd_utilities.dart';

/// Dummy-Implementierung des NotificationsHelper für Nicht-Web-Plattformen.
/// Stellt leere Implementierungen bereit, da Browser-spezifische Benachrichtigungen auf nativen Plattformen normalerweise nicht benötigt werden.
class _GSDWebNotificationsHelper extends GSDBaseNotificationsHelper {
  /// Konstruktor für Dummy-NotificationsHelper
  _GSDWebNotificationsHelper();

  /// Wirft UnimplementedError da Benachrichtigungsberechtigungen auf nativen Plattformen anders gehandhabt werden
  @override
  bool get isNotificationPermissionGranted => throw UnimplementedError();

  /// Wirft UnimplementedError da Benachrichtigungsberechtigungen auf nativen Plattformen anders gehandhabt werden
  @override
  bool get isNotificationPermissionDenied => throw UnimplementedError();

  /// Wirft UnimplementedError da Benachrichtigungsberechtigungen auf nativen Plattformen anders gehandhabt werden
  @override
  bool get isNotificationPermissionDefault => throw UnimplementedError();

  /// Wirft UnimplementedError da Browser-Erkennung auf nativen Plattformen nicht verfügbar ist
  @override
  bool get isEdgeBrowser => throw UnimplementedError();

  /// Wirft UnimplementedError da Browser-Erkennung auf nativen Plattformen nicht verfügbar ist
  @override
  bool get isSafariBrowser => throw UnimplementedError();

  /// Wirft UnimplementedError da Browser-Erkennung auf nativen Plattformen nicht verfügbar ist
  @override
  bool get isChromeBrowser => throw UnimplementedError();

  /// Wirft UnimplementedError da Browser-Erkennung auf nativen Plattformen nicht verfügbar ist
  @override
  bool get isFirefoxBrowser => throw UnimplementedError();

  /// Wirft UnimplementedError da Benachrichtigungsberechtigungen auf nativen Plattformen anders gehandhabt werden
  @override
  String get notificationPermission => throw UnimplementedError();

  /// Wirft UnimplementedError da Benachrichtigungsberechtigungen auf nativen Plattformen anders gehandhabt werden
  @override
  void requestNotificationPermission() {
    throw UnimplementedError();
  }

  @override
  void showNotification(String title, String body) {
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // Keine Ressourcen zu bereinigen in der Dummy-Implementierung
  }
}

/// Factory-Funktion zum Erstellen von Dummy-Instanzen - gibt Basisklassentyp zurück
GSDBaseNotificationsHelper createWebNotificationsHelper() =>
    _GSDWebNotificationsHelper();
