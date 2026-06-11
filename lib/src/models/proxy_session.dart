class ProxySession {
  const ProxySession({
    required this.localHost,
    required this.localPort,
    required this.startedAt,
  });

  final String localHost;
  final int localPort;
  final DateTime startedAt;

  String get endpoint => '$localHost:$localPort';
}
