class ProxyConfig {
  const ProxyConfig({
    required this.profileName,
    required this.sshHost,
    required this.sshPort,
    required this.username,
    required this.password,
    required this.localHost,
    required this.localPort,
  });

  factory ProxyConfig.defaultServer() {
    return const ProxyConfig(
      profileName: 'Nexus Ubuntu',
      sshHost: '124.158.152.249',
      sshPort: 22,
      username: 'nexus',
      password: '',
      localHost: '127.0.0.1',
      localPort: 1080,
    );
  }

  final String profileName;
  final String sshHost;
  final int sshPort;
  final String username;
  final String password;
  final String localHost;
  final int localPort;

  ProxyConfig copyWith({
    String? profileName,
    String? sshHost,
    int? sshPort,
    String? username,
    String? password,
    String? localHost,
    int? localPort,
  }) {
    return ProxyConfig(
      profileName: profileName ?? this.profileName,
      sshHost: sshHost ?? this.sshHost,
      sshPort: sshPort ?? this.sshPort,
      username: username ?? this.username,
      password: password ?? this.password,
      localHost: localHost ?? this.localHost,
      localPort: localPort ?? this.localPort,
    );
  }
}
