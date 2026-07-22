import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gsd_utilities/gsd_utilities.dart';

/// Example-Screen für LocalStorage-Management
/// Demonstriert das Speichern, Laden und Überwachen von Storage-Events
class StorageExampleScreen extends StatefulWidget {
  const StorageExampleScreen({super.key});

  @override
  State<StorageExampleScreen> createState() => _StorageExampleScreenState();
}

class _StorageExampleScreenState extends State<StorageExampleScreen> {
  late GSDLocalStorageManager _storageManager;
  final List<StorageItem> _storageItems = [];
  String _eventLog = '';

  // Form Controllers
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  // Demo-Counter für automatische Events
  int _demoCounter = 0;
  bool _autoEventsEnabled = false;

  @override
  void initState() {
    super.initState();
    _storageManager = GSDLocalStorageManager();
    _setupStorageEventListener();
    _loadAllStorageItems();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Richtet Event-Listener für Storage-Änderungen ein
  void _setupStorageEventListener() {
    _storageManager.storageChanged.subscribe((args) async {
      try {
        String log = 'Storage Event empfangen:\n';
        log += '  Key: ${args.key}\n';
        log += '  Neuer Wert: ${args.value}\n';
        log += '  Zeitstempel: ${DateTime.now().toLocal()}\n\n';

        _addToEventLog(log);

        // Liste aktualisieren
        _loadAllStorageItems();
      } catch (e, stackTrace) {
        _addToEventLog('Fehler beim Verarbeiten des Storage-Events: $e');
        _addToEventLog('Stack trace: $stackTrace');
      }
    });
  }

  void _loadAllStorageItems() {
    final knownItems = _storageManager.getAllItems();

    final items = <StorageItem>[];

    for (final entry in knownItems.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.isNotEmpty) {
        items.add(StorageItem(key: key, value: value));
      }
    }

    setState(() {
      _storageItems.clear();
      _storageItems.addAll(items);
    });
  }

  /// Speichert einen neuen Wert im LocalStorage
  void _saveValue() {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty || value.isEmpty) {
      _showSnackBar('Bitte geben Sie sowohl Key als auch Value ein');
      return;
    }

    try {
      _storageManager.writeData(key, value);
      _keyController.clear();
      _valueController.clear();
      _showSnackBar('Wert erfolgreich gespeichert');
      _loadAllStorageItems();
    } catch (e) {
      _addToEventLog('Fehler beim Speichern: $e');
    }
  }

  /// Löscht einen Wert aus dem LocalStorage (durch Überschreiben mit leerem String)
  void _deleteValue(String key) {
    try {
      _storageManager.writeData(key, '');
      _showSnackBar('Wert "$key" gelöscht');
      _loadAllStorageItems();
    } catch (e) {
      _addToEventLog('Fehler beim Löschen: $e');
    }
  }

  /// Löscht alle bekannten Werte aus dem LocalStorage
  void _clearAllValues() {
    try {
      for (final item in _storageItems) {
        _storageManager.writeData(item.key, '');
      }
      _showSnackBar('Alle Werte gelöscht');
      _loadAllStorageItems();
    } catch (e) {
      _addToEventLog('Fehler beim Löschen aller Werte: $e');
    }
  }

  /// Startet/Stoppt automatische Demo-Events für Cross-Tab-Tests
  void _toggleAutoEvents() {
    setState(() {
      _autoEventsEnabled = !_autoEventsEnabled;
    });

    if (_autoEventsEnabled) {
      _startAutoEvents();
    }
  }

  /// Startet automatische Events für Demo-Zwecke
  void _startAutoEvents() async {
    while (_autoEventsEnabled && mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (_autoEventsEnabled && mounted) {
        _demoCounter++;
        final key = 'demo_auto_${Random().nextInt(3) + 1}';
        final value =
            'Automatischer Wert #$_demoCounter (${DateTime.now().toLocal()})';

        try {
          _storageManager.writeData(key, value);
          _loadAllStorageItems();
        } catch (e) {
          _addToEventLog('Fehler beim automatischen Event: $e');
        }
      }
    }
  }

  /// Fügt eine Nachricht zum Event-Log hinzu
  void _addToEventLog(String message) {
    setState(() {
      _eventLog += '$message\n\n';
    });
  }

  /// Löscht das Event-Log
  void _clearEventLog() {
    setState(() {
      _eventLog = '';
    });
  }

  /// Zeigt eine SnackBar-Nachricht an
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalStorage Management'),
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
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.storage,
                                    color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'LocalStorage mit Events',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Diese Demo zeigt verschlüsselte Datenspeicherung mit Event-System:\n'
                              '• Cross-Tab Storage Events (nur Web)\n'
                              '• Automatische Event-Übertragung\n'
                              '• Sichere Verschlüsselung der Daten',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Eingabeformular
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Neuen Wert hinzufügen',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Key Input
                            TextField(
                              controller: _keyController,
                              decoration: const InputDecoration(
                                labelText: 'Schlüssel (Key)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.key),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Value Input
                            TextField(
                              controller: _valueController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Wert (Value)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.text_fields),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _saveValue,
                                    icon: const Icon(Icons.save),
                                    label: const Text('Speichern'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _clearAllValues,
                                    icon: const Icon(Icons.delete_sweep),
                                    label: const Text('Alle löschen'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Auto-Events Toggle
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Automatische Demo-Events',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Erzeugt alle 3 Sekunden Test-Events für Cross-Tab-Demo',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _autoEventsEnabled,
                              onChanged: (_) => _toggleAutoEvents(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Gespeicherte Items
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gespeicherte Werte (${_storageItems.length})',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            if (_storageItems.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Keine gespeicherten Werte vorhanden',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ..._storageItems.map((item) => Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: const Icon(Icons.storage),
                                      title: Text(
                                        item.key,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        item.value,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _deleteValue(item.key),
                                      ),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Event-Log
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
                                  'Storage Event-Log',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextButton.icon(
                                  onPressed: _clearEventLog,
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
                                  _eventLog.isEmpty
                                      ? 'Keine Events empfangen.\n\nTipp: Öffnen Sie diese App in mehreren Browser-Tabs, um Cross-Tab Events zu testen!'
                                      : _eventLog,
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

/// Hilfsklasse für Storage-Items
class StorageItem {
  final String key;
  final String value;

  StorageItem({required this.key, required this.value});

  @override
  String toString() => 'StorageItem{key: $key, value: $value}';
}
