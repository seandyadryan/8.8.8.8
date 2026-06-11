import 'package:flutter/material.dart';

import 'controllers/vpn_controller.dart';
import 'models/wireguard_config.dart';
import 'services/wireguard_vpn_service.dart';
import 'views/home_view.dart';

class NexusWireGuardApp extends StatefulWidget {
  const NexusWireGuardApp({super.key});

  @override
  State<NexusWireGuardApp> createState() => _NexusWireGuardAppState();
}

class _NexusWireGuardAppState extends State<NexusWireGuardApp> {
  late final VpnController controller;

  @override
  void initState() {
    super.initState();
    controller = VpnController(
      service: WireGuardVpnService(),
      initialConfig: WireGuardConfig.defaultServer(),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus WireGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF35D07F),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101418),
        useMaterial3: true,
      ),
      home: HomeView(controller: controller),
    );
  }
}
