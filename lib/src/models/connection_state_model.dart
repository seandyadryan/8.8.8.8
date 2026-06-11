enum VpnConnectionStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

extension VpnConnectionStatusLabel on VpnConnectionStatus {
  String get label {
    switch (this) {
      case VpnConnectionStatus.disconnected:
        return 'Disconnected';
      case VpnConnectionStatus.connecting:
        return 'Connecting';
      case VpnConnectionStatus.connected:
        return 'Connected';
      case VpnConnectionStatus.disconnecting:
        return 'Disconnecting';
      case VpnConnectionStatus.error:
        return 'Connection error';
    }
  }
}
