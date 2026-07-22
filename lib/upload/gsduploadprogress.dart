part of '../gsd_utilities.dart';

/// Gesamtfortschrittsverfolgung für mehrere Datei-Uploads.
/// Aggregiert Fortschrittsinformationen von einzelnen Datei-Uploads.
class GSDUploadProgress {
  /// Gibt an, ob alle Datei-Uploads beendet sind (abgeschlossen oder fehlgeschlagen)
  bool get isFinished {
    return uploadFileProgresses.every((progress) =>
        progress.status == GSDUploadFileStatus.completed ||
        progress.status == GSDUploadFileStatus.failed);
  }

  /// Gesamtabschluss-Prozentsatz (0-100) für alle Dateien
  int get percentage {
    if (totalFiles == 0) return 0;
    return ((failedFiles.length + completedFiles.length) / totalFiles * 100)
        .round();
  }

  /// Gesamtanzahl der Dateien, die hochgeladen werden
  int get totalFiles {
    return uploadFileProgresses.length;
  }

  /// Liste der Dateien, die erfolgreich abgeschlossen wurden
  List<GSDUploadFile> get completedFiles {
    return uploadFileProgresses
        .where((progress) => progress.status == GSDUploadFileStatus.completed)
        .map((progress) => progress.uploadFile)
        .toList();
  }

  /// Liste der Dateien, deren Upload fehlgeschlagen ist
  List<GSDUploadFile> get failedFiles {
    return uploadFileProgresses
        .where((progress) => progress.status == GSDUploadFileStatus.failed)
        .map((progress) => progress.uploadFile)
        .toList();
  }

  /// Fortschrittsinformationen für jeden einzelnen Datei-Upload
  final List<GSDUploadFileProgress> uploadFileProgresses;

  /// Erstellt eine neue Gesamt-Upload-Fortschritts-Instanz
  ///
  /// [uploadFileProgresses] Liste der einzelnen Datei-Fortschritts-Tracker
  GSDUploadProgress({
    required this.uploadFileProgresses,
  });
}
