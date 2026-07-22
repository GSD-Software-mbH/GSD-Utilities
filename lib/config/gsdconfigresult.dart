part of '../gsd_utilities.dart';

/// Ergebnis-Container für Konfigurationslade-Operationen.
/// Stellt umfassende Informationen über Erfolg oder Fehlschlag von Konfigurationsoperationen bereit.
///
/// Typ-Parameter [T] muss BaseConfig erweitern
class GSDConfigResult<T extends GSDBaseConfig> {
  /// Die geladene Konfigurationsinstanz (null bei Ladefehlern)
  final T? config;

  /// Gibt an, ob das Laden der Konfiguration erfolgreich war
  final bool isSuccess;

  /// Detaillierte Log-Nachrichten für Debugging und Fehlerbehandlung
  final String log;

  /// Exception-Details wenn die Operation fehlgeschlagen ist (null bei Erfolg)
  final Exception? error;

  /// Erstellt eine neue ConfigResult-Instanz
  ///
  /// [isSuccess] Ob die Operation erfolgreich war
  /// [log] Detaillierte Log-Nachrichten für Debugging
  /// [config] Die geladene Konfiguration (optional, nur bei Erfolg)
  /// [error] Exception-Details (optional, nur bei Fehlern)
  GSDConfigResult({
    required this.isSuccess,
    required this.log,
    this.config,
    this.error,
  });
}
