import 'dart:async';

import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import 'package:wireguard_flutter_plus/wireguard_flutter_platform_interface.dart';

import '../models/traffic_stats.dart';
import '../models/vpn_session.dart';
import '../models/wireguard_config.dart';

class WireGuardVpnService {
  WireGuardVpnService({WireGuardFlutterInterface? engine})
    : _engine = engine ?? WireGuardFlutter.instance;

  final WireGuardFlutterInterface _engine;
  bool _initialized = false;

  Stream<VpnStage> get stageStream => _engine.vpnStageSnapshot;

  Stream<TrafficStats> get trafficStream =>
      _engine.trafficSnapshot.map(TrafficStats.fromWireGuard);

  Future<void> initialize(WireGuardConfig config) async {
    if (_initialized) return;

    await _engine.initialize(
      interfaceName: config.interfaceName,
      vpnName: config.profileName,
      iosAppGroup: config.iosAppGroup,
    );
    _initialized = true;
  }

  Future<VpnSession> connect(WireGuardConfig config) async {
    if (!config.hasRequiredKeys) {
      throw const WireGuardVpnException(
        'Private key client dan public key server masih kosong.',
      );
    }

    await initialize(config);

    await _engine.startVpn(
      serverAddress: config.endpoint,
      wgQuickConfig: config.toWgQuickConfig(),
      providerBundleIdentifier: config.providerBundleIdentifier,
    );

    return VpnSession(
      profileName: config.profileName,
      endpoint: config.endpoint,
      startedAt: DateTime.now(),
    );
  }

  Future<void> disconnect() => _engine.stopVpn();

  Future<VpnStage> stage() => _engine.stage();
}

class WireGuardVpnException implements Exception {
  const WireGuardVpnException(this.message);

  final String message;

  @override
  String toString() => message;
}
