import 'package:flutter/material.dart';

import '../controllers/vpn_controller.dart';
import '../models/connection_state_model.dart';
import '../models/wireguard_config.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.controller});

  final VpnController controller;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController _interfaceController;
  late final TextEditingController _clientPrivateKeyController;
  late final TextEditingController _clientAddressController;
  late final TextEditingController _dnsController;
  late final TextEditingController _serverPublicKeyController;
  late final TextEditingController _endpointHostController;
  late final TextEditingController _endpointPortController;
  late final TextEditingController _allowedIpsController;
  late final TextEditingController _keepaliveController;

  @override
  void initState() {
    super.initState();
    final config = widget.controller.config;
    _interfaceController = TextEditingController(text: config.interfaceName);
    _clientPrivateKeyController = TextEditingController(
      text: config.clientPrivateKey,
    );
    _clientAddressController = TextEditingController(
      text: config.clientAddress,
    );
    _dnsController = TextEditingController(text: config.dns);
    _serverPublicKeyController = TextEditingController(
      text: config.serverPublicKey,
    );
    _endpointHostController = TextEditingController(text: config.endpointHost);
    _endpointPortController = TextEditingController(
      text: config.endpointPort.toString(),
    );
    _allowedIpsController = TextEditingController(text: config.allowedIps);
    _keepaliveController = TextEditingController(
      text: config.persistentKeepalive.toString(),
    );
  }

  @override
  void dispose() {
    _interfaceController.dispose();
    _clientPrivateKeyController.dispose();
    _clientAddressController.dispose();
    _dnsController.dispose();
    _serverPublicKeyController.dispose();
    _endpointHostController.dispose();
    _endpointPortController.dispose();
    _allowedIpsController.dispose();
    _keepaliveController.dispose();
    super.dispose();
  }

  void _syncConfig() {
    widget.controller.updateConfig(
      widget.controller.config.copyWith(
        interfaceName: _interfaceController.text.trim(),
        clientPrivateKey: _clientPrivateKeyController.text.trim(),
        clientAddress: _clientAddressController.text.trim(),
        dns: _dnsController.text.trim(),
        serverPublicKey: _serverPublicKeyController.text.trim(),
        endpointHost: _endpointHostController.text.trim(),
        endpointPort:
            int.tryParse(_endpointPortController.text.trim()) ?? 51820,
        allowedIps: _allowedIpsController.text.trim(),
        persistentKeepalive:
            int.tryParse(_keepaliveController.text.trim()) ?? 25,
      ),
    );
  }

  Future<void> _toggle() async {
    _syncConfig();
    await widget.controller.toggleConnection();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final connected = controller.isConnected;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(status: controller.status),
                      const SizedBox(height: 24),
                      _ConnectionPanel(
                        controller: controller,
                        onToggle: _toggle,
                      ),
                      const SizedBox(height: 18),
                      _StatsPanel(controller: controller),
                      const SizedBox(height: 18),
                      _WireGuardForm(
                        enabled: !connected && !controller.isBusy,
                        interfaceController: _interfaceController,
                        clientPrivateKeyController: _clientPrivateKeyController,
                        clientAddressController: _clientAddressController,
                        dnsController: _dnsController,
                        serverPublicKeyController: _serverPublicKeyController,
                        endpointHostController: _endpointHostController,
                        endpointPortController: _endpointPortController,
                        allowedIpsController: _allowedIpsController,
                        keepaliveController: _keepaliveController,
                      ),
                      const SizedBox(height: 18),
                      _ConfigPreview(config: _currentPreviewConfig()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  WireGuardConfig _currentPreviewConfig() {
    return widget.controller.config.copyWith(
      interfaceName: _interfaceController.text.trim(),
      clientPrivateKey: _clientPrivateKeyController.text.trim(),
      clientAddress: _clientAddressController.text.trim(),
      dns: _dnsController.text.trim(),
      serverPublicKey: _serverPublicKeyController.text.trim(),
      endpointHost: _endpointHostController.text.trim(),
      endpointPort: int.tryParse(_endpointPortController.text.trim()) ?? 51820,
      allowedIps: _allowedIpsController.text.trim(),
      persistentKeepalive: int.tryParse(_keepaliveController.text.trim()) ?? 25,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.status});

  final VpnConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF35D07F),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.vpn_lock_outlined, color: Color(0xFF0C1115)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nexus WireGuard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                status.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA8B3BD),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel({required this.controller, required this.onToggle});

  final VpnController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final connected = controller.isConnected;
    final session = controller.session;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: FilledButton(
              onPressed: controller.isBusy ? null : onToggle,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: connected
                    ? const Color(0xFF35D07F)
                    : const Color(0xFF26323B),
                foregroundColor: connected
                    ? const Color(0xFF0C1115)
                    : Colors.white,
              ),
              child: controller.isBusy
                  ? const SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : Icon(
                      connected ? Icons.power_settings_new : Icons.power,
                      size: 64,
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            connected ? 'VPN aktif' : 'VPN mati',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            connected && session != null
                ? '${session.profileName} lewat ${session.endpoint}'
                : 'Tekan tombol untuk membuka tunnel WireGuard',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFA8B3BD)),
          ),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              controller.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFFA3A3)),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  const _StatsPanel({required this.controller});

  final VpnController controller;

  @override
  Widget build(BuildContext context) {
    final stats = controller.trafficStats;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatTile(label: 'Download', value: stats.downloadSpeed),
          _StatTile(label: 'Upload', value: stats.uploadSpeed),
          _StatTile(label: 'Total Down', value: stats.totalDownload),
          _StatTile(label: 'Total Up', value: stats.totalUpload),
          _StatTile(label: 'Durasi', value: stats.duration),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFA8B3BD), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _WireGuardForm extends StatelessWidget {
  const _WireGuardForm({
    required this.enabled,
    required this.interfaceController,
    required this.clientPrivateKeyController,
    required this.clientAddressController,
    required this.dnsController,
    required this.serverPublicKeyController,
    required this.endpointHostController,
    required this.endpointPortController,
    required this.allowedIpsController,
    required this.keepaliveController,
  });

  final bool enabled;
  final TextEditingController interfaceController;
  final TextEditingController clientPrivateKeyController;
  final TextEditingController clientAddressController;
  final TextEditingController dnsController;
  final TextEditingController serverPublicKeyController;
  final TextEditingController endpointHostController;
  final TextEditingController endpointPortController;
  final TextEditingController allowedIpsController;
  final TextEditingController keepaliveController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WireGuard Profile',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _Field(
            controller: interfaceController,
            label: 'Interface',
            icon: Icons.settings_input_component_outlined,
            enabled: enabled,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: clientPrivateKeyController,
            label: 'Client Private Key',
            icon: Icons.key_outlined,
            enabled: enabled,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: serverPublicKeyController,
            label: 'Server Public Key',
            icon: Icons.verified_user_outlined,
            enabled: enabled,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _Field(
                  controller: endpointHostController,
                  label: 'Endpoint Host',
                  icon: Icons.dns_outlined,
                  enabled: enabled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                  controller: endpointPortController,
                  label: 'UDP Port',
                  icon: Icons.lan_outlined,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: clientAddressController,
                  label: 'Client Address',
                  icon: Icons.badge_outlined,
                  enabled: enabled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                  controller: keepaliveController,
                  label: 'Keepalive',
                  icon: Icons.timer_outlined,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            controller: dnsController,
            label: 'DNS',
            icon: Icons.public_outlined,
            enabled: enabled,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: allowedIpsController,
            label: 'Allowed IPs',
            icon: Icons.route_outlined,
            enabled: enabled,
          ),
        ],
      ),
    );
  }
}

class _ConfigPreview extends StatelessWidget {
  const _ConfigPreview({required this.config});

  final WireGuardConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12181D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF24313A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview .conf',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SelectableText(
            config.toWgQuickConfig(),
            style: const TextStyle(
              color: Color(0xFFA8B3BD),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    color: const Color(0xFF171E24),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFF26323B)),
  );
}
