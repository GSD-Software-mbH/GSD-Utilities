part of '../gsd_utilities.dart';

/// Aufzählung der möglichen Upload-Datei-Status.
/// Repräsentiert den aktuellen Zustand einer einzelnen Datei-Upload-Operation.
enum GSDUploadFileStatus {
  /// Upload wurde noch nicht gestartet
  notStarted,

  /// Upload läuft gerade
  inProgress,

  /// Upload erfolgreich abgeschlossen
  completed,

  /// Upload aufgrund eines Fehlers fehlgeschlagen
  failed
}
