import 'package:flutter/foundation.dart';

import '../models/connection_state_model.dart';
import '../models/proxy_config.dart';
import '../models/proxy_session.dart';
import '../services/ssh_dynamic_proxy_service.dart';

class ProxyController extends ChangeNotifier {
  ProxyController({
    required SshDynamicProxyService service,
    required ProxyConfig initialConfig,
  }) : _service = service,
       _config = initialConfig;

  final SshDynamicProxyService _service;

  ProxyConfig _config;
  ProxySession? _session;
  ProxyConnectionStatus _status = ProxyConnectionStatus.disconnected;
  String? _errorMessage;

  ProxyConfig get config => _config;
  ProxySession? get session => _session;
  ProxyConnectionStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get canConnect =>
      _status == ProxyConnectionStatus.disconnected ||
      _status == ProxyConnectionStatus.error;

  bool get isBusy =>
      _status == ProxyConnectionStatus.connecting ||
      _status == ProxyConnectionStatus.disconnecting;

  bool get isConnected => _status == ProxyConnectionStatus.connected;

  void updateConfig(ProxyConfig config) {
    _config = config;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> toggleConnection() async {
    if (isConnected) {
      await disconnect();
      return;
    }

    if (canConnect) {
      await connect();
    }
  }

  Future<void> connect() async {
    _status = ProxyConnectionStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _service.connect(_config);
      _status = ProxyConnectionStatus.connected;
    } catch (error) {
      _session = null;
      _status = ProxyConnectionStatus.error;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    _status = ProxyConnectionStatus.disconnecting;
    notifyListeners();

    try {
      await _service.disconnect();
    } finally {
      _session = null;
      _status = ProxyConnectionStatus.disconnected;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.disconnect();
    super.dispose();
  }
}
