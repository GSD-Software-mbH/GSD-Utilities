import 'package:flutter/material.dart';
import 'package:gsd_utilities/gsd_utilities.dart';

/// Example-Screen für Notification-Management
/// Demonstriert Browser-Benachrichtigungsberechtigungen und Browser-Erkennung
class NotificationExampleScreen extends StatefulWidget {
  const NotificationExampleScreen({super.key});

  @override
  State<NotificationExampleScreen> createState() =>
      _NotificationExampleScreenState();
}

class _NotificationExampleScreenState extends State<NotificationExampleScreen> {
  late GSDNotificationsHelper _notificationsHelper;
  String _logMessages = '';
  String _currentPermissionStatus = '';
  String _browserInfo = '';

  // Form Controllers für Custom Notifications
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _notificationCounter = 0;

  @override
  void initState() {
    super.initState();
    _notificationsHelper = GSDNotificationsHelper();
    _updateNotificationStatus();
    _updateBrowserInfo();
    _addLog('Notification Helper initialisiert');

    // Standard-Werte für Test-Benachrichtigungen
    _titleController.text = 'GSD Utilities Test';
    _bodyController.text = 'Dies ist eine Test-Benachrichtigung!';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _notificationsHelper.dispose(); // Notification-Ressourcen aufräumen
    super.dispose();
  }

  /// Aktualisiert den aktuellen Berechtigungsstatus
  void _updateNotificationStatus() {
    try {
      setState(() {
        _currentPermissionStatus = _notificationsHelper.notificationPermission;
      });
      _addLog('Berechtigungsstatus aktualisiert: $_currentPermissionStatus');
    } catch (e) {
      _addLog('Fehler beim Aktualisieren des Status: $e');
    }
  }

  /// Aktualisiert die Browser-Informationen
  void _updateBrowserInfo() {
    try {
      List<String> browserDetails = [];

      if (_notificationsHelper.isChromeBrowser) {
        browserDetails.add('Chromium-basiert');
      }
      if (_notificationsHelper.isEdgeBrowser) {
        browserDetails.add('Microsoft Edge');
      }
      if (_notificationsHelper.isFirefoxBrowser) {
        browserDetails.add('Mozilla Firefox');
      }
      if (_notificationsHelper.isSafariBrowser) {
        browserDetails.add('Apple Safari');
      }

      setState(() {
        _browserInfo = browserDetails.isEmpty
            ? 'Unbekannter Browser'
            : browserDetails.join(', ');
      });
      _addLog('Browser erkannt: $_browserInfo');
    } catch (e) {
      setState(() {
        _browserInfo = 'Browser-Erkennung nicht verfügbar';
      });
      _addLog('Browser-Erkennung fehlgeschlagen: $e');
    }
  }

  /// Fordert Benachrichtigungsberechtigung an
  void _requestNotificationPermission() {
    try {
      _addLog('Fordere Benachrichtigungsberechtigung an...');
      _notificationsHelper.requestNotificationPermission();

      // Kurze Verzögerung, dann Status aktualisieren
      Future.delayed(const Duration(milliseconds: 500), () {
        _updateNotificationStatus();
      });
    } catch (e) {
      _addLog('Fehler beim Anfordern der Berechtigung: $e');
    }
  }

