part of '../gsd_utilities.dart';

/// Plattformübergreifender NotificationsHelper, der automatisch die entsprechende Implementierung auswählt.
/// Stellt eine einheitliche Schnittstelle für Web- und Mobile/Desktop-Benachrichtigungsoperationen bereit.
///
/// Features:
/// - Web: Verwendet Browser Notification API für Berechtigungen und Browser-Erkennung
/// - Mobile/Desktop: Verwendet Fallback-Implementierung (UnimplementedError)
class GSDNotificationsHelper {
  /// Interne plattformspezifische NotificationsHelper-Instanz
  late GSDBaseNotificationsHelper _notificationsHelper;

  /// Erstellt eine neue NotificationsHelper-Instanz
  /// Wählt automatisch die entsprechende Plattform-Implementierung aus
  GSDNotificationsHelper() {
    _notificationsHelper = createWebNotificationsHelper();
  }

  /// Gibt zurück, ob die Benachrichtigungsberechtigung erteilt wurde
  bool get isNotificationPermissionGranted =>
      _notificationsHelper.isNotificationPermissionGranted;

  /// Gibt zurück, ob die Benachrichtigungsberechtigung verweigert wurde
  bool get isNotificationPermissionDenied =>
      _notificationsHelper.isNotificationPermissionDenied;

  /// Gibt zurück, ob die Benachrichtigungsberechtigung im Standard-Status ist
  bool get isNotificationPermissionDefault =>
      _notificationsHelper.isNotificationPermissionDefault;

  /// Gibt zurück, ob der aktuelle Browser Microsoft Edge ist
  bool get isEdgeBrowser => _notificationsHelper.isEdgeBrowser;

  /// Gibt zurück, ob der aktuelle Browser Apple Safari ist
  bool get isSafariBrowser => _notificationsHelper.isSafariBrowser;

  /// Gibt zurück, ob der aktuelle Browser Chromium-basiert ist
  bool get isChromeBrowser => _notificationsHelper.isChromeBrowser;

  /// Gibt zurück, ob der aktuelle Browser Mozilla Firefox ist
  bool get isFirefoxBrowser => _notificationsHelper.isFirefoxBrowser;

  /// Gibt den aktuellen Status der Benachrichtigungsberechtigung zurück
  String get notificationPermission =>
      _notificationsHelper.notificationPermission;

  /// Fordert die Benachrichtigungsberechtigung vom Benutzer an
  void requestNotificationPermission() {
    _notificationsHelper.requestNotificationPermission();
  }

  void showNotification(String title, String body) {
    _notificationsHelper.showNotification(title, body);
  }

  /// Räumt alle Ressourcen auf
  void dispose() {
    _notificationsHelper.dispose();
  }
}
