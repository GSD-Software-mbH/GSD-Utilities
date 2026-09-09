part of '../gsd_utilities.dart';

/// Repräsentiert eine für den Upload vorbereitete Datei mit Metadaten und Plattformkompatibilität.
/// Unterstützt sowohl lokale Dateien (Mobile/Desktop) als auch Web-Dateien (Browser-Uploads).
/// Stellt Bildverarbeitungsfunktionen und Fortschrittsverfolgung bereit.
class GSDUploadFile {
  /// Eindeutige Kennung für diese Upload-Datei-Instanz
  String get uuid {
    return _uuid;
  }

  /// Gibt an, ob diese Datei ein Bild ist, das verarbeitet werden kann
  bool get isImage {
    if (!_isImageCalculated) {
      _isImage = bytes?.isImage() ?? false;
      _isImageCalculated = true;
    }

    return _isImage;
  }

  /// Dateipfad für lokale Dateien (leer für Web-Uploads)
  String get filePath {
    return _platformFile.path ?? "";
  }

  /// Anzeigename der Datei (automatisch aus Pfad generiert wenn nicht angegeben)
  String get name {
    return _platformFile.name;
  }

  /// Ursprüngliche Dateigröße in Bytes
  int get size {
    if (!_isSizeCalculated) {
      _size = bytes?.lengthInBytes ?? 0;
      _isSizeCalculated = true;
    }

    return _size;
  }

  /// Berechnete Größe nach Bildauflösungsanpassung
  /// Gibt formatierten Byte-String zurück (z.B. "1.5 MB")
  String get resolutionSize {
    return (size * (_resolution.percentage / 100)).round().getBytesString(1);
  }

  /// Aktuell eingestellte Bildauflösung für die Komprimierung
  /// Null wenn keine spezifische Auflösung gesetzt wurde
  GSDUploadImageResolution? get resolution {
    return _resolution;
  }

  /// Plattform-spezifische Datei-Repräsentation für Upload-APIs
  /// Enthält die ursprünglichen Dateiinformationen
  RestApiUploadFile get platformFile {
    return _platformFile;
  }

  /// Rohe Bytes der Datei
  /// Lädt bei Bedarf lokale Dateien oder gibt bereits vorhandene Bytes zurück
  Uint8List? get bytes {
    if (_platformFile.isBytes) {
      return _platformFile.bytes;
    } else if (_platformFile.isPath) {
      try {
        File file = File(_platformFile.path!);
        return Uint8List.fromList(file.readAsBytesSync());
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  // Private Felder für Caching und interne Zustandsverwaltung
  bool _isImage = false; // Cached Wert ob Datei ein Bild ist
  bool _isImageCalculated =
      false; // Flag ob Bild-Check bereits durchgeführt wurde
  bool _isSizeCalculated = false; // Flag ob Größe bereits berechnet wurde
  int _size = 0; // Cached Dateigröße in Bytes
  late String _uuid; // Eindeutige Kennung der Datei-Instanz
  GSDUploadImageResolution _resolution = // Bildauflösungseinstellungen
      GSDUploadImageResolution(percentage: 100);
  late RestApiUploadFile
      _platformFile; // Plattform-spezifische Datei-Repräsentation

  /// Haupt-Konstruktor für GSDUploadFile
  ///
  /// [name] - Name der Datei (wird vom platformFile überschrieben wenn leer)
  /// [platformFile] - Plattform-spezifische Datei-Repräsentation
  /// [resolution] - Optionale Bildauflösungseinstellungen (Standard: 100%)
  GSDUploadFile(
      {required String name,
      required RestApiUploadFile platformFile,
      GSDUploadImageResolution? resolution}) {
    _uuid = const Uuid().v4(); // Generiere UUID für jedes UploadFile
    _resolution = resolution ?? GSDUploadImageResolution(percentage: 100);
    _platformFile = platformFile;
  }

  /// Factory-Konstruktor zur Erstellung einer Upload-Datei aus einem Dateipfad
  ///
  /// Verwendet für lokale Dateien auf Mobile/Desktop Plattformen
  /// [path] - Absoluter oder relativer Pfad zur Datei
  factory GSDUploadFile.fromPath(String path) {
    return GSDUploadFile(
        name: "",
        resolution: null,
        platformFile: RestApiUploadFile.fromPath(path: path));
  }

  /// Factory-Konstruktor zur Erstellung einer Upload-Datei aus Byte-Daten
  ///
  /// Verwendet für Web-Uploads oder bereits geladene Dateien im Speicher
  /// [bytes] - Rohe Datei-Bytes
  /// [name] - Name der Datei inkl. Dateierweiterung
  factory GSDUploadFile.fromBytes(Uint8List bytes, String name) {
    return GSDUploadFile(
        name: name,
        resolution: null,
        platformFile: RestApiUploadFile.fromBytes(name: name, bytes: bytes));
  }

  /// Setzt die Bildauflösung für Komprimierung/Skalierung
  ///
  /// Wirkt sich nur auf Bilddateien aus und beeinflusst die finale Upload-Größe
  /// [resolution] - Neue Auflösungseinstellungen
  void setResolution(GSDUploadImageResolution resolution) {
    _resolution = resolution;
  }

  /// Sets the platform file for upload and resets calculated flags.
  ///
  /// This method assigns a new [RestApiUploadFile] to the internal platform file
  /// reference and resets the image and size calculation flags to false, indicating
  /// that these properties need to be recalculated for the new file.
  ///
  /// Parameters:
  /// * [platformFile] - The [RestApiUploadFile] instance to be set
  void setPlatformFile(RestApiUploadFile platformFile) {
    _platformFile = platformFile;
    _isImageCalculated = false;
    _isSizeCalculated = false;
  }

  /// String-Repräsentation der Upload-Datei für Debugging
  ///
  /// Enthält alle wichtigen Eigenschaften der Datei-Instanz
  @override
  String toString() {
    return 'GSDUploadFile {uuid: $_uuid, name: $name, filePath: $filePath, size: $size, isImage: $_isImage, resolution: $_resolution}';
  }
}