  /// Fügt eine Nachricht zum Log hinzu
  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _logMessages += '[$timestamp] $message\n';
    });
  }

  /// Löscht das Log
  void _clearLog() {
    setState(() {
      _logMessages = '';
    });
    _addLog('Log gelöscht');
  }

  /// Testet alle Berechtigungsstatus
  void _testAllPermissionStates() {
    try {
      _addLog('Teste alle Berechtigungsstatus...');

      bool isGranted = _notificationsHelper.isNotificationPermissionGranted;
      bool isDenied = _notificationsHelper.isNotificationPermissionDenied;
      bool isDefault = _notificationsHelper.isNotificationPermissionDefault;

      _addLog('Berechtigung erteilt: $isGranted');
      _addLog('Berechtigung verweigert: $isDenied');
      _addLog('Berechtigung Standard: $isDefault');

      _updateNotificationStatus();
    } catch (e) {
      _addLog('Fehler beim Testen der Berechtigungen: $e');
    }
  }

  /// Sendet eine Test-Benachrichtigung
  void _sendTestNotification() {
    try {
      if (!_notificationsHelper.isNotificationPermissionGranted) {
        _addLog(
            'Benachrichtigung kann nicht gesendet werden - keine Berechtigung');
        _showPermissionDialog();
        return;
      }

      _notificationCounter++;
      final title = _titleController.text.isNotEmpty
          ? _titleController.text
          : 'GSD Utilities Test';
      final body = _bodyController.text.isNotEmpty
          ? _bodyController.text
          : 'Test-Benachrichtigung #$_notificationCounter';

      _notificationsHelper.showNotification(title, body);
      _addLog('Test-Benachrichtigung gesendet: "$title" - "$body"');
    } catch (e) {
      _addLog('Fehler beim Senden der Benachrichtigung: $e');
    }
  }

  /// Sendet eine vordefinierte Demo-Benachrichtigung
  void _sendDemoNotification() {
    try {
      if (!_notificationsHelper.isNotificationPermissionGranted) {
        _addLog(
            'Demo-Benachrichtigung kann nicht gesendet werden - keine Berechtigung');
        _showPermissionDialog();
        return;
      }

      _notificationCounter++;
      final demoMessages = [
        'Flutter Web Benachrichtigungen funktionieren! 🎉',
        'GSD Utilities - Ihre Entwicklung vereinfacht ⚡',
        'Cross-Browser Support aktiviert ✅',
        'Notification API erfolgreich integriert 🔔',
      ];

      final randomMessage =
          demoMessages[_notificationCounter % demoMessages.length];

      _notificationsHelper.showNotification(
          'GSD Utilities Demo #$_notificationCounter', randomMessage);
      _addLog('📤 Demo-Benachrichtigung #$_notificationCounter gesendet');
    } catch (e) {
      _addLog('❌ Fehler beim Senden der Demo-Benachrichtigung: $e');
    }
  }

  /// Zeigt einen Dialog zur Berechtigung an
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Berechtigung erforderlich'),
          content: const Text(
              'Um Benachrichtigungen zu senden, müssen Sie zuerst die Berechtigung erteilen. '
              'Klicken Sie auf "Berechtigung anfordern" und erlauben Sie Benachrichtigungen in Ihrem Browser.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestNotificationPermission();
              },
              child: const Text('Berechtigung anfordern'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Notification & Browser Helper Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Demonstriert Browser-Benachrichtigungsberechtigungen und Browser-Erkennung',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Status Cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Browser-Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Erkannter Browser: $_browserInfo',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Benachrichtigungsstatus',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aktueller Status: $_currentPermissionStatus',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getPermissionIcon(_currentPermissionStatus),
                          color: _getPermissionColor(_currentPermissionStatus),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getPermissionText(_currentPermissionStatus),
                          style: TextStyle(
                            color:
                                _getPermissionColor(_currentPermissionStatus),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Custom Notification Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Custom Notification',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titel',
                        border: OutlineInputBorder(),
                        hintText: 'Geben Sie einen Titel ein...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Nachricht',
                        border: OutlineInputBorder(),
                        hintText: 'Geben Sie eine Nachricht ein...',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _sendTestNotification,
                            icon: const Icon(Icons.send),
                            label: const Text('Custom Notification senden'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _requestNotificationPermission,
                  icon: const Icon(Icons.notifications),
                  label: const Text('Berechtigung anfordern'),
                ),
                ElevatedButton.icon(
                  onPressed: _sendDemoNotification,
                  icon: const Icon(Icons.notification_add),
                  label: const Text('Demo-Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _testAllPermissionStates,
                  icon: const Icon(Icons.security),
                  label: const Text('Status testen'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _updateNotificationStatus();
                    _updateBrowserInfo();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aktualisieren'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearLog,
                  icon: const Icon(Icons.clear),
                  label: const Text('Log löschen'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Log Output
            const Text(
              'Aktivitätsprotokoll:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200, // Feste Höhe für das Log
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: SingleChildScrollView(
                child: Text(
                  _logMessages.isEmpty ? 'Keine Aktivitäten...' : _logMessages,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gibt das passende Icon für den Berechtigungsstatus zurück
  IconData _getPermissionIcon(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Icons.check_circle;
      case 'denied':
        return Icons.cancel;
      case 'default':
        return Icons.help_outline;
      default:
        return Icons.error_outline;
    }
  }

  /// Gibt die passende Farbe für den Berechtigungsstatus zurück
  Color _getPermissionColor(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Colors.green;
      case 'denied':
        return Colors.red;
      case 'default':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Gibt den passenden Text für den Berechtigungsstatus zurück
  String _getPermissionText(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return 'Berechtigung erteilt';
      case 'denied':
        return 'Berechtigung verweigert';
      case 'default':
        return 'Berechtigung nicht angefragt';
      default:
        return 'Unbekannter Status';
    }
  }
}
