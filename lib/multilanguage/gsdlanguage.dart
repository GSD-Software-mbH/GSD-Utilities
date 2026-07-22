part of '../gsd_utilities.dart';

/// Repräsentiert eine Sprache mit ihren Metadaten
///
/// Diese Klasse enthält alle notwendigen Informationen über eine Sprache,
/// einschließlich Code, Name und ISO-Standards.
class GSDLanguage {
  /// Eindeutiger Code der Sprache (z.B. "de", "en")
  String code = "";

  /// Anzeigename der Sprache (z.B. "Deutsch", "English")
  String name = "";

  /// ISO-Code der Sprache (z.B. "de-DE", "en-US")
  String isocode = "";

  /// Sprach-Tag für Lokalisierung (z.B. "de", "en")
  String lang = "";

  /// Konstruktor für eine neue Sprachinstanz
  ///
  /// [name] - Der Anzeigename der Sprache
  /// [code] - Der eindeutige Code der Sprache
  /// [isocode] - Der ISO-Code der Sprache
  /// [lang] - Der Sprach-Tag für Lokalisierung
  GSDLanguage(this.name, this.code, this.isocode, this.lang);

  /// Erstellt eine GSDLanguage-Instanz aus JSON-Daten
  ///
  /// [languageMap] - Eine Map mit den Sprachdaten aus JSON
  GSDLanguage.fromJson(Map languageMap) {
    code = languageMap["code"];
    name = languageMap["name"];
    isocode = languageMap["isocode"];
    lang = languageMap["lang"];
  }

  /// Konvertiert die Sprache zu einer Map für JSON-Serialisierung
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'isocode': isocode,
      'lang': lang,
    };
  }

  /// Prüft, ob zwei Sprachen identisch sind
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GSDLanguage && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'GSDLanguage(code: $code, name: $name)';
}
