import 'package:flutter/material.dart';
import 'package:gsd_utilities/gsd_utilities.dart';

/// Example-Screen für Multi-Language Management
/// Demonstriert das Laden, Wechseln und Verwenden von Sprachen
class MultiLanguageExampleScreen extends StatefulWidget {
  const MultiLanguageExampleScreen({super.key});

  @override
  State<MultiLanguageExampleScreen> createState() =>
      _MultiLanguageExampleScreenState();
}

class _MultiLanguageExampleScreenState
    extends State<MultiLanguageExampleScreen> {
  late GSDMultiLanguageProvider _languageProvider;
  String _logMessages = '';
  bool _isInitialized = false;

  // Test-Schlüssel für Demonstrationszwecke
  final List<String> _testKeys = [
    'welcome_message',
    'goodbye_message',
    'error_message',
    'success_message',
    'button_save',
    'button_cancel',
    'loading_text',
  ];

  @override
  void initState() {
    super.initState();
    _initializeLanguageProvider();
  }

  @override
  void dispose() {
    _languageProvider.dispose();
    super.dispose();
  }

  /// Initialisiert den Multi-Language Provider mit Test-Implementierungen
  Future<void> _initializeLanguageProvider() async {
    _logMessage('Initialisiere Multi-Language Provider...');

    try {
      // Erstelle Test-Implementierungen der Interfaces
      final dataProvider = _TestDataProvider();
      final configProvider = _TestConfigProvider();
      final analyticsProvider = _TestAnalyticsProvider();

      _languageProvider = GSDMultiLanguageProvider(
        dataProvider: dataProvider,
        configProvider: configProvider,
        analyticsProvider: analyticsProvider,
      );

      // Event-Handler registrieren
      _languageProvider.onLanguageChanged
          .subscribe((args) => _onLanguageChanged());
      _languageProvider.onError.subscribe((args) => _onLanguageError());

      // Provider initialisieren
      await _languageProvider.initialize();

      setState(() {
        _isInitialized = true;
      });

      _logMessage('✅ Multi-Language Provider erfolgreich initialisiert');
      _logMessage(
          '📋 Verfügbare Sprachen: ${_languageProvider.supportedLanguages.length}');
    } catch (e) {
      _logMessage('❌ Fehler bei der Initialisierung: $e');
    }
  }

  /// Event-Handler für Sprachwechsel
  void _onLanguageChanged() {
    final lang = _languageProvider.selectedLanguage;
    _logMessage('🔄 Sprache gewechselt zu: ${lang?.name} (${lang?.code})');
    setState(() {}); // UI aktualisieren
  }

  /// Event-Handler für Fehler
  void _onLanguageError() {
    _logMessage('⚠️ Fehler im Multi-Language Provider aufgetreten');
  }

  /// Wechselt zur nächsten verfügbaren Sprache
  Future<void> _switchToNextLanguage() async {
    if (_languageProvider.supportedLanguages.isEmpty) return;

    final currentIndex = _languageProvider.supportedLanguages.indexWhere(
        (lang) => lang.code == _languageProvider.selectedLanguage?.code);

    final nextIndex =
        (currentIndex + 1) % _languageProvider.supportedLanguages.length;
    final nextLanguage = _languageProvider.supportedLanguages[nextIndex];

    _logMessage('🔄 Wechsle zu Sprache: ${nextLanguage.name}...');
    await _languageProvider.setSelectedLanguage(nextLanguage);
  }

  /// Wechselt zu einer spezifischen Sprache anhand des Codes
  Future<void> _switchToLanguageByCode(String code) async {
    _logMessage('🔄 Wechsle zu Sprache mit Code: $code...');
    await _languageProvider.setLanguageByCode(code);
  }

  /// Aktualisiert die aktuellen Sprachdaten
  Future<void> _refreshLanguageData() async {
    _logMessage('🔄 Aktualisiere Sprachdaten...');
    await _languageProvider.refresh();
  }

  /// Testet verschiedene getText-Methoden
  void _testTextRetrieval() {
    _logMessage('🧪 Teste Text-Abruf:');

    for (String key in _testKeys) {
      final text = _languageProvider.getMLText(key);
      _logMessage('  • $key = "$text"');
    }

    // Test mit Standard-Wert
    final textWithDefault = _languageProvider.getMLText('nonexistent_key',
        defaultValue: 'Standard-Text');
    _logMessage('  • Mit Standard-Wert = "$textWithDefault"');

    // Test mit Parametern
    final paramText = _languageProvider.getTextWithParams(
        'welcome_message_with_params', ['Max Mustermann', '42']);
    _logMessage('  • Mit Parametern = "$paramText"');
  }

  /// Fügt eine Nachricht zum Log hinzu
  void _logMessage(String message) {
    setState(() {
      _logMessages +=
          '${DateTime.now().toLocal().toString().substring(11, 19)} $message\n';
    });
  }

  /// Leert das Log
  void _clearLog() {
    setState(() {
      _logMessages = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Language Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusSection(),
            const SizedBox(height: 16),
            _buildCurrentLanguageSection(),
            const SizedBox(height: 16),
            _buildActionsSection(),
            const SizedBox(height: 16),
            _buildLogSection(),
          ],
        ),
      ),
    );
  }

  /// Baut den Status-Bereich
  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.pending,
                  color: _isInitialized ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                    _isInitialized ? 'Initialisiert' : 'Wird initialisiert...'),
              ],
            ),
            if (_isInitialized) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _languageProvider.isLoading ? Icons.refresh : Icons.done,
                    color: _languageProvider.isLoading
                        ? Colors.blue
                        : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(_languageProvider.isLoading ? 'Lädt...' : 'Bereit'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Baut den Bereich für die aktuelle Sprache
  Widget _buildCurrentLanguageSection() {
    if (!_isInitialized) return const SizedBox.shrink();

    final currentLanguage = _languageProvider.selectedLanguage;
    final supportedLanguages = _languageProvider.supportedLanguages;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aktuelle Sprache',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (currentLanguage != null)
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: Text(currentLanguage.name),
                subtitle: Text(
                    'Code: ${currentLanguage.code} | ISO: ${currentLanguage.isocode}'),
                contentPadding: EdgeInsets.zero,
              )
            else
              const Text('Keine Sprache ausgewählt'),
            const SizedBox(height: 16),
            Text('Verfügbare Sprachen (${supportedLanguages.length}):'),
            const SizedBox(height: 8),
            ...supportedLanguages.map((lang) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        lang.code == currentLanguage?.code
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: lang.code == currentLanguage?.code
                            ? Colors.blue
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${lang.name} (${lang.code})')),
                      TextButton(
                        onPressed: () => _switchToLanguageByCode(lang.code),
                        child: const Text('Wählen'),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// Baut den Aktions-Bereich
  Widget _buildActionsSection() {
    if (!_isInitialized) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aktionen', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _languageProvider.isLoading
                      ? null
                      : _switchToNextLanguage,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Nächste Sprache'),
                ),
                ElevatedButton.icon(
                  onPressed:
                      _languageProvider.isLoading ? null : _refreshLanguageData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aktualisieren'),
                ),
                ElevatedButton.icon(
                  onPressed: _testTextRetrieval,
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Text-Abruf testen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Baut den Log-Bereich
  Widget _buildLogSection() {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Log-Nachrichten',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: _clearLog,
                    icon: const Icon(Icons.clear),
                    label: const Text('Leeren'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        _logMessages.isEmpty
                            ? 'Keine Log-Nachrichten'
                            : _logMessages,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
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

// Test-Implementierungen der Interfaces

/// Test-Implementierung des Datenanbieters
class _TestDataProvider implements IGSDMultiLanguageDataProvider {
  final Map<String, Map<String, dynamic>> _languageData = {};
  final List<Map<String, dynamic>> _supportedLanguages = [];

  @override
  Future<void> initialize() async {
    // Simuliere Verzögerung
    await Future.delayed(const Duration(milliseconds: 500));

    // Test-Sprachen definieren
    _supportedLanguages.clear();
    _supportedLanguages.addAll([
      {
        'code': 'de',
        'name': 'Deutsch',
        'isocode': 'de-DE',
        'lang': 'de',
      },
      {
        'code': 'en',
        'name': 'English',
        'isocode': 'en-US',
        'lang': 'en',
      },
      {
        'code': 'fr',
        'name': 'Français',
        'isocode': 'fr-FR',
        'lang': 'fr',
      },
    ]);

    // Test-Übersetzungen definieren
    _languageData['de'] = {
      'welcome_message': 'Willkommen in der App!',
      'goodbye_message': 'Auf Wiedersehen!',
      'error_message': 'Ein Fehler ist aufgetreten',
      'success_message': 'Erfolgreich abgeschlossen',
      'button_save': 'Speichern',
      'button_cancel': 'Abbrechen',
      'loading_text': 'Wird geladen...',
      'welcome_message_with_params': 'Hallo {0}, du bist {1} Jahre alt!',
    };

    _languageData['en'] = {
      'welcome_message': 'Welcome to the app!',
      'goodbye_message': 'Goodbye!',
      'error_message': 'An error occurred',
      'success_message': 'Successfully completed',
      'button_save': 'Save',
      'button_cancel': 'Cancel',
      'loading_text': 'Loading...',
      'welcome_message_with_params': 'Hello {0}, you are {1} years old!',
    };

    _languageData['fr'] = {
      'welcome_message': 'Bienvenue dans l\'application!',
      'goodbye_message': 'Au revoir!',
      'error_message': 'Une erreur s\'est produite',
      'success_message': 'Terminé avec succès',
      'button_save': 'Sauvegarder',
      'button_cancel': 'Annuler',
      'loading_text': 'Chargement...',
      'welcome_message_with_params': 'Bonjour {0}, vous avez {1} ans!',
    };
  }

  @override
  Future<Map<String, dynamic>?> getLanguageData(String languageCode) async {
    // Simuliere Netzwerk-Verzögerung
    await Future.delayed(const Duration(milliseconds: 300));
    return _languageData[languageCode];
  }

  @override
  Future<List<Map<String, dynamic>>> getSupportedLanguages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_supportedLanguages);
  }
}

/// Test-Implementierung des Konfigurationsanbieters
class _TestConfigProvider implements IGSDMultiLanguageConfigProvider {
  String _selectedLanguage = '';

  @override
  void setSelectedLanguage(String languageCode) {
    _selectedLanguage = languageCode;
    debugPrint('💾 Sprache in Konfiguration gespeichert: $languageCode');
  }

  @override
  String get selectedLanguage => _selectedLanguage;
}

/// Test-Implementierung des Analytics-Anbieters
class _TestAnalyticsProvider implements IGSDMultiLanguageAnalyticsProvider {
  @override
  void logLanguageChanged(String languageCode) {
    debugPrint('📊 Analytics: Sprachwechsel zu $languageCode');
  }
}
