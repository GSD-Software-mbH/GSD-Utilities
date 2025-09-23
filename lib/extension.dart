part of 'gsd_utilities.dart';

extension StringExtensions on String {
  /// Ersetzt Platzhalter wie %1, %2, ... im String durch die Werte aus [params].
  ///
  /// Beispiel: 'Hallo %1!'.replaceParams(['Welt']) ergibt 'Hallo Welt!'.
  String replaceParams(List<String> params) {
    var result = this;
    for (var i = 0; i < params.length; i++) {
      result = result.replaceAll('%${i + 1}', params[i]);
    }
    return result;
  }

  /// Prüft, ob der String ein gültiger MD5-Hash ist (32 hexadezimale Zeichen).
  bool isMd5Hash() {
    final md5Regex = RegExp(r'^[a-fA-F0-9]{32}$');
    return md5Regex.hasMatch(this);
  }

  /// Wandelt einen Hex-String (z.B. '#FF00FF' oder 'FF00FF') in ein [Color]-Objekt um.
  /// Unterstützt auch Strings ohne Alpha-Kanal (setzt dann volle Deckkraft).
  Color fromHexToColor() {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Wandelt Unicode-Escape-Sequenzen (z.B. '\\u00E4') und bekannte Escape-Sequenzen
  /// wie '\\n', '\\r', '\\t' im String in die entsprechenden Zeichen um.
  String convertFromUnicode() {
    return replaceAllMapped(
            RegExp(r'\\u([0-9A-Fa-f]{4})'),
            (Match match) =>
                String.fromCharCode(int.parse(match.group(1)!, radix: 16)))
        // Ersetzt bekannte Escape-Sequenzen wie \\n, \\r und \\t
        .replaceAllMapped(RegExp(r'(?<!\\)\\n'), (_) => '\n')
        .replaceAllMapped(RegExp(r'(?<!\\)\\r'), (_) => '\r')
        .replaceAllMapped(RegExp(r'(?<!\\)\\t'), (_) => '\t')
        .replaceAllMapped(RegExp(r'(?<!\\)\\b'), (_) => '\b')
        .replaceAllMapped(RegExp(r'(?<!\\)\\f'), (_) => '\f')
        .replaceAll(r'\\', '\\');
  }
}

extension IntExtensions on int {
  /// Gibt die Byte-Größe als lesbaren String zurück (z.B. '1.23 MB').
  /// [decimals] gibt die Anzahl der Nachkommastellen an.
  String getBytesString(int decimals) {
    if (this <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (math.log(this) / math.log(1024)).floor();
    return '${(this / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}

/// Extension-Methoden für Uint8List zur Hinzufügung von Bilderkennungsfunktionen.
/// Stellt Hilfsfunktionen für die Arbeit mit Binärdaten und Bildformaten bereit.
extension GSDUint8ListExtention on Uint8List {
  /// Bestimmt, ob die Byte-Daten ein gültiges Bildformat repräsentieren.
  ///
  /// Verwendet das image-Package, um zu versuchen, die Binärdaten zu dekodieren.
  /// Unterstützt gängige Formate wie PNG, JPEG, GIF, WebP, etc.
  ///
  /// Gibt true zurück, wenn die Daten als Bild dekodiert werden können, andernfalls false.
  bool isImage() {
    try {
      img.Image? decodedImage = img.decodeImage(this);

      return decodedImage != null;
    } catch (e) {
      return false;
    }
  }
}

extension GSDMultiLanguageContext on material.BuildContext {
  /// Gibt den MultiLanguageProvider ohne Listener zurück (kein automatisches Rebuild bei Sprachwechsel).
  GSDMultiLanguageProvider get gsdMultiLangugeProvider =>
      Provider.of<GSDMultiLanguageProvider>(this, listen: false);

  /// Gibt den MultiLanguageProvider mit Listener zurück (Widget wird bei Sprachwechsel neu gebaut).
  GSDMultiLanguageProvider get gsdMultiLangugeProviderWithListener =>
      Provider.of<GSDMultiLanguageProvider>(this, listen: true);

  /// Holt einen lokalisierten Text anhand des Schlüssels aus dem Provider.
  /// [defaultValue] wird verwendet, falls der Schlüssel nicht gefunden wird.
  /// [listen] steuert, ob das Widget bei Sprachwechsel neu gebaut wird.
  String getMLText(String key, {String? defaultValue, bool listen = true}) {
    return Provider.of<GSDMultiLanguageProvider>(this, listen: listen)
        .getMLText(key, defaultValue: defaultValue);
  }

  /// Holt einen lokalisierten Text mit Parametern aus dem Provider.
  /// [params] ersetzt Platzhalter im Text, z.B. {0}, {1}.
  /// [defaultValue] wird verwendet, falls der Schlüssel nicht gefunden wird.
  /// [listen] steuert, ob das Widget bei Sprachwechsel neu gebaut wird.
  String getMLTextWithParams(String key, List<String> params,
      {String? defaultValue, bool listen = true}) {
    return Provider.of<GSDMultiLanguageProvider>(this, listen: listen)
        .getTextWithParams(key, params, defaultValue: defaultValue);
  }
}
