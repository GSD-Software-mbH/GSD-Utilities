part of '../gsd_utilities.dart';

/// Multi-Sprachen Provider mit Dependency Injection Unterstützung
///
/// Diese Klasse verwaltet die Internationalisierung (i18n) einer App.
/// Sie lädt Sprachdaten, verwaltet die aktuell ausgewählte Sprache
/// und bietet Methoden zum Abrufen von lokalisierten Texten.
///
/// Der Provider verwendet das Dependency Injection Pattern und
/// kann mit verschiedenen Datenquellen und Konfigurationsanbietern
/// arbeiten.
class GSDMultiLanguageProvider with ChangeNotifier {
  /// Öffentliche Getter
  ///
  /// Liste aller unterstützten Sprachen (unveränderlich)
  List<GSDLanguage> get supportedLanguages =>
      List.unmodifiable(_supportedLanguages);

  /// Aktuell ausgewählte Sprache oder null falls noch keine ausgewählt
  GSDLanguage? get selectedLanguage => _selectedLanguage;

  /// Map mit allen geladenen Übersetzungsschlüsseln und -werten
  Map<String, dynamic> get values => Map.unmodifiable(_values);

  /// Gibt an, ob der Provider initialisiert wurde
  bool get isInitialized => _isInitialized;

  /// Gibt an, ob gerade ein Ladevorgang läuft
  bool get isLoading => _isLoading;

  /// Events für Benachrichtigungen
  ///
  /// Wird ausgelöst, wenn sich die Sprache ändert
  final Event onLanguageChanged = Event();

  /// Wird ausgelöst, wenn ein Fehler auftritt
  final Event onError = Event();

  /// Private Felder
  ///
  /// Map mit allen geladenen Übersetzungen
  Map<String, dynamic> _values = <String, dynamic>{};

  /// Aktuell ausgewählte Sprache
  GSDLanguage? _selectedLanguage;

  /// Liste aller verfügbaren Sprachen
  final List<GSDLanguage> _supportedLanguages = [];

  /// Initialisierungsstatus
  bool _isInitialized = false;

  /// Ladestatus für UI-Feedback
  bool _isLoading = false;

  /// Abhängigkeiten über Dependency Injection
  ///
  /// Pflichtabhängigkeit: Datenanbieter für Sprachdaten
  final IGSDMultiLanguageDataProvider _dataProvider;

  /// Optionale Abhängigkeit: Konfigurationsanbieter für Persistierung
  final IGSDMultiLanguageConfigProvider? _configProvider;

  /// Optionale Abhängigkeit: Analytics-Anbieter für Tracking
  final IGSDMultiLanguageAnalyticsProvider? _analyticsProvider;

  /// Konstruktor mit Dependency Injection
  ///
  /// [dataProvider] - Erforderlich: Anbieter für Sprachdaten
  /// [configProvider] - Optional: Anbieter für Konfigurationspersistierung
  /// [analyticsProvider] - Optional: Anbieter für Analytics/Tracking
  GSDMultiLanguageProvider({
    required IGSDMultiLanguageDataProvider dataProvider,
    IGSDMultiLanguageConfigProvider? configProvider,
    IGSDMultiLanguageAnalyticsProvider? analyticsProvider,
  })  : _dataProvider = dataProvider,
        _configProvider = configProvider,
        _analyticsProvider = analyticsProvider;

