import 'package:flutter_test/flutter_test.dart';
import 'package:gsd_utilities/gsd_utilities.dart';

/// Test-Implementierung des Datenanbieters für Unit Tests
class MockDataProvider implements IGSDMultiLanguageDataProvider {
  final Map<String, Map<String, dynamic>> _languageData = {};
  final List<Map<String, dynamic>> _supportedLanguages = [];
  bool _isInitialized = false;
  bool _shouldThrowError = false;
  Duration _delay = Duration.zero;

  /// Setzt Test-Daten
  void setTestData({
    required List<Map<String, dynamic>> supportedLanguages,
    required Map<String, Map<String, dynamic>> languageData,
  }) {
    _supportedLanguages.clear();
    _supportedLanguages.addAll(supportedLanguages);
    _languageData.clear();
    _languageData.addAll(languageData);
  }

  /// Simuliert Fehler für Fehlerbehandlungs-Tests
  void setShouldThrowError(bool shouldThrow) {
    _shouldThrowError = shouldThrow;
  }

  /// Setzt eine Verzögerung für asynchrone Tests
  void setDelay(Duration delay) {
    _delay = delay;
  }

  @override
  Future<void> initialize() async {
    if (_delay.inMilliseconds > 0) {
      await Future.delayed(_delay);
    }

    if (_shouldThrowError) {
      throw Exception('Mock initialization error');
    }

    _isInitialized = true;
  }

  @override
  Future<Map<String, dynamic>?> getLanguageData(String languageCode) async {
    if (_delay.inMilliseconds > 0) {
      await Future.delayed(_delay);
    }

    if (_shouldThrowError) {
      throw Exception('Mock language data error');
    }

    if (!_isInitialized) {
      throw Exception('Provider not initialized');
    }

    return _languageData[languageCode];
  }

  @override
  Future<List<Map<String, dynamic>>> getSupportedLanguages() async {
    if (_delay.inMilliseconds > 0) {
      await Future.delayed(_delay);
    }

    if (_shouldThrowError) {
      throw Exception('Mock supported languages error');
    }

    if (!_isInitialized) {
      throw Exception('Provider not initialized');
    }

    return List.from(_supportedLanguages);
  }
}

/// Test-Implementierung des Konfigurationsanbieters
class MockConfigProvider implements IGSDMultiLanguageConfigProvider {
  String _selectedLanguage = '';

  @override
  void setSelectedLanguage(String languageCode) {
    _selectedLanguage = languageCode;
  }

  @override
  String get selectedLanguage => _selectedLanguage;

  /// Test-Hilfsmethode zum Zurücksetzen
  void reset() {
    _selectedLanguage = '';
  }
}

/// Test-Implementierung des Analytics-Anbieters
class MockAnalyticsProvider implements IGSDMultiLanguageAnalyticsProvider {
  final List<String> _loggedLanguageChanges = [];

  @override
  void logLanguageChanged(String languageCode) {
    _loggedLanguageChanges.add(languageCode);
  }

  /// Getter für Test-Überprüfungen
  List<String> get loggedLanguageChanges => List.from(_loggedLanguageChanges);

  /// Test-Hilfsmethode zum Zurücksetzen
  void reset() {
    _loggedLanguageChanges.clear();
  }
}

