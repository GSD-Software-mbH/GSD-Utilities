part of '../gsd_utilities.dart';

/// Ergebnis-Container für einzelne Datei-Upload-Operationen.
/// Enthält den Upload-Status, Fehlerinformationen und Server-Antwortdaten.
class GSDUploadFileResult {
  /// Die ursprüngliche Upload-Datei, die verarbeitet wurde
  GSDUploadFile get uploadFile {
    return _uploadFile;
  }

  /// Gibt an, ob der Upload erfolgreich war
  bool get success {
    return _success;
  }

  /// Exception-Details wenn der Upload fehlgeschlagen ist (null bei Erfolg)
  Exception? get error {
    return _error;
  }

  /// Server-zugewiesene Objekt-ID für die hochgeladene Datei (null bei Fehlschlag)
  String? get oid {
    return _oid;
  }

  final GSDUploadFile _uploadFile;
  final bool _success;
  final Exception? _error;
  final String? _oid;

  /// Erstellt ein neues Upload-Ergebnis für eine Datei-Operation
  ///
  /// [uploadFile] Die Datei, die hochgeladen wurde
  /// [success] Ob der Upload erfolgreich war
  /// [error] Exception-Details (optional, für fehlgeschlagene Uploads)
  /// [oid] Server-Objekt-ID (optional, für erfolgreiche Uploads)
  GSDUploadFileResult(
      {required GSDUploadFile uploadFile,
      required bool success,
      Exception? error,
      String? oid})
      : _uploadFile = uploadFile,
        _success = success,
        _error = error,
        _oid = oid;

  @override
  String toString() {
    return 'GSDUploadFileResult {uploadFile: $_uploadFile, success: $_success, error: $_error, oid: $_oid}';
  }
}
