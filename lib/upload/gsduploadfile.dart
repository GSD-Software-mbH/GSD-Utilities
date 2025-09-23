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
    return _isImage;
  }

  /// Dateipfad für lokale Dateien (leer für Web-Uploads)
  String get filePath {
    return _filePath;
  }

  /// Anzeigename der Datei (automatisch aus Pfad generiert wenn nicht angegeben)
  String get name {
    if (_name.isEmpty) {
      _name = basename(_filePath);
    }

    return _name;
  }

  /// Ursprüngliche Dateigröße in Bytes
  int get size {
    return _size;
  }

  /// Berechnete Größe nach Bildauflösungsanpassung
  /// Gibt formatierten Byte-String zurück (z.B. "1.5 MB")
  String get resolutionSize {
    return (_size * (_resolution.percentage / 100)).round().getBytesString(1);
  }

  String get previewImage {
    return _previewImage;
  }

  GSDUploadImageResolution? get resolution {
    return _resolution;
  }

  PlatformFile? get platfromFile {
    return _platfromFile;
  }

  Uint8List? get bytes {
    if (kIsWeb) {
      // Für Web-Plattform verwenden wir die Bytes aus der PlatformFile
      return _platfromFile?.bytes;
    } else {
      // Für mobile/desktop Plattformen lesen wir die Datei
      if (_filePath.isNotEmpty) {
        try {
          File file = File(_filePath);
          return Uint8List.fromList(file.readAsBytesSync());
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }

  String _filePath = "";
  String _name = "";
  final String _previewImage = "";
  int _size = 0;
  bool _isImage = false;
  late String _uuid;
  GSDUploadImageResolution _resolution =
      GSDUploadImageResolution(percentage: 100);
  PlatformFile? _platfromFile;

  GSDUploadFile(
      {required String name,
      required String filePath,
      required int size,
      GSDUploadImageResolution? resolution,
      PlatformFile? platformFile,
      bool isImage = false}) {
    _uuid = const Uuid().v4(); // Generiere UUID für jedes UploadFile
    _name = name;
    _filePath = filePath;
    _size = size;
    _resolution = resolution ?? GSDUploadImageResolution(percentage: 100);
    _platfromFile = platformFile;
    _isImage = isImage;
  }

  factory GSDUploadFile.fromPlatformFile(PlatformFile file) {
    if (!kIsWeb) {
      return GSDUploadFile.fromPath(file.path.toString());
    } else {
      return GSDUploadFile.fromWebPlatformFile(file);
    }
  }

  factory GSDUploadFile.fromPath(String path) {
    File file = File(path);
    int size = file.lengthSync();

    List<int> bytes = file.readAsBytesSync();

    return GSDUploadFile(
        name: "",
        isImage: Uint8List.fromList(bytes).isImage(),
        filePath: path,
        size: size,
        resolution: null);
  }

  factory GSDUploadFile.fromWebPlatformFile(PlatformFile file) {
    int size = file.bytes?.length ?? 0;

    return GSDUploadFile(
        name: file.name,
        isImage: file.bytes?.isImage() ?? false,
        filePath: "",
        size: size,
        resolution: null,
        platformFile: file);
  }

  void setResolution(GSDUploadImageResolution resolution) {
    _resolution = resolution;
  }

  void setFilePath(String filePath) {
    _filePath = filePath;
  }

  @override
  String toString() {
    return 'GSDUploadFile {uuid: $_uuid, name: $_name, filePath: $_filePath, size: $_size, isImage: $_isImage, resolution: $_resolution}';
  }
}