  /// Initialisiert den Provider
  ///
  /// Diese Methode muss vor der ersten Verwendung aufgerufen werden.
  /// Sie lädt die verfügbaren Sprachen und stellt die zuletzt verwendete
  /// Sprache wieder her (falls verfügbar).
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);

    try {
      await _dataProvider.initialize();

      // Lade unterstützte Sprachen
      await _loadSupportedLanguages();

      // Setze Anfangssprache aus Konfiguration oder Standard
      final savedLanguageCode = _configProvider?.selectedLanguage;
      if (savedLanguageCode != null && savedLanguageCode.isNotEmpty) {
        await setLanguageByCode(savedLanguageCode);
      } else if (_supportedLanguages.isNotEmpty) {
        await setSelectedLanguage(_supportedLanguages.first);
      }

      _isInitialized = true;
    } catch (e) {
      _handleError('Fehler beim Initialisieren des MultiLanguageProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Lädt die unterstützten Sprachen vom Datenanbieter
  ///
  /// Diese private Methode ruft die verfügbaren Sprachen vom
  /// Datenanbieter ab und erstellt GSDLanguage-Objekte daraus.
  Future<void> _loadSupportedLanguages() async {
    try {
      final languagesData = await _dataProvider.getSupportedLanguages();

      _supportedLanguages.clear();
      for (var languageData in languagesData) {
        try {
          _supportedLanguages.add(GSDLanguage.fromJson(languageData));
        } catch (e) {
          debugPrint('Fehler beim Parsen der Sprachdaten: $e');
        }
      }
    } catch (e) {
      _handleError('Fehler beim Laden der unterstützten Sprachen: $e');
    }
  }

  /// Setzt die ausgewählte Sprache
  ///
  /// [language] - Die zu setzende Sprache
  ///
  /// Lädt die Sprachdaten, speichert die Auswahl persistent
  /// (falls Konfigurationsanbieter verfügbar) und benachrichtigt
  /// alle Listener über die Änderung.
  Future<void> setSelectedLanguage(GSDLanguage language) async {
    if (_selectedLanguage == language) return;

    _setLoading(true);

    try {
      // Lade Sprachdaten
      final languageData = await _dataProvider.getLanguageData(language.code);

      if (languageData != null) {
        _values = languageData;
        _selectedLanguage = language;

        // Speichere in Konfiguration falls Anbieter verfügbar
        _configProvider?.setSelectedLanguage(language.code);

        // Protokolliere Analytics falls Anbieter verfügbar
        _analyticsProvider?.logLanguageChanged(language.code);

        // Benachrichtige Listener
        onLanguageChanged.broadcast();
        notifyListeners();
      } else {
        _handleError('Keine Daten für Sprache gefunden: ${language.code}');
      }
    } catch (e) {
      _handleError('Fehler beim Setzen der Sprache ${language.code}: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Setzt die Sprache anhand des Sprachcodes
  ///
  /// [code] - Der Code der gewünschten Sprache (z.B. "de", "en")
  ///
  /// Sucht in den unterstützten Sprachen nach dem entsprechenden
  /// Code und wechselt zu dieser Sprache. Falls die Sprache nicht
  /// gefunden wird, wird zur ersten verfügbaren Sprache gewechselt.
  Future<void> setLanguageByCode(String code) async {
    final language = _supportedLanguages.cast<GSDLanguage?>().firstWhere(
          (item) => item?.code == code,
          orElse: () => null,
        );

    if (language != null) {
      await setSelectedLanguage(language);
    } else {
      _handleError('Sprache mit Code "$code" nicht gefunden');

      // Fallback zur ersten unterstützten Sprache
      if (_supportedLanguages.isNotEmpty) {
        await setSelectedLanguage(_supportedLanguages.first);
      }
    }
  }

  /// Aktualisiert die Sprachdaten der aktuell ausgewählten Sprache
  ///
  /// Lädt die Sprachdaten der aktuellen Sprache erneut vom
  /// Datenanbieter. Nützlich wenn sich die Übersetzungen
  /// zur Laufzeit geändert haben könnten.
  Future<void> refresh() async {
    if (_selectedLanguage != null) {
      final currentLanguage = _selectedLanguage!;
      _selectedLanguage = null; // Erzwinge Neuladen
      await setSelectedLanguage(currentLanguage);
    }
  }

  /// Ruft lokalisierten Text anhand eines Schlüssels ab
  ///
  /// [key] - Der Übersetzungsschlüssel
  /// [defaultValue] - Fallback-Wert falls der Schlüssel nicht gefunden wird
  ///
  /// Gibt den lokalisierten Text zurück oder den Standardwert bzw.
  /// den Schlüssel selbst falls keine Übersetzung gefunden wird.
  String getMLText(String key, {String? defaultValue}) {
    return _values[key]?.toString() ?? defaultValue ?? key;
  }

  /// Ruft lokalisierten Text mit Parametern ab
  ///
  /// [key] - Der Übersetzungsschlüssel
  /// [params] - Liste von Parametern für Platzhalter {0}, {1}, etc.
  /// [defaultValue] - Fallback-Wert falls der Schlüssel nicht gefunden wird
  ///
  /// Ersetzt Platzhalter im Format {0}, {1}, {2}, etc. durch die
  /// entsprechenden Parameter aus der Liste.
  String getTextWithParams(String key, List<String> params,
      {String? defaultValue}) {
    String text = getMLText(key, defaultValue: defaultValue);

    for (int i = 0; i < params.length; i++) {
      text = text.replaceAll('{$i}', params[i]);
    }

    return text;
  }

  /// Private Hilfsmethoden

  /// Setzt den Ladestatus und benachrichtigt UI-Komponenten
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Behandelt Fehler einheitlich
  void _handleError(String error) {
    debugPrint('MultiLanguageProvider Fehler: $error');
    onError.broadcast();
  }

  /// Aufräumen beim Dispose
  @override
  void dispose() {
    onLanguageChanged.unsubscribeAll();
    onError.unsubscribeAll();
    super.dispose();
  }
}
