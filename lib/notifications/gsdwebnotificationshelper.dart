import 'package:web/web.dart' as web;
import 'dart:ui_web';
import 'package:gsd_utilities/gsd_utilities.dart';

class _GSDWebNotificationHelper extends GSDBaseNotificationsHelper {
  _GSDWebNotificationHelper();

  /// Liste der aktiven Notifications für Cleanup
  final List<web.Notification> _activeNotifications = [];

  /// Gibt zurück, ob der aktuelle Browser Chromium-basiert ist
  @override
  bool get isChromeBrowser => BrowserDetection.instance.isChromium;

  /// Gibt zurück, ob der aktuelle Browser Microsoft Edge ist
  @override
  bool get isEdgeBrowser => BrowserDetection.instance.isEdge;

  /// Gibt zurück, ob der aktuelle Browser Mozilla Firefox ist
  @override
  bool get isFirefoxBrowser => BrowserDetection.instance.isFirefox;

  /// Gibt zurück, ob der aktuelle Browser Apple Safari ist
  @override
  bool get isSafariBrowser => BrowserDetection.instance.isSafari;

  /// Gibt zurück, ob die Benachrichtigungsberechtigung im Standard-Status ist
  @override
  bool get isNotificationPermissionDefault =>
      web.Notification.permission == 'default';

  /// Gibt zurück, ob die Benachrichtigungsberechtigung verweigert wurde
  @override
  bool get isNotificationPermissionDenied =>
      web.Notification.permission == 'denied';

  /// Gibt zurück, ob die Benachrichtigungsberechtigung erteilt wurde
  @override
  bool get isNotificationPermissionGranted =>
      web.Notification.permission == 'granted';

  /// Gibt den aktuellen Status der Benachrichtigungsberechtigung zurück
  @override
  String get notificationPermission => web.Notification.permission;

  /// Fordert die Benachrichtigungsberechtigung vom Benutzer an
  /// Verwendet die Browser Notification API
  @override
  void requestNotificationPermission() {
    web.Notification.requestPermission();
  }

  @override
  void showNotification(String title, String body) {
    try {
      // Einfache Lösung: Notification mit Web API erstellen
      final notification =
          web.Notification(title, web.NotificationOptions(body: body));
      _activeNotifications.add(notification);

      // Auto-close nach 5 Sekunden
      Future.delayed(const Duration(seconds: 5), () {
        try {
          notification.close();
          _activeNotifications.remove(notification);
        } catch (e) {
          rethrow;
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Räumt alle aktiven Notifications auf
  @override
  void dispose() {
    // Alle aktiven Notifications schließen
    for (final notification in _activeNotifications) {
      try {
        notification.close();
      } catch (e) {
        // Notification war möglicherweise bereits geschlossen
      }
    }
    _activeNotifications.clear();
  }
}

/// Factory-Funktion zum Erstellen web-spezifischer NotificationsHelper-Instanzen
/// Gibt den Basisklassentyp für Plattformabstraktion zurück
GSDBaseNotificationsHelper createWebNotificationsHelper() =>
    _GSDWebNotificationHelper();
