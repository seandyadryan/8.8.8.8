class WireGuardConfig {
  const WireGuardConfig({
    required this.profileName,
    required this.interfaceName,
    required this.clientPrivateKey,
    required this.clientAddress,
    required this.dns,
    required this.serverPublicKey,
    required this.endpointHost,
    required this.endpointPort,
    required this.allowedIps,
    required this.persistentKeepalive,
    required this.providerBundleIdentifier,
    required this.iosAppGroup,
  });

  factory WireGuardConfig.defaultServer() {
    return const WireGuardConfig(
      profileName: 'Nexus WireGuard',
      interfaceName: 'nexuswg',
      clientPrivateKey: '',
      clientAddress: '10.8.0.2/32',
      dns: '1.1.1.1, 8.8.8.8',
      serverPublicKey: '',
      endpointHost: '124.158.152.249',
      endpointPort: 51820,
      allowedIps: '0.0.0.0/0',
      persistentKeepalive: 25,
      providerBundleIdentifier: 'com.example.warpProxyClient.WGExtension',
      iosAppGroup: 'group.com.example.warpProxyClient',
    );
  }

  final String profileName;
  final String interfaceName;
  final String clientPrivateKey;
  final String clientAddress;
  final String dns;
  final String serverPublicKey;
  final String endpointHost;
  final int endpointPort;
  final String allowedIps;
  final int persistentKeepalive;
  final String providerBundleIdentifier;
  final String iosAppGroup;

  String get endpoint => '$endpointHost:$endpointPort';

  bool get hasRequiredKeys =>
      clientPrivateKey.trim().isNotEmpty && serverPublicKey.trim().isNotEmpty;

  String toWgQuickConfig() {
    final keepalive = persistentKeepalive > 0
        ? '\nPersistentKeepalive = $persistentKeepalive'
        : '';

    return '''
[Interface]
PrivateKey = ${clientPrivateKey.trim()}
Address = ${clientAddress.trim()}
DNS = ${dns.trim()}

[Peer]
PublicKey = ${serverPublicKey.trim()}
Endpoint = $endpoint
AllowedIPs = ${allowedIps.trim()}$keepalive
''';
  }

  WireGuardConfig copyWith({
    String? profileName,
    String? interfaceName,
    String? clientPrivateKey,
    String? clientAddress,
    String? dns,
    String? serverPublicKey,
    String? endpointHost,
    int? endpointPort,
    String? allowedIps,
    int? persistentKeepalive,
    String? providerBundleIdentifier,
    String? iosAppGroup,
  }) {
    return WireGuardConfig(
      profileName: profileName ?? this.profileName,
      interfaceName: interfaceName ?? this.interfaceName,
      clientPrivateKey: clientPrivateKey ?? this.clientPrivateKey,
      clientAddress: clientAddress ?? this.clientAddress,
      dns: dns ?? this.dns,
      serverPublicKey: serverPublicKey ?? this.serverPublicKey,
      endpointHost: endpointHost ?? this.endpointHost,
      endpointPort: endpointPort ?? this.endpointPort,
      allowedIps: allowedIps ?? this.allowedIps,
      persistentKeepalive: persistentKeepalive ?? this.persistentKeepalive,
      providerBundleIdentifier:
          providerBundleIdentifier ?? this.providerBundleIdentifier,
      iosAppGroup: iosAppGroup ?? this.iosAppGroup,
    );
  }
}
