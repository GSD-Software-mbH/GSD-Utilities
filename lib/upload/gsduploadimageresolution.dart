part of '../gsd_utilities.dart';

/// Konfiguration der Bildauflösung für Upload-Optimierung.
/// Definiert den Prozentsatz der ursprünglichen Bildgröße für die Komprimierung.
class GSDUploadImageResolution {
  /// Prozentsatz der ursprünglichen Bildgröße (1-100)
  /// 100 = Originalgröße, 50 = halbe Größe, etc.
  final int percentage;

  /// Erstellt eine neue Bildauflösungs-Konfiguration
  ///
  /// [percentage] Prozentsatz der ursprünglichen Bildgröße (1-100)
  GSDUploadImageResolution({required this.percentage});
}
