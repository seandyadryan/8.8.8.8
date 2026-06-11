enum ProxyConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

extension ProxyConnectionStatusLabel on ProxyConnectionStatus {
  String get label {
    switch (this) {
      case ProxyConnectionStatus.disconnected:
        return 'Disconnected';
      case ProxyConnectionStatus.connecting:
        return 'Connecting';
      case ProxyConnectionStatus.connected:
        return 'Connected';
      case ProxyConnectionStatus.disconnecting:
        return 'Disconnecting';
      case ProxyConnectionStatus.error:
        return 'Connection error';
    }
  }
}
