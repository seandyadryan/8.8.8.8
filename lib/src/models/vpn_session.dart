class VpnSession {
  const VpnSession({
    required this.profileName,
    required this.endpoint,
    required this.startedAt,
  });

  final String profileName;
  final String endpoint;
  final DateTime startedAt;
}
