import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gsd_utilities/gsd_utilities.dart';
import 'package:gsd_restapi/gsd_restapi.dart';

/// Example-Screen für DOCUframe Upload-Management
/// Demonstriert DOCUframeUploadManager mit Progress-Tracking
class UploadExampleScreen extends StatefulWidget {
  const UploadExampleScreen({super.key});

  @override
  State<UploadExampleScreen> createState() => _UploadExampleScreenState();
}

class _UploadExampleScreenState extends State<UploadExampleScreen> {
  final List<GSDUploadFile> _uploadQueue = [];
  final List<GSDUploadFileResult> _completedUploads = [];
  final _accountForm = GlobalKey<FormState>();
  String _uploadLog = '';
  bool _isUploading = false;

  // DOCUframe-Konfiguration
  DOCUframeUploadManager? _uploadManager;
  bool _isConfigured = false;

  // Konfigurationsfelder
  final TextEditingController _urlController =
      TextEditingController(text: 'https://demo.docuframe.com');
  final TextEditingController _aliasController =
      TextEditingController(text: 'gsd');
  final TextEditingController _usernameController =
      TextEditingController(text: 'demo');
  final TextEditingController _passwordController =
      TextEditingController(text: '');
  final TextEditingController _appnameController =
      TextEditingController(text: 'gsd-restapi');
  bool _allowSslError = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _addToLog('DOCUframe Upload Manager Demo gestartet');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _aliasController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _appnameController.dispose();
    super.dispose();
  }

  /// Überprüft die DOCUframe-Verbindung
  Future<void> _checkDOCUframeConnection() async {
    setState(() {
      _isChecking = true;
    });

    _addToLog('DOCUframe-Verbindung wird überprüft...');

    try {
      // Erstelle temporären RestApi Manager für Check
      final restApiManager = RestApiDOCUframeManager(
        config: RestApiDOCUframeConfig(
          appKey: "123",
          userName: _usernameController.text,
          appNames: [_appnameController.text],
          serverUrl: _urlController.text,
          alias: _aliasController.text,
          allowSslError: _allowSslError,
          device: RestApiDevice('gsd_utilities_example_app'),
        ),
      );

      // Führe Check-Service aus
      final checkResult = await restApiManager.checkService();

      if (checkResult.isOk) {
        _addToLog('✅ DOCUframe-Service erreichbar');

        final loginResult =
            await restApiManager.login(_passwordController.text);

        if (loginResult.isOk) {
          _addToLog('✅ Login erfolgreich als ${_usernameController.text}');
          _configureDOCUframe(restApiManager);
        } else {
          _addToLog('❌ Login fehlgeschlagen: ${loginResult.statusMessage}');
          _showErrorDialog('Login fehlgeschlagen',
              'Fehler: ${loginResult.statusMessage}\nBitte überprüfen Sie die Zugangsdaten.');
          setState(() {
            _isChecking = false;
          });
          return;
        }
      } else {
        _addToLog(
            '❌ DOCUframe-Service nicht erreichbar: ${checkResult.httpResponse.statusCode}');
        _showErrorDialog('Verbindung fehlgeschlagen',
            'Der DOCUframe-Service ist nicht erreichbar.\nStatus: ${checkResult.httpResponse.statusCode}\nBitte überprüfen Sie die Konfiguration.');
      }
    } catch (e) {
      _addToLog('❌ Fehler beim Verbindungstest: $e');
      _showErrorDialog('Verbindungsfehler', 'Fehler beim Verbindungstest:\n$e');
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  /// Zeigt einen Fehler-Dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Konfiguriert die DOCUframe-Verbindung
  void _configureDOCUframe(RestApiDOCUframeManager restApiManager) {
    try {
      // Erstelle Upload Manager
      _uploadManager = DOCUframeUploadManager(
        restApiManager,
        progressCheckInterval: const Duration(seconds: 1),
      );

      setState(() {
        _isConfigured = true;
      });

      _addToLog('DOCUframe-Verbindung erfolgreich konfiguriert');
      _addToLog('Server: ${_urlController.text}');
      _addToLog('Username: ${_usernameController.text}');
    } catch (e) {
      _addToLog('Fehler bei DOCUframe-Konfiguration: $e');
    }
  }

  /// Öffnet File-Picker und fügt Dateien zur Upload-Queue hinzu
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true, // Wichtig für Web-Plattform
      );

      if (result != null && result.files.isNotEmpty) {
        for (final platformFile in result.files) {
          GSDUploadFile uploadFile;

          if (!kIsWeb) {
            uploadFile = GSDUploadFile.fromPath(platformFile.path!);
          } else {
            uploadFile =
                GSDUploadFile.fromBytes(platformFile.bytes!, platformFile.name);
          }

          setState(() {
            _uploadQueue.add(uploadFile);
          });

          _addToLog(
              'Datei hinzugefügt: ${uploadFile.name} (${_formatFileSize(uploadFile.size)})');
        }

        _addToLog(
            '${result.files.length} Datei(en) zur Upload-Queue hinzugefügt');
      }
    } catch (e) {
      _addToLog('Fehler beim Datei-Auswahl: $e');
    }
  }

  /// Erstellt eine Demo-Datei für Test-Zwecke
  void _addDemoFile() {
    final demoContent =
        'Demo-Datei für DOCUframe Upload\nErstellt am: ${DateTime.now()}\nDies ist eine Test-Datei für den DOCUframe Upload Manager.';
    final demoBytes = Uint8List.fromList(demoContent.codeUnits);
    final fileName =
        'docuframe_demo_${DateTime.now().millisecondsSinceEpoch}.txt';

    GSDUploadFile uploadFile;

    if (kIsWeb) {
      uploadFile = GSDUploadFile.fromBytes(demoBytes, fileName);
    } else {
      // Für Mobile/Desktop: Erstelle temporäre Datei
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$fileName');
      tempFile.writeAsBytesSync(demoBytes);

      uploadFile = GSDUploadFile.fromPath(tempFile.path);
    }

    setState(() {
      _uploadQueue.add(uploadFile);
    });

    _addToLog(
        'Demo-Datei hinzugefügt: ${uploadFile.name} (${_formatFileSize(uploadFile.size)})');
  }

  /// Startet den DOCUframe Upload-Prozess
  Future<void> _startUpload() async {
    if (!_isConfigured || _uploadManager == null) {
      _addToLog('DOCUframe muss zuerst konfiguriert werden');
      return;
    }

    if (_uploadQueue.isEmpty) {
      _addToLog('Keine Dateien in der Upload-Queue');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    _addToLog(
        'DOCUframe Upload gestartet für ${_uploadQueue.length} Datei(en)...');

    // Set zum Tracken bereits verarbeiteter Dateien
    final Set<String> processedFiles = {};

    try {
      // Kopie der Upload-Queue erstellen
      final filesToUpload = List<GSDUploadFile>.from(_uploadQueue);

      // DOCUframe Upload mit Progress-Stream
      await for (final progress in _uploadManager!.uploadFiles(filesToUpload)) {
        _addToLog(
            'Upload-Fortschritt: ${progress.percentage}% (${progress.completedFiles}/${progress.totalFiles})');

        // Verarbeite jeden Datei-Progress
        for (int i = 0; i < progress.uploadFileProgresses.length; i++) {
          final fileProgress = progress.uploadFileProgresses[i];
          final file = fileProgress.uploadFile;
          final fileId = file.uuid; // Eindeutige ID der Datei

          switch (fileProgress.status) {
            case GSDUploadFileStatus.notStarted:
              _addToLog('📄 ${file.name}: Wartet...');
              break;
            case GSDUploadFileStatus.inProgress:
              _addToLog(
                  '⏳ ${file.name}: Upload läuft... (${_formatFileSize(fileProgress.uploadedBytes)}/${_formatFileSize(file.size)})');
              break;
            case GSDUploadFileStatus.completed:
              // Prüfe ob diese Datei bereits verarbeitet wurde
              if (!processedFiles.contains(fileId) &&
                  fileProgress.result != null &&
                  fileProgress.result!.success) {
                _addToLog(
                    '✅ ${file.name}: Upload erfolgreich (OID: ${fileProgress.result!.oid})');

                // Markiere als verarbeitet und verschiebe zu completed
                processedFiles.add(fileId);
                setState(() {
                  _completedUploads.add(fileProgress.result!);
                  _uploadQueue.removeWhere((f) => f.uuid == fileId);
                });
              }
              break;
            case GSDUploadFileStatus.failed:
              // Prüfe ob diese Datei bereits verarbeitet wurde
              if (!processedFiles.contains(fileId) &&
                  fileProgress.result != null) {
                _addToLog(
                    '❌ ${file.name}: Upload fehlgeschlagen - ${fileProgress.result!.error}');

                // Markiere als verarbeitet und verschiebe zu completed (auch fehlgeschlagene)
                processedFiles.add(fileId);
                setState(() {
                  _completedUploads.add(fileProgress.result!);
                  _uploadQueue.removeWhere((f) => f.uuid == fileId);
                });
              }
              break;
          }
        }
      }
    } catch (e) {
      _addToLog('Upload-Fehler: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
      _addToLog('DOCUframe Upload-Prozess abgeschlossen');
    }
  }

  /// Entfernt eine Datei aus der Upload-Queue
  void _removeFromQueue(GSDUploadFile file) {
    setState(() {
      _uploadQueue.removeWhere((f) => f.uuid == file.uuid);
    });
    _addToLog('Datei aus Queue entfernt: ${file.name}');
  }

  /// Löscht die Upload-Queue
  void _clearQueue() {
    setState(() {
      _uploadQueue.clear();
    });
    _addToLog('Upload-Queue geleert');
  }

  /// Löscht abgeschlossene Uploads
  void _clearCompleted() {
    setState(() {
      _completedUploads.clear();
    });
    _addToLog('Abgeschlossene Uploads geleert');
  }

  /// Fügt eine Nachricht zum Upload-Log hinzu
  void _addToLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toLocal().toString().substring(11, 19);
      _uploadLog += '[$timestamp] $message\n';
    });
  }

  /// Löscht das Upload-Log
  void _clearLog() {
    setState(() {
      _uploadLog = '';
    });
  }

  /// Formatiert Dateigröße in lesbarem Format
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Gibt das Status-Icon für Upload-Status zurück
  IconData _getStatusIcon(bool success) {
    return success ? Icons.check_circle : Icons.error;
  }

  /// Gibt die Status-Farbe für Upload-Status zurück
  Color _getStatusColor(bool success) {
    return success ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOCUframe Upload Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info-Card
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.cloud_upload,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'DOCUframe Upload Manager Demo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Diese Demo zeigt den DOCUframeUploadManager:\n'
                              '• Enterprise-Integration mit DOCUframe\n'
                              '• Stream-basiertes Progress-Tracking\n'
                              '• Automatische Bildoptimierung\n'
                              '• Batch-Upload mit detailliertem Status',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DOCUframe-Konfiguration
                    Form(
                      key: _accountForm,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'DOCUframe-Konfiguration',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_isConfigured)
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Server URL
                              TextFormField(
                                controller: _urlController,
                                enabled: !_isConfigured,
                                decoration: const InputDecoration(
                                  labelText: 'Server URL',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.link),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Alias und Username
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _aliasController,
                                      enabled: !_isConfigured,
                                      decoration: const InputDecoration(
                                        labelText: 'Alias',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.alternate_email),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _usernameController,
                                      enabled: !_isConfigured,
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Passwort
                              TextFormField(
                                controller: _passwordController,
                                enabled: !_isConfigured,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Passwort',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.lock),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Appname
                              TextFormField(
                                controller: _appnameController,
                                enabled: !_isConfigured,
                                decoration: const InputDecoration(
                                  labelText: 'Appname',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.apps),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Allow SSL Error Checkbox
                              CheckboxListTile(
                                title: const Text('SSL-Fehler ignorieren'),
                                subtitle: const Text(
                                    'Aktivieren für Entwicklung/Test-Umgebungen'),
                                value: _allowSslError,
                                enabled: !_isConfigured,
                                onChanged: (value) {
                                  setState(() {
                                    _allowSslError = value ?? false;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),

                              // Konfigurieren Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: (_isConfigured || _isChecking)
                                      ? null
                                      : () {
                                          if (!_accountForm.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          _checkDOCUframeConnection();
                                        },
                                  icon: _isChecking
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.settings),
                                  label: Text(_isConfigured
                                      ? 'Konfiguriert'
                                      : _isChecking
                                          ? 'Verbindung prüfen...'
                                          : 'DOCUframe konfigurieren'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: (_isUploading || !_isConfigured)
                                        ? null
                                        : _pickFiles,
                                    icon: const Icon(Icons.file_open),
                                    label: const Text('Dateien wählen'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: (_isUploading || !_isConfigured)
                                        ? null
                                        : _addDemoFile,
                                    icon: const Icon(Icons.note_add),
                                    label: const Text('Demo-Datei'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isUploading ||
                                            _uploadQueue.isEmpty ||
                                            !_isConfigured
                                        ? null
                                        : _startUpload,
                                    icon: _isUploading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : const Icon(Icons.cloud_upload),
                                    label: Text(_isUploading
                                        ? 'Uploading...'
                                        : 'DOCUframe Upload'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        _isUploading ? null : _clearQueue,
                                    icon: const Icon(Icons.clear_all),
                                    label: const Text('Queue leeren'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
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

                    // Upload Queue
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upload-Queue (${_uploadQueue.length})',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (_uploadQueue.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Keine Dateien in der Upload-Queue',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ..._uploadQueue.map((file) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Icon(
                                        file.isImage
                                            ? Icons.image
                                            : Icons.insert_drive_file,
                                        color: Colors.blue,
                                      ),
                                      title: Text(file.name),
                                      subtitle:
                                          Text(_formatFileSize(file.size)),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.remove_circle,
                                            color: Colors.red),
                                        onPressed: _isUploading
                                            ? null
                                            : () => _removeFromQueue(file),
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Completed Uploads
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Abgeschlossene Uploads (${_completedUploads.length})',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (_completedUploads.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: _clearCompleted,
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Löschen'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_completedUploads.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Noch keine abgeschlossenen Uploads',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ..._completedUploads.map((result) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Icon(
                                        _getStatusIcon(result.success),
                                        color: _getStatusColor(result.success),
                                      ),
                                      title: Text(result.uploadFile.name),
                                      subtitle: Text(
                                        result.success
                                            ? 'Upload erfolgreich (OID: ${result.oid})'
                                            : 'Fehler: ${result.error}',
                                        style: TextStyle(
                                          color:
                                              _getStatusColor(result.success),
                                        ),
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Upload-Log
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Upload-Log',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextButton.icon(
                                  onPressed: _clearLog,
                                  icon: const Icon(Icons.clear, size: 16),
                                  label: const Text('Löschen'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 200,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  _uploadLog.isEmpty
                                      ? 'Keine Log-Nachrichten'
                                      : _uploadLog,
                                  style: const TextStyle(
                                      fontFamily: 'monospace', fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
