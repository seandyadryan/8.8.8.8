import 'dart:async';

import 'package:dartssh2/dartssh2.dart';

import '../models/proxy_config.dart';
import '../models/proxy_session.dart';

class SshDynamicProxyService {
  SSHClient? _client;
  SSHDynamicForward? _forward;

  bool get isRunning => _forward != null && !_forward!.isClosed;

  Future<ProxySession> connect(ProxyConfig config) async {
    if (isRunning) {
      return ProxySession(
        localHost: _forward!.host,
        localPort: _forward!.port,
        startedAt: DateTime.now(),
      );
    }

    if (config.password.trim().isEmpty) {
      throw const ProxyConnectionException('Password SSH masih kosong.');
    }

    final socket = await SSHSocket.connect(
      config.sshHost,
      config.sshPort,
      timeout: const Duration(seconds: 15),
    );

    final client = SSHClient(
      socket,
      username: config.username,
      onPasswordRequest: () => config.password,
      ident: 'NexusProxy_1.0',
    );

    final forward = await client.forwardDynamic(
      bindHost: config.localHost,
      bindPort: config.localPort,
      options: const SSHDynamicForwardOptions(
        handshakeTimeout: Duration(seconds: 10),
        connectTimeout: Duration(seconds: 15),
        maxConnections: 128,
      ),
    );

    _client = client;
    _forward = forward;

    return ProxySession(
      localHost: forward.host,
      localPort: forward.port,
      startedAt: DateTime.now(),
    );
  }

  Future<void> disconnect() async {
    final forward = _forward;
    final client = _client;

    _forward = null;
    _client = null;

    await forward?.close();
    client?.close();
  }
}

class ProxyConnectionException implements Exception {
  const ProxyConnectionException(this.message);

  final String message;

  @override
  String toString() => message;
}
