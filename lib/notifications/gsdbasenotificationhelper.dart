part of '../gsd_utilities.dart';

/// Abstrakte Basis-Klasse für NotificationsHelper-Implementierungen
/// Definiert die Schnittstelle für Benachrichtigungsfunktionen und Browser-Erkennung
abstract class GSDBaseNotificationsHelper {
  /// Gibt zurück, ob die Benachrichtigungsberechtigung erteilt wurde
  bool get isNotificationPermissionGranted;

  /// Gibt zurück, ob die Benachrichtigungsberechtigung verweigert wurde
  bool get isNotificationPermissionDenied;

  /// Gibt zurück, ob die Benachrichtigungsberechtigung im Standard-Status ist
  bool get isNotificationPermissionDefault;

  /// Gibt zurück, ob der aktuelle Browser Microsoft Edge ist
  bool get isEdgeBrowser;

  /// Gibt zurück, ob der aktuelle Browser Apple Safari ist
  bool get isSafariBrowser;

  /// Gibt zurück, ob der aktuelle Browser Chromium-basiert ist
  bool get isChromeBrowser;

  /// Gibt zurück, ob der aktuelle Browser Mozilla Firefox ist
  bool get isFirefoxBrowser;

  /// Gibt den aktuellen Status der Benachrichtigungsberechtigung zurück
  /// Returns: 'granted', 'denied' oder 'default'
  String get notificationPermission;

  /// Fordert die Benachrichtigungsberechtigung vom Benutzer an
  void requestNotificationPermission();

  void showNotification(String title, String body);

  /// Räumt Ressourcen auf (optional)
  void dispose() {}
}
