import 'package:flutter/material.dart';
import 'package:gsd_utilities/gsd_utilities.dart';

/// Beispiel-Widget für die Demonstration des GSDUriManager
class UriExample extends StatefulWidget {
  const UriExample({super.key});

  @override
  State<UriExample> createState() => _UriExampleState();
}

class _UriExampleState extends State<UriExample> {
  /// URI-Manager-Instanz
  final GSDUriManager _uriManager = GSDUriManager();

  /// Aktuelle URI als Text
  String _currentUri = '';

  /// Query-Parameter der aktuellen URI
  Map<String, String> _queryParameters = {};

  /// Titel-Controller
  final TextEditingController _titleController = TextEditingController();

  /// Query-Parameter-Schlüssel Controller
  final TextEditingController _keyController = TextEditingController();

  /// Query-Parameter-Wert Controller
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUri();
    _titleController.text = 'URI Manager Demo';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Lädt die aktuelle URI aus dem Browser
  void _loadCurrentUri() {
    setState(() {
      final currentUri = _uriManager.getCurrentUri();
      _currentUri = currentUri.toString();
      _queryParameters = _uriManager.getAllQueryParameters();
    });
  }

  /// Aktualisiert den Seitentitel
  void _updateTitle() {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      _uriManager.updateTitle(title);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Titel aktualisiert auf: "$title"')),
      );
    }
  }

  /// Fügt Query-Parameter zur aktuellen URI hinzu
  void _addQueryParameter() {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte geben Sie einen Schlüssel ein')),
      );
      return;
    }

    // Parameter über URI Manager setzen
    _uriManager.setQueryParameter(key, value);
    _loadCurrentUri(); // URI neu laden

    _keyController.clear();
    _valueController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Query-Parameter "$key" hinzugefügt')),
    );
  }

  /// Entfernt einen Query-Parameter aus der URI
  void _removeQueryParameter() {
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte geben Sie einen Schlüssel ein')),
      );
      return;
    }

    // Prüfen ob Parameter existiert
    if (_uriManager.getQueryParameter(key) != null) {
      _uriManager.removeQueryParameter(key);
      _loadCurrentUri(); // URI neu laden

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Query-Parameter "$key" entfernt')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Query-Parameter "$key" nicht gefunden')),
      );
    }

    _keyController.clear();
  }

  /// Setzt die URI komplett zurück (entfernt alle Parameter)
  void _resetUri() {
    _uriManager.resetUri();
    _loadCurrentUri(); // URI neu laden

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('URI zurückgesetzt - alle Parameter entfernt')),
    );
  }

  /// Lädt einen spezifischen Parameter-Wert und zeigt ihn an
  void _loadSpecificParameter() {
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte geben Sie einen Schlüssel ein')),
      );
      return;
    }

    final value = _uriManager.getQueryParameter(key);
    if (value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parameter "$key": "$value"')),
      );
      _valueController.text = value;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parameter "$key" nicht gefunden')),
      );
    }
  }

  /// Demo-Parameter-Sets laden
  void _loadDemoParameters(String demoType) {
    Map<String, String> demoParams;

    switch (demoType) {
      case 'simple':
        demoParams = {'page': '1', 'sort': 'name'};
        break;
      case 'search':
        demoParams = {
          'q': 'flutter',
          'category': 'development',
          'sort': 'relevance',
          'filter': 'recent'
        };
        break;
      case 'user':
        demoParams = {
          'userId': '12345',
          'profile': 'public',
          'tab': 'projects',
          'theme': 'dark'
        };
        break;
      default:
        demoParams = {};
    }

    _uriManager.setQueryParameters(demoParams);
    _loadCurrentUri(); // URI neu laden

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Demo-Parameter "$demoType" geladen')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URI Manager Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aktuelle URI Anzeige
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aktuelle Browser-URI:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _currentUri,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      if (_queryParameters.isNotEmpty) ...[
                        const Text(
                          'Query-Parameter:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ..._queryParameters.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text('• ${entry.key}: ${entry.value}'),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 16),
                                  onPressed: () {
                                    _uriManager.removeQueryParameter(entry.key);
                                    _loadCurrentUri();
                                  },
                                  tooltip: 'Parameter entfernen',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else
                        const Text('Keine Query-Parameter vorhanden'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _loadCurrentUri,
                        icon: const Icon(Icons.refresh),
                        label: const Text('URI neu laden'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Titel-Update Sektion
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seitentitel aktualisieren:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Neuer Titel',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _updateTitle,
                        child: const Text('Titel aktualisieren'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Query-Parameter Manipulation
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Query-Parameter bearbeiten:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _keyController,
                              decoration: const InputDecoration(
                                labelText: 'Parameter-Schlüssel',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _valueController,
                              decoration: const InputDecoration(
                                labelText: 'Wert',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _addQueryParameter,
                            icon: const Icon(Icons.add),
                            label: const Text('Hinzufügen'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _removeQueryParameter,
                            icon: const Icon(Icons.remove),
                            label: const Text('Entfernen'),
                          ),
                          ElevatedButton.icon(
                            onPressed: _loadSpecificParameter,
                            icon: const Icon(Icons.search),
                            label: const Text('Wert laden'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // URI Reset und Demo-Parameter
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'URI-Operationen:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // URI Reset
                      ElevatedButton.icon(
                        onPressed: _resetUri,
                        icon: const Icon(Icons.clear_all),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        label: const Text(
                            'URI zurücksetzen (alle Parameter entfernen)'),
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Demo-Parameter laden:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () => _loadDemoParameters('simple'),
                            child: const Text('Einfach (page, sort)'),
                          ),
                          ElevatedButton(
                            onPressed: () => _loadDemoParameters('search'),
                            child: const Text('Suche (q, category, etc.)'),
                          ),
                          ElevatedButton(
                            onPressed: () => _loadDemoParameters('user'),
                            child:
                                const Text('Benutzer (userId, profile, etc.)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // API Informationen
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API-Features:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          '✅ getCurrentUri() - Aktuelle Browser-URI abrufen'),
                      const Text(
                          '✅ resetUri() - Alle Query-Parameter entfernen'),
                      const Text(
                          '✅ setQueryParameter(key, value) - Parameter hinzufügen/bearbeiten'),
                      const Text(
                          '✅ getQueryParameter(key) - Spezifischen Parameter abrufen'),
                      const Text(
                          '✅ getAllQueryParameters() - Alle Parameter als Map'),
                      const Text(
                          '✅ removeQueryParameter(key) - Parameter entfernen'),
                      const Text('✅ updateTitle(title) - Browser-Titel ändern'),
                      const Text(
                          '✅ Live-Update der Browser-URL ohne Seitenreload'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
