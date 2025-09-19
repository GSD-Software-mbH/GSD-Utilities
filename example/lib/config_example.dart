import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gsd_utilities/gsd_utilities.dart';

/// Example-Screen für Konfigurationsmanagement
/// Demonstriert das Laden, Speichern und Überwachen von Konfigurationen
class ConfigExampleScreen extends StatefulWidget {
  const ConfigExampleScreen({super.key});

  @override
  State<ConfigExampleScreen> createState() => _ConfigExampleScreenState();
}

class _ConfigExampleScreenState extends State<ConfigExampleScreen> {
  late GSDConfigManager _configManager;
  AppExampleConfig? _currentConfig;
  String _logMessages = '';
  bool _isLoading = false;

  // Form Controllers
  final _serverUrlController = TextEditingController();
  final _timeoutController = TextEditingController();
  bool _debugMode = false;

  @override
  void initState() {
    super.initState();
    _configManager = GSDConfigManager(key: "example_app_config");
    _loadConfiguration();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _timeoutController.dispose();
    _currentConfig?.configChangedEvent.unsubscribeAll();
    super.dispose();
  }

  /// Lädt die Konfiguration aus dem persistenten Speicher
  Future<void> _loadConfiguration() async {
    setState(() {
      _isLoading = true;
      _logMessages += 'Lade Konfiguration...\n';
    });

    try {
      final configResult = await _configManager.loadConfig(AppExampleConfig());

      setState(() {
        _logMessages += 'Konfiguration geladen:\n';
        _logMessages += 'Erfolg: ${configResult.isSuccess}\n';
        _logMessages += 'Log: ${configResult.log}\n';

        if (configResult.isSuccess && configResult.config != null) {
          _currentConfig = configResult.config as AppExampleConfig;
        } else {
          _currentConfig = null;
        }
      });
    } catch (e) {
      setState(() {
        _logMessages += 'Fehler beim Laden: $e\n\n';
      });
    } finally {
      setState(() {
        if (_currentConfig == null) {
          _logMessages += 'Erstelle neue Konfiguration\n';
          _currentConfig = AppExampleConfig();
          _setupConfigEventListener();
          _logMessages += 'Setze Standardwerte\n';
          _setDefaultValues();
          _configManager.saveConfig(_currentConfig!);
          _logMessages += 'Konfiguration gespeichert\n';
        }

        _updateFormFields();

        _logMessages += 'Konfiguration: ${_currentConfig!.toString()}\n\n';

        _isLoading = false;
      });
    }
  }

  /// Aktualisiert die Formularfelder mit den geladenen Werten
  void _updateFormFields() {
    if (_currentConfig != null) {
      _serverUrlController.text = _currentConfig!.serverUrl ?? '';
      _timeoutController.text = _currentConfig!.timeout?.toString() ?? '';
      _debugMode = _currentConfig!.debugMode ?? false;
    }
  }

  /// Setzt Standardwerte für neue Konfiguration
  void _setDefaultValues() {
    _currentConfig?.serverUrl = 'https://api.example.com';
    _currentConfig?.timeout = 30;
    _currentConfig?.debugMode = true;
  }

  /// Richtet Event-Listener für Konfigurationsänderungen ein
  void _setupConfigEventListener() {
    _currentConfig?.configChangedEvent.subscribe((args) async {
      setState(() {
        _logMessages += 'Konfiguration automatisch gespeichert!\n\n';
      });
    });
  }

  /// Speichert die aktuelle Konfiguration
  void _saveConfiguration() {
    if (_currentConfig != null) {
      _currentConfig!.serverUrl = _serverUrlController.text;
      _currentConfig!.timeout = int.tryParse(_timeoutController.text);
      _currentConfig!.debugMode = _debugMode;

      setState(() {
        _logMessages += 'Speichere Konfiguration...\n';
      });

      _currentConfig!.save(); // Löst automatisch das Event aus
    }
  }

  /// Löscht die Log-Nachrichten
  void _clearLogs() {
    setState(() {
      _logMessages = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfigurationsmanagement'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                                      Icon(Icons.info_outline,
                                          color: Colors.blue.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Konfigurationsmanagement',
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
                                    'Diese Demo zeigt plattformübergreifende Konfigurationsverwaltung:\n'
                                    '• Web: Verschlüsselter LocalStorage\n'
                                    '• Mobile/Desktop: FlutterSecureStorage\n'
                                    '• Automatische Event-basierte Speicherung',
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Konfigurationsformular
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Konfiguration bearbeiten',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),

                                  // Server URL
                                  TextField(
                                    controller: _serverUrlController,
                                    decoration: const InputDecoration(
                                      labelText: 'Server URL',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.link),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Timeout
                                  TextField(
                                    controller: _timeoutController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Timeout (Sekunden)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.timer),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Debug Mode
                                  SwitchListTile(
                                    title: const Text('Debug-Modus'),
                                    subtitle: const Text(
                                        'Aktiviert erweiterte Protokollierung'),
                                    value: _debugMode,
                                    onChanged: (value) {
                                      setState(() {
                                        _debugMode = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _saveConfiguration,
                                  icon: const Icon(Icons.save),
                                  label: const Text('Speichern'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _loadConfiguration,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Neu laden'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Log-Bereich
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Debug-Log',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextButton.icon(
                                        onPressed: _clearLogs,
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
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Text(
                                        _logMessages.isEmpty
                                            ? 'Keine Log-Nachrichten'
                                            : _logMessages,
                                        style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12),
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

/// Beispiel-Konfigurationsklasse
/// Demonstriert die Implementierung einer eigenen Konfiguration
class AppExampleConfig extends GSDBaseConfig {
  String? serverUrl;
  int? timeout;
  bool? debugMode;

  AppExampleConfig({this.serverUrl, this.timeout, this.debugMode});

  @override
  String toJson() {
    final map = {
      'serverUrl': serverUrl,
      'timeout': timeout,
      'debugMode': debugMode,
    };
    return jsonEncode(map);
  }

  @override
  void loadFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString);
      serverUrl = data['serverUrl'];
      timeout = data['timeout'];
      debugMode = data['debugMode'];
    } catch (e) {
      // Bei Fehlern Standardwerte verwenden
      serverUrl = null;
      timeout = null;
      debugMode = null;
    }
  }

  @override
  GSDBaseConfig createInstance() => AppExampleConfig();

  @override
  String toString() {
    return 'AppExampleConfig{serverUrl: $serverUrl, timeout: $timeout, debugMode: $debugMode}';
  }
}
