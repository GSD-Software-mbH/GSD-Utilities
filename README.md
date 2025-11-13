# GSD-Utilities

Dieses Paket bietet umfassende Utility-Funktionen für Flutter-Anwendungen mit plattformübergreifender Konfigurationsverwaltung, LocalStorage mit Cross-Tab-Events, fortschrittlicher Datei-Upload-Funktionalität und DOCUframe-Integration. Es ermöglicht die strukturierte Verwaltung von Anwendungsdaten sowohl für Web- als auch für Mobile/Desktop-Plattformen.

**👉 [Online-Demo ansehen](https://docs.gsd-software.com/Help/WebApp/flutterSDKdemo/gsd_utilities/index.html)**

## Features

- **Plattformübergreifende Konfigurationsverwaltung**: Automatische Plattformauswahl zwischen Web und Mobile/Desktop
- **Sichere Datenpersistierung**: Web mit verschlüsseltem LocalStorage, Mobile/Desktop mit FlutterSecureStorage
- **LocalStorage mit Events**: Cross-Tab-Kommunikation über JavaScript Interop
- **URI-Management**: Browser-URI-Manipulation
- **Web-Benachrichtigungen**: Browser-Notification-API mit Berechtigungsmanagement und Browser-Erkennung
- **File Upload System**: Real-time Fortschrittsverfolgung mit Byte-Level-Genauigkeit
- **Bildverarbeitung**: Automatische Bilderkennung und Größenanpassung
- **Batch-Upload**: Mehrere Dateien gleichzeitig hochladen
- **DOCUframe Integration**: Enterprise-Funktionen für DOCUframe-Systeme
- **Event-basierte Architektur**: Benachrichtigungen bei Datenänderungen
- **TypeScript-kompatibel**: JavaScript Interop für Web-Plattformen
- **Memory-effizient**: Automatisches Cleanup und Ressourcenverwaltung

## Installation

Fügen Sie das Paket in Ihrer `pubspec.yaml` hinzu:

```yaml
dependencies:
  gsd_utilities: [version]
```

Führen Sie anschließend `flutter pub get` aus, um das Paket zu installieren.

## Nutzung

### Konfigurationsmanagement

Erstellen Sie eine Konfigurationsklasse und verwalten Sie sie automatisch:

```dart
import 'package:gsd_utilities/gsd_utilities.dart';

// Eigene Konfigurationsklasse erstellen
class AppConfig extends GSDBaseConfig {
  String? serverUrl;
  int? timeout;
  bool? debugMode;

  AppConfig({this.serverUrl, this.timeout, this.debugMode});

  @override
  String toJson() {
    return '{"serverUrl": ${serverUrl != null ? '"$serverUrl"' : 'null'}, '
           '"timeout": $timeout, "debugMode": $debugMode}';
  }

  @override
  void loadFromJson(String jsonString) {
    final data = jsonDecode(jsonString);
    serverUrl = data['serverUrl'];
    timeout = data['timeout'];
    debugMode = data['debugMode'];
  }

  @override
  GSDBaseConfig createInstance() => AppConfig();
}

// Konfiguration laden und verwalten
final configManager = GSDConfigManager(key: "app_config");
final configResult = await configManager.loadConfig(AppConfig());

if (configResult.isSuccess && configResult.config != null) {
  print('Konfiguration geladen: ${configResult.config!.serverUrl}');
} else {
  print('Konfiguration konnte nicht geladen werden: ${configResult.log}');
}
```

### LocalStorage mit Cross-Tab-Events

Überwachen Sie LocalStorage-Änderungen zwischen Browser-Tabs:

```dart
// LocalStorage Manager erstellen
final localStorageManager = GSDLocalStorageManager();

// Storage-Events überwachen (nur Web)
localStorageManager.storageChanged.subscribe((GSDWebLocalStorageEventArgs args) async {
  print('Storage geändert von anderem Tab:');
  print('Key: ${args.key}, Neuer Wert: ${args.value}');
});

// Daten schreiben und lesen
localStorageManager.writeData('user_settings', '{"theme": "dark"}');
String settings = localStorageManager.readData('user_settings');
print('Geladene Einstellungen: $settings');
```

### URI-Management mit Browser History API

Verwalten Sie Browser-URIs und Query-Parameter ohne Seitenreload:

```dart
// URI Manager erstellen
final uriManager = GSDUriManager();

// Aktuelle Browser-URI abrufen
Uri currentUri = uriManager.getCurrentUri();
print('Aktuelle URI: $currentUri');

// Query-Parameter verwalten
uriManager.setQueryParameter('page', '1');
uriManager.setQueryParameter('filter', 'active');

// Mehrere Parameter gleichzeitig setzen
uriManager.setQueryParameters({
  'category': 'flutter',
  'sort': 'date',
  'view': 'grid'
});

// Parameter lesen
String? currentPage = uriManager.getQueryParameter('page');
Map<String, String> allParams = uriManager.getAllQueryParameters();

// Parameter entfernen
uriManager.removeQueryParameter('filter');

// Alle Parameter zurücksetzen
uriManager.resetUri();

// Browser-Titel ändern
uriManager.updateTitle('Meine Flutter App - Seite 1');

// Zu neuer URI navigieren
uriManager.navigateToUri(Uri.parse('https://example.com/newpage?tab=settings'));
```

### URI-Manager Features

```dart
// State-Management über URI
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GSDUriManager _uriManager = GSDUriManager();
  
  @override
  void initState() {
    super.initState();
    // State aus URI laden
    _loadStateFromUri();
  }
  
  void _loadStateFromUri() {
    final params = _uriManager.getAllQueryParameters();
    setState(() {
      searchQuery = params['q'] ?? '';
      selectedCategory = params['category'] ?? 'all';
      currentPage = int.tryParse(params['page'] ?? '1') ?? 1;
    });
  }
  
  void _updateSearch(String query) {
    // State in URI speichern
    _uriManager.setQueryParameter('q', query);
    _uriManager.setQueryParameter('page', '1'); // Reset zur ersten Seite
    _uriManager.updateTitle('Suche: $query');
    
    setState(() {
      searchQuery = query;
      currentPage = 1;
    });
  }
  
  void _changeCategory(String category) {
    _uriManager.setQueryParameter('category', category);
    _uriManager.setQueryParameter('page', '1');
    
    setState(() {
      selectedCategory = category;
      currentPage = 1;
    });
  }
}
```

### Web-Benachrichtigungen mit Browser-Erkennung

Senden Sie native Browser-Benachrichtigungen mit automatischer Browser-Erkennung:

```dart
import 'package:gsd_utilities/gsd_utilities.dart';

// Notification Helper erstellen
final notificationHelper = GSDNotificationsHelper();

// Browser-Information abrufen
print('Chrome Browser: ${notificationHelper.isChromeBrowser}');
print('Firefox Browser: ${notificationHelper.isFirefoxBrowser}');
print('Edge Browser: ${notificationHelper.isEdgeBrowser}');
print('Safari Browser: ${notificationHelper.isSafariBrowser}');

// Berechtigungsstatus prüfen
String permission = notificationHelper.notificationPermission;
print('Aktueller Status: $permission'); // 'default', 'granted', oder 'denied'

bool canSend = notificationHelper.isNotificationPermissionGranted;
bool isDenied = notificationHelper.isNotificationPermissionDenied;
bool isDefault = notificationHelper.isNotificationPermissionDefault;

// Berechtigung anfordern
if (notificationHelper.isNotificationPermissionDefault) {
  notificationHelper.requestNotificationPermission();
  
  // Nach kurzer Verzögerung Status prüfen
  await Future.delayed(Duration(milliseconds: 500));
  if (notificationHelper.isNotificationPermissionGranted) {
    print('Berechtigung erteilt!');
  }
}

// Benachrichtigung senden
if (notificationHelper.isNotificationPermissionGranted) {
  notificationHelper.showNotification(
    'GSD Utilities',
    'Benachrichtigung erfolgreich gesendet!'
  );
}

// Ressourcen aufräumen
notificationHelper.dispose();
```

### Notification Features

```dart
class NotificationService {
  final GSDNotificationsHelper _notificationHelper = GSDNotificationsHelper();
  
  // Berechtigung initialisieren
  Future<bool> initializeNotifications() async {
    if (_notificationHelper.isNotificationPermissionDefault) {
      _notificationHelper.requestNotificationPermission();
      
      // Warten auf Benutzer-Entscheidung
      await Future.delayed(Duration(seconds: 1));
    }
    
    return _notificationHelper.isNotificationPermissionGranted;
  }
  
  // Status-Updates senden
  void sendStatusUpdate(String title, String message) {
    if (_notificationHelper.isNotificationPermissionGranted) {
      _notificationHelper.showNotification(title, message);
    }
  }
  
  // Browser-spezifische Behandlung
  void handleBrowserSpecific() {
    if (_notificationHelper.isChromeBrowser) {
      // Chrome-spezifische Features
      print('Chrome Browser erkannt - alle Features verfügbar');
    } else if (_notificationHelper.isSafariBrowser) {
      // Safari hat einige Einschränkungen
      print('Safari Browser - eingeschränkte Notification-Features');
    }
  }
  
  void dispose() {
    _notificationHelper.dispose();
  }
}
```

### File Upload mit Fortschrittsverfolgung

Laden Sie Dateien mit Real-time-Fortschrittsanzeige hoch:

```dart
import 'package:gsd_restapi/gsd_restapi.dart';

// Upload Manager erstellen
final RestApiDOCUframeManager apiManager = RestApiDOCUframeManager(
  'GSD-DFApp', 'username', ['app1'], 'https://server.com', 'db'
);
final uploadManager = DOCUframeUploadManager(apiManager);

// Dateien für Upload vorbereiten
List<GSDUploadFile> files = [
  GSDUploadFile.fromPath('/path/to/document.pdf'),
  GSDUploadFile.fromPath('/path/to/image.jpg'),
];

// Upload mit Fortschrittsverfolgung starten
await for (GSDUploadProgress progress in uploadManager.uploadFiles(files)) {
  print('Gesamt-Fortschritt: ${progress.percentage}%');
  print('Abgeschlossene Dateien: ${progress.completedFiles.length}/${progress.totalFiles}');
  
  for (int i = 0; i < progress.uploadFileProgresses.length; i++) {
    final fileProgress = progress.uploadFileProgresses[i];
    print('Datei ${i + 1}: ${fileProgress.percentage}% - Status: ${fileProgress.status}');
  }
  
  if (progress.isFinished) {
    print('Alle Uploads abgeschlossen!');
    break;
  }
}
```

### Event-Handling

```dart
// Konfigurationsänderungen überwachen
config.configChangedEvent.subscribe((args) async {
  print('Konfiguration wurde automatisch gespeichert');
});

// Account-Änderungen überwachen
account.accountChanged.subscribe((args) async {
  print('Account-Daten wurden geändert');
});
```

## Konfigurationsarchitektur

Das Paket verwendet eine plattformspezifische Konfigurationsarchitektur:

### Web-Plattform
- **LocalStorage**: Browser-basierte Datenpersistierung
- **AES-Verschlüsselung**: Sichere Speicherung sensibler Daten
- **Storage-Events**: Cross-Tab-Kommunikation über JavaScript Interop

### Mobile/Desktop-Plattform
- **FlutterSecureStorage**: Systemspezifische sichere Speicherung
- **Platform-native**: Verwendet OS-eigene Sicherheitsmechanismen

## File Upload Features

### Unterstützte Dateitypen
- **Dokumente**: PDF, DOC, DOCX, TXT, etc.
- **Bilder**: PNG, JPEG, GIF, WebP (mit automatischer Komprimierung)
- **Archive**: ZIP, RAR, etc.
- **Web-Dateien**: Direkte Browser-Upload-Unterstützung

### Upload-Funktionen
```dart
// Bildkomprimierung konfigurieren
final uploadFile = GSDUploadFile.fromPath('/path/to/large_image.jpg');
uploadFile.setResolution(GSDUploadImageResolution(percentage: 75)); // 75% der Originalgröße

// Upload-Status überwachen
if (fileProgress.status == GSDUploadFileStatus.completed) {
  print('Upload erfolgreich! Server-ID: ${fileProgress.result?.oid}');
} else if (fileProgress.status == GSDUploadFileStatus.failed) {
  print('Upload fehlgeschlagen: ${fileProgress.result?.error}');
}
```

## DOCUframe Integration

Spezielle Enterprise-Funktionen für DOCUframe-Systeme:

```dart
// Account-Konfiguration
final account = DOCUframeAccount(
  'Mein Account',
  'https://docuframe.server.com',
  'account_alias',
  'username'
);

account.setDatabaseName('production_db');

// Account-Serialisierung
Map<String, dynamic> accountData = account.toJson();
DOCUframeAccount restoredAccount = DOCUframeAccount.fromJson(accountData);
```

## Error-Handling

Das Paket bietet umfassende Fehlerbehandlung:

```dart
try {
  final result = await configManager.loadConfig(AppConfig());
  if (!result.isSuccess) {
    print('Fehler beim Laden: ${result.error}');
    print('Debug-Log: ${result.log}');
  }
} catch (e) {
  print('Unerwarteter Fehler: $e');
}
```

## Performance und Memory Management

- **Automatisches Cleanup**: Event-Listener werden automatisch entfernt
- **Memory-effizient**: Große Dateien werden in Chunks verarbeitet
- **Background-Processing**: Uploads laufen im Hintergrund
- **Platform-optimiert**: Plattformspezifische Optimierungen

## API-Design

Das Paket folgt dem Prinzip der **sauberen Architektur**:

- ✅ `GSDConfigManager` - Hauptklasse für Konfigurationsverwaltung
- ✅ `GSDLocalStorageManager` - Plattformübergreifender Storage-Manager
- ✅ `GSDUriManager` - Browser-URI-Manipulation
- ✅ `DOCUframeUploadManager` - Upload-Funktionalität mit Fortschrittsverfolgung
- ✅ `GSDBaseConfig` - Abstrakte Basis für eigene Konfigurationsklassen
- ✅ `GSDUploadFile` - Datei-Repräsentation mit Metadaten
- ❌ `_GSDWebConfigManager` - Interne Web-Implementierung (nicht zugänglich)
- ❌ `_GSDAppConfigManager` - Interne Mobile-Implementierung (nicht zugänglich)
- ❌ `_GSDWebUriManager` - Interne Web-URI-Implementierung (nicht zugänglich)

## Plattform-Kompatibilität

| Feature | Web | Mobile | Desktop |
|---------|-----|--------|---------|
| Konfigurationsverwaltung | ✅ | ✅ | ✅ |
| LocalStorage | ✅ | ❌ | ❌ |
| Storage-Events | ✅ | ❌ | ❌ |
| URI-Management | ✅ | ❌ | ❌ |
| Web-Benachrichtigungen | ✅ | ❌* | ❌* |
| File-Upload | ✅ | ✅ | ✅ |
| Bildverarbeitung | ✅ | ✅ | ✅ |
| Secure Storage | ❌ | ✅ | ✅ |

*⚠️ Fallback-Implementierung verfügbar (eingeschränkte Funktionalität)*

## Hinweise

- **Automatische Plattformauswahl**: Das richtige Storage-System wird automatisch gewählt
- **Event-basiert**: Alle Änderungen werden über Events kommuniziert
- **Type-safe**: Vollständige TypeScript-Integration für Web-Plattformen
- **Memory-safe**: Automatisches Cleanup verhindert Memory-Leaks
- **Production-ready**: Umfassive Fehlerbehandlung und Logging
- **Browser-URI-Manipulation**: URI-Änderungen ohne Seitenreload (nur Web)
- **Native Browser-Notifications**: Verwendung der Browser Notification API (nur Web)
- **Browser-Erkennung**: Automatische Erkennung von Chrome, Firefox, Edge, Safari
- **Dokumentiert**: Alle Klassen und Methoden vollständig dokumentiert

### URI-Manager Spezifika

**Web-Plattform:**
- ✅ Browser History API (`history.replaceState()`)
- ✅ Document Title API (`document.title`)
- ✅ JavaScript Interop für native Browser-Integration
- ✅ Live-URL-Updates ohne Seitenreload

**Mobile/Desktop-Plattform:**
- ❌ Keine Funktionalität

### Notification-Helper Spezifika

**Web-Plattform:**
- ✅ Native Browser Notification API (`new Notification()`)
- ✅ Permission Management (`Notification.requestPermission()`)
- ✅ Browser-Erkennung (Chrome, Firefox, Edge, Safari)
- ✅ Automatisches Schließen nach 5 Sekunden
- ✅ Resource Management und Cleanup

**Mobile/Desktop-Plattform:**
- ❌ Dummy-Implementierung (UnimplementedError)
- ❌ Für native Platforms sollten plattformspezifische Notification-Plugins verwendet werden

Dieses Paket ermöglicht die professionelle Utility-Verwaltung in Ihrer Flutter-Anwendung und bietet umfassende Funktionen für Konfiguration, Storage, File-Upload und Enterprise-Integration bei gleichzeitig sauberer und plattformübergreifender API.
