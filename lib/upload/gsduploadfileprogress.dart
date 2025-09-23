part of '../gsd_utilities.dart';

/// Fortschrittsverfolgung für einzelne Datei-Uploads.
/// Stellt Echtzeit-Informationen über Upload-Status und Byte-Transfer-Fortschritt bereit.
class GSDUploadFileProgress {
  /// Berechneter Upload-Prozentsatz (0-100) basierend auf hochgeladenen vs. Gesamt-Bytes
  int get percentage {
    if (uploadFile.size == 0) return 0;
    return (uploadedBytes / uploadFile.size * 100).round();
  }

  /// Gibt an, ob der Upload beendet ist (entweder abgeschlossen oder fehlgeschlagen)
  bool get isFinished {
    return status == GSDUploadFileStatus.completed ||
        status == GSDUploadFileStatus.failed;
  }

  /// Anzahl der bisher erfolgreich hochgeladenen Bytes
  final int uploadedBytes;

  /// Aktueller Status der Upload-Operation
  final GSDUploadFileStatus status;

  /// Endergebnis des Uploads (null während des Uploads)
  final GSDUploadFileResult? result;

  /// Die Datei, die hochgeladen wird
  final GSDUploadFile uploadFile;

  /// Erstellt eine neue Upload-Fortschritts-Instanz
  ///
  /// [status] Aktueller Upload-Status
  /// [uploadFile] Die Datei, die hochgeladen wird
  /// [uploadedBytes] Anzahl der bisher hochgeladenen Bytes
  /// [result] Endergebnis des Uploads (optional, für abgeschlossene Uploads)
  GSDUploadFileProgress({
    required this.status,
    required this.uploadFile,
    this.uploadedBytes = 0,
    this.result,
  });

  @override
  String toString() {
    return 'GSDUploadFileProgress {percentage: $percentage, '
        'totalBytes: ${uploadFile.size}, uploadedBytes: $uploadedBytes, '
        'status: $status, result: $result}';
  }
}
