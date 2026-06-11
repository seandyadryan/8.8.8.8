import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';

import '../models/connection_state_model.dart';
import '../models/traffic_stats.dart';
import '../models/vpn_session.dart';
import '../models/wireguard_config.dart';
import '../services/wireguard_vpn_service.dart';

class VpnController extends ChangeNotifier {
  VpnController({
    required WireGuardVpnService service,
    required WireGuardConfig initialConfig,
  }) : _service = service,
       _config = initialConfig {
    _stageSubscription = _service.stageStream.listen(_handleStage);
    _trafficSubscription = _service.trafficStream.listen((stats) {
      _trafficStats = stats;
      notifyListeners();
    });
  }

  final WireGuardVpnService _service;

  late final StreamSubscription<VpnStage> _stageSubscription;
  late final StreamSubscription<TrafficStats> _trafficSubscription;

  WireGuardConfig _config;
  VpnSession? _session;
  VpnConnectionStatus _status = VpnConnectionStatus.disconnected;
  TrafficStats _trafficStats = const TrafficStats();
  String? _errorMessage;

  WireGuardConfig get config => _config;
  VpnSession? get session => _session;
  VpnConnectionStatus get status => _status;
  TrafficStats get trafficStats => _trafficStats;
  String? get errorMessage => _errorMessage;

  bool get canConnect =>
      _status == VpnConnectionStatus.disconnected ||
      _status == VpnConnectionStatus.error;

  bool get isBusy =>
      _status == VpnConnectionStatus.connecting ||
      _status == VpnConnectionStatus.disconnecting;

  bool get isConnected => _status == VpnConnectionStatus.connected;

  void updateConfig(WireGuardConfig config) {
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
    _status = VpnConnectionStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _service.connect(_config);
      _status = VpnConnectionStatus.connected;
    } catch (error) {
      _session = null;
      _status = VpnConnectionStatus.error;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> disconnect() async {
    _status = VpnConnectionStatus.disconnecting;
    notifyListeners();

    try {
      await _service.disconnect();
    } finally {
      _session = null;
      _trafficStats = const TrafficStats();
      _status = VpnConnectionStatus.disconnected;
      notifyListeners();
    }
  }

  void _handleStage(VpnStage stage) {
    switch (stage) {
      case VpnStage.connected:
        _status = VpnConnectionStatus.connected;
        break;
      case VpnStage.connecting:
      case VpnStage.authenticating:
      case VpnStage.preparing:
      case VpnStage.waitingConnection:
      case VpnStage.reconnect:
        _status = VpnConnectionStatus.connecting;
        break;
      case VpnStage.disconnecting:
      case VpnStage.exiting:
        _status = VpnConnectionStatus.disconnecting;
        break;
      case VpnStage.denied:
        _status = VpnConnectionStatus.error;
        _errorMessage = 'Izin VPN ditolak oleh sistem atau user.';
        break;
      case VpnStage.disconnected:
      case VpnStage.noConnection:
        if (_status != VpnConnectionStatus.error) {
          _status = VpnConnectionStatus.disconnected;
        }
        break;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _stageSubscription.cancel();
    _trafficSubscription.cancel();
    _service.disconnect();
    super.dispose();
  }
}
