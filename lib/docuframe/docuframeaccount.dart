part of '../gsd_utilities.dart';

/// Repräsentiert eine DOCUframe-Konto-Konfiguration mit Verbindungsdetails.
/// Behandelt Kontoinformationen, Datenbankeinstellungen und Änderungsbenachrichtigungen.
class DOCUframeAccount {
  /// Anzeigename des Kontos
  String get name {
    return _name;
  }

  /// Server-URL-Adresse für die DOCUframe-Instanz
  String get urlAddress {
    return _urlAddress;
  }

  /// Konto-Alias zur Identifikation
  String get alias {
    return _alias;
  }

  /// Benutzername für die Authentifizierung
  String get username {
    return _username;
  }

  /// Datenbankname für die Verbindung
  String get databaseName {
    return _databaseName;
  }

  /// Private Felder für Kontodaten
  String _name = "";
  String _urlAddress = "";
  String _alias = "";
  String _username = "";
  String _databaseName = "";

  /// Event, das ausgelöst wird, wenn sich eine Konto-Eigenschaft ändert
  Event accountChanged = Event();

  DOCUframeAccount(this._name, this._urlAddress, this._alias, this._username,
      this._databaseName);

  DOCUframeAccount.fromJson(Map<dynamic, dynamic> json) {
    _name = json["name"] ?? "";
    _urlAddress = json["urlAddress"] ?? "";
    _alias = json["alias"] ?? "";
    _username = json["username"] ?? "";
    _databaseName = json["databaseName"] ?? "";
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': _name,
      'urlAddress': _urlAddress,
      'alias': _alias,
      'username': _username,
      'databaseName': _databaseName,
    };

    return map;
  }

  void setName(String name) {
    _name = name;
    accountChanged.broadcast();
  }

  void setUrlAddress(String urlAddress) {
    _urlAddress = urlAddress;
    accountChanged.broadcast();
  }

  void setAlias(String alias) {
    _alias = alias;
    accountChanged.broadcast();
  }

  void setUsername(String username) {
    _username = username;
    accountChanged.broadcast();
  }

  void setDatabaseName(String databaseName) {
    _databaseName = databaseName;
    accountChanged.broadcast();
  }
}
