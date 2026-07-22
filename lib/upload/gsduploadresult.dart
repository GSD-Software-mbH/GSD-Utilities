part of '../gsd_utilities.dart';

/// Gesamtergebnis für Multi-Datei-Upload-Operationen.
/// Aggregiert die Ergebnisse aller einzelnen Datei-Uploads.
class GSDUploadResult {
  /// Gibt an, ob alle Datei-Uploads erfolgreich waren
  bool get success {
    return _uploadFileResults.every((result) => result.success);
  }

  /// Liste der einzelnen Datei-Upload-Ergebnisse
  final List<GSDUploadFileResult> _uploadFileResults;

  /// Erstellt ein neues Gesamt-Upload-Ergebnis
  ///
  /// [uploadFileResults] Liste der einzelnen Datei-Upload-Ergebnisse
  GSDUploadResult({required List<GSDUploadFileResult> uploadFileResults})
      : _uploadFileResults = uploadFileResults;

  @override
  String toString() {
    return 'GSDUploadResult {success: $success, uploadFileResults: $_uploadFileResults}';
  }
}