void main() {
  group('GSDLanguage Tests', () {
    test('should create language with constructor', () {
      final language = GSDLanguage('Deutsch', 'de', 'de-DE', 'de');

      expect(language.name, 'Deutsch');
      expect(language.code, 'de');
      expect(language.isocode, 'de-DE');
      expect(language.lang, 'de');
    });

    test('should create language from JSON', () {
      final json = {
        'name': 'English',
        'code': 'en',
        'isocode': 'en-US',
        'lang': 'en'
      };

      final language = GSDLanguage.fromJson(json);

      expect(language.name, 'English');
      expect(language.code, 'en');
      expect(language.isocode, 'en-US');
      expect(language.lang, 'en');
    });

    test('should convert language to JSON', () {
      final language = GSDLanguage('Français', 'fr', 'fr-FR', 'fr');
      final json = language.toJson();

      expect(json['name'], 'Français');
      expect(json['code'], 'fr');
      expect(json['isocode'], 'fr-FR');
      expect(json['lang'], 'fr');
    });

    test('should compare languages correctly', () {
      final lang1 = GSDLanguage('Deutsch', 'de', 'de-DE', 'de');
      final lang2 = GSDLanguage('German', 'de', 'de-DE', 'de');
      final lang3 = GSDLanguage('English', 'en', 'en-US', 'en');

      expect(lang1 == lang2, true); // Gleicher Code
      expect(lang1 == lang3, false); // Verschiedener Code
      expect(lang1.hashCode, lang2.hashCode); // HashCode sollte gleich sein
    });

    test('should have proper toString representation', () {
      final language = GSDLanguage('Deutsch', 'de', 'de-DE', 'de');
      expect(language.toString(), 'GSDLanguage(code: de, name: Deutsch)');
    });
  });

  group('GSDMultiLanguageProvider Tests', () {
    late MockDataProvider mockDataProvider;
    late MockConfigProvider mockConfigProvider;
    late MockAnalyticsProvider mockAnalyticsProvider;
    late GSDMultiLanguageProvider provider;

    setUp(() {
      mockDataProvider = MockDataProvider();
      mockConfigProvider = MockConfigProvider();
      mockAnalyticsProvider = MockAnalyticsProvider();

      // Standard-Testdaten setzen
      mockDataProvider.setTestData(
        supportedLanguages: [
          {'name': 'Deutsch', 'code': 'de', 'isocode': 'de-DE', 'lang': 'de'},
          {'name': 'English', 'code': 'en', 'isocode': 'en-US', 'lang': 'en'},
          {'name': 'Français', 'code': 'fr', 'isocode': 'fr-FR', 'lang': 'fr'},
        ],
        languageData: {
          'de': {
            'hello': 'Hallo',
            'goodbye': 'Auf Wiedersehen',
            'welcome_user': 'Willkommen {0}!',
          },
          'en': {
            'hello': 'Hello',
            'goodbye': 'Goodbye',
            'welcome_user': 'Welcome {0}!',
          },
          'fr': {
            'hello': 'Bonjour',
            'goodbye': 'Au revoir',
            'welcome_user': 'Bienvenue {0}!',
          },
        },
      );

      provider = GSDMultiLanguageProvider(
        dataProvider: mockDataProvider,
        configProvider: mockConfigProvider,
        analyticsProvider: mockAnalyticsProvider,
      );
    });

    test('should initialize successfully', () async {
      expect(provider.isInitialized, false);
      expect(provider.isLoading, false);
      expect(provider.supportedLanguages, isEmpty);

      await provider.initialize();

      expect(provider.isInitialized, true);
      expect(provider.isLoading, false);
      expect(provider.supportedLanguages, hasLength(3));
      expect(provider.selectedLanguage, isNotNull);
      expect(provider.selectedLanguage!.code,
          'de'); // Erste Sprache sollte ausgewählt sein
    });

    test('should not initialize twice', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);

      // Zweite Initialisierung sollte keine Auswirkung haben
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('should restore saved language from config', () async {
      mockConfigProvider.setSelectedLanguage('fr');

      await provider.initialize();

      expect(provider.selectedLanguage!.code, 'fr');
    });

    test('should handle initialization error gracefully', () async {
      mockDataProvider.setShouldThrowError(true);

      await provider.initialize();

      expect(provider.isInitialized, false);
      expect(provider.isLoading, false);
    });

    test('should set loading state during operations', () async {
      mockDataProvider.setDelay(const Duration(milliseconds: 100));

      final initFuture = provider.initialize();
      expect(provider.isLoading, true);

      await initFuture;
      expect(provider.isLoading, false);
    });

    test('should switch language successfully', () async {
      await provider.initialize();

      final englishLang =
          provider.supportedLanguages.firstWhere((lang) => lang.code == 'en');

      await provider.setSelectedLanguage(englishLang);

      expect(provider.selectedLanguage!.code, 'en');
      expect(mockConfigProvider.selectedLanguage, 'en');
      expect(mockAnalyticsProvider.loggedLanguageChanges, contains('en'));
    });

    test('should switch language by code', () async {
      await provider.initialize();

      await provider.setLanguageByCode('fr');

      expect(provider.selectedLanguage!.code, 'fr');
      expect(mockConfigProvider.selectedLanguage, 'fr');
    });

    test('should fallback to first language for invalid code', () async {
      await provider.initialize();

      await provider.setLanguageByCode('invalid');

      // Sollte zur ersten verfügbaren Sprache wechseln
      expect(provider.selectedLanguage!.code, 'de');
    });

    test('should not switch to same language', () async {
      await provider.initialize();
      final initialLanguage = provider.selectedLanguage!;

      // Analytics zurücksetzen nach Initialisierung
      mockAnalyticsProvider.reset();

      await provider.setSelectedLanguage(initialLanguage);

      // Analytics sollte nicht aufgerufen werden für gleiche Sprache
      expect(mockAnalyticsProvider.loggedLanguageChanges, isEmpty);
    });

    test('should refresh language data', () async {
      await provider.initialize();
      await provider.setLanguageByCode('en');

      // Änderung in Mock-Daten simulieren
      mockDataProvider.setTestData(
        supportedLanguages: mockDataProvider._supportedLanguages,
        languageData: {
          ...mockDataProvider._languageData,
          'en': {
            'hello': 'Hi there!', // Geändert
            'goodbye': 'See you!',
            'welcome_user': 'Hey {0}!',
          },
        },
      );

      await provider.refresh();

      expect(provider.getMLText('hello'), 'Hi there!');
    });

    test('should get text by key', () async {
      await provider.initialize();
      await provider.setLanguageByCode('de');

      expect(provider.getMLText('hello'), 'Hallo');
      expect(provider.getMLText('goodbye'), 'Auf Wiedersehen');
    });

    test('should return default value for missing key', () async {
      await provider.initialize();

      expect(provider.getMLText('missing_key'), 'missing_key');
      expect(provider.getMLText('missing_key', defaultValue: 'Default'),
          'Default');
    });

    test('should get text with parameters', () async {
      await provider.initialize();
      await provider.setLanguageByCode('de');

      final text = provider.getTextWithParams('welcome_user', ['Max']);
      expect(text, 'Willkommen Max!');
    });

    test('should handle multiple parameters', () async {
      await provider.initialize();

      // Füge Test-Daten mit mehreren Parametern hinzu
      mockDataProvider.setTestData(
        supportedLanguages: mockDataProvider._supportedLanguages,
        languageData: {
          'de': {
            'hello': 'Hallo',
            'goodbye': 'Auf Wiedersehen',
            'welcome_user': 'Willkommen {0}!',
            'multi_param':
                'Hallo {0}, du bist {1} Jahre alt und wohnst in {2}.',
          },
          'en': {
            'hello': 'Hello',
            'goodbye': 'Goodbye',
            'welcome_user': 'Welcome {0}!',
          },
          'fr': {
            'hello': 'Bonjour',
            'goodbye': 'Au revoir',
            'welcome_user': 'Bienvenue {0}!',
          },
        },
      );

      await provider.refresh(); // Lade die neuen Daten

      final text =
          provider.getTextWithParams('multi_param', ['Anna', '25', 'Berlin']);
      expect(text, 'Hallo Anna, du bist 25 Jahre alt und wohnst in Berlin.');
    });

    test('should fire events on language change', () async {
      bool languageChangedFired = false;
      provider.onLanguageChanged.subscribe((args) {
        languageChangedFired = true;
      });

      await provider.initialize();
      await provider.setLanguageByCode('en');

      expect(languageChangedFired, true);
    });

    test('should fire error events', () async {
      bool errorFired = false;
      provider.onError.subscribe((args) {
        errorFired = true;
      });

      mockDataProvider.setShouldThrowError(true);
      await provider.initialize();

      expect(errorFired, true);
    });

    test('should dispose properly', () {
      // Test, dass dispose ohne Fehler aufgerufen werden kann
      expect(() => provider.dispose(), returnsNormally);
    });

    test('should handle language data loading error', () async {
      await provider.initialize();

      mockDataProvider.setShouldThrowError(true);

      await provider.setLanguageByCode('en');

      // Sollte bei der ursprünglichen Sprache bleiben
      expect(provider.selectedLanguage!.code, 'de');
    });

    test('should work without optional providers', () async {
      final providerWithoutOptionals = GSDMultiLanguageProvider(
        dataProvider: mockDataProvider,
      );

      await providerWithoutOptionals.initialize();

      expect(providerWithoutOptionals.isInitialized, true);
      expect(providerWithoutOptionals.supportedLanguages, hasLength(3));

      providerWithoutOptionals.dispose();
    });

    test('should handle empty language data', () async {
      mockDataProvider.setTestData(
        supportedLanguages: [],
        languageData: {},
      );

      await provider.initialize();

      expect(provider.supportedLanguages, isEmpty);
      expect(provider.selectedLanguage, isNull);
    });

    test('should handle null language data response', () async {
      await provider.initialize();

      // Mock soll null für Sprachdaten zurückgeben
      mockDataProvider.setTestData(
        supportedLanguages: mockDataProvider._supportedLanguages,
        languageData: {}, // Keine Daten für 'en'
      );

      await provider.setLanguageByCode('en');

      // Sollte bei der ursprünglichen Sprache bleiben
      expect(provider.selectedLanguage!.code, 'de');
    });
  });

  group('Integration Tests', () {
    test('should work with complete workflow', () async {
      final mockDataProvider = MockDataProvider();
      final mockConfigProvider = MockConfigProvider();
      final mockAnalyticsProvider = MockAnalyticsProvider();

      mockDataProvider.setTestData(
        supportedLanguages: [
          {'name': 'Deutsch', 'code': 'de', 'isocode': 'de-DE', 'lang': 'de'},
          {'name': 'English', 'code': 'en', 'isocode': 'en-US', 'lang': 'en'},
        ],
        languageData: {
          'de': {'greeting': 'Hallo Welt!'},
          'en': {'greeting': 'Hello World!'},
        },
      );

      final provider = GSDMultiLanguageProvider(
        dataProvider: mockDataProvider,
        configProvider: mockConfigProvider,
        analyticsProvider: mockAnalyticsProvider,
      );

      // Initialisierung
      await provider.initialize();
      expect(provider.isInitialized, true);
      expect(provider.supportedLanguages, hasLength(2));

      // Erste Sprache sollte automatisch ausgewählt sein
      expect(provider.selectedLanguage!.code, 'de');
      expect(provider.getMLText('greeting'), 'Hallo Welt!');

      // Sprachwechsel
      await provider.setLanguageByCode('en');
      expect(provider.selectedLanguage!.code, 'en');
      expect(provider.getMLText('greeting'), 'Hello World!');

      // Konfiguration sollte gespeichert sein
      expect(mockConfigProvider.selectedLanguage, 'en');

      // Analytics sollte protokolliert haben
      expect(mockAnalyticsProvider.loggedLanguageChanges, contains('en'));

      provider.dispose();
    });
  });
}
