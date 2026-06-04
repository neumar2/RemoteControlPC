class Profile {
  String id;
  String name;
  String localIp;
  String vpnIp;
  String macAddress;
  String smbUsername;
  String smbPassword;
  String smbDomain;
  bool hasGamingMacros;
  bool hasSMBFiles;

  Profile({
    required this.id,
    required this.name,
    required this.localIp,
    required this.vpnIp,
    required this.macAddress,
    this.smbUsername = '',
    this.smbPassword = '',
    this.smbDomain = '',
    this.hasGamingMacros = true,
    this.hasSMBFiles = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'localIp': localIp,
        'vpnIp': vpnIp,
        'macAddress': macAddress,
        'smbUsername': smbUsername,
        'smbPassword': smbPassword,
        'smbDomain': smbDomain,
        'hasGamingMacros': hasGamingMacros,
        'hasSMBFiles': hasSMBFiles,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'],
        name: json['name'],
        localIp: json['localIp'],
        vpnIp: json['vpnIp'],
        macAddress: json['macAddress'],
        smbUsername: json['smbUsername'] ?? '',
        smbPassword: json['smbPassword'] ?? '',
        smbDomain: json['smbDomain'] ?? '',
        hasGamingMacros: json['hasGamingMacros'] ?? true,
        hasSMBFiles: json['hasSMBFiles'] ?? true,
      );
}
