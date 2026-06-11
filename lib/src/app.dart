import 'package:flutter/material.dart';

import 'controllers/proxy_controller.dart';
import 'models/proxy_config.dart';
import 'services/ssh_dynamic_proxy_service.dart';
import 'views/home_view.dart';

class WarpProxyApp extends StatefulWidget {
  const WarpProxyApp({super.key});

  @override
  State<WarpProxyApp> createState() => _WarpProxyAppState();
}

class _WarpProxyAppState extends State<WarpProxyApp> {
  late final ProxyController controller;

  @override
  void initState() {
    super.initState();
    controller = ProxyController(
      service: SshDynamicProxyService(),
      initialConfig: ProxyConfig.defaultServer(),
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
      title: 'Nexus Proxy',
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
