part of '../gsd_utilities.dart';

/// Event-Argumente für Konfigurationsänderungs-Benachrichtigungen.
/// Wird verwendet, wenn Konfigurationsdaten geändert werden und persistiert werden müssen.
class GSDConfigChangedEventArgs extends EventArgs {
  /// Die Konfigurationsinstanz, die geändert wurde
  final GSDBaseConfig config;

  /// Erstellt neue Event-Argumente für eine Konfigurationsänderung
  ///
  /// [config] Die geänderte Konfiguration, die gespeichert werden muss
  GSDConfigChangedEventArgs({required this.config});
}
