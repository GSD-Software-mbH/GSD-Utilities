part of '../gsd_utilities.dart';

/// Event-Argumente für Web-localStorage-Änderungs-Benachrichtigungen.
/// Wird ausgelöst, wenn localStorage von anderen Tabs oder Fenstern geändert wird.
/// Nur auf Web-Plattformen verfügbar.
class GSDWebLocalStorageEventArgs extends EventArgs {
  /// Der Speicherschlüssel, der geändert wurde
  String key;

  /// Der neue Wert, der gespeichert wurde (oder leerer String wenn gelöscht)
  String value;

  /// Erstellt neue Event-Argumente für eine localStorage-Änderung
  ///
  /// [key] Der Speicherschlüssel, der geändert wurde
  /// [value] Der neue Wert, der gespeichert wurde
  GSDWebLocalStorageEventArgs(this.key, this.value);
}
