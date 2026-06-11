import 'package:flutter/material.dart';

import '../controllers/proxy_controller.dart';
import '../models/connection_state_model.dart';
import '../models/proxy_config.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.controller});

  final ProxyController controller;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _localPortController;

  @override
  void initState() {
    super.initState();
    final config = widget.controller.config;
    _hostController = TextEditingController(text: config.sshHost);
    _portController = TextEditingController(text: config.sshPort.toString());
    _usernameController = TextEditingController(text: config.username);
    _passwordController = TextEditingController(text: config.password);
    _localPortController = TextEditingController(
      text: config.localPort.toString(),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _localPortController.dispose();
    super.dispose();
  }

  void _syncConfig() {
    widget.controller.updateConfig(
      widget.controller.config.copyWith(
        sshHost: _hostController.text.trim(),
        sshPort: int.tryParse(_portController.text.trim()) ?? 22,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        localPort: int.tryParse(_localPortController.text.trim()) ?? 1080,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
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
                          _ServerForm(
                            enabled: !connected && !controller.isBusy,
                            hostController: _hostController,
                            portController: _portController,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            localPortController: _localPortController,
                          ),
                          const SizedBox(height: 18),
                          _UsagePanel(config: controller.config),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.status});

  final ProxyConnectionStatus status;

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
          child: const Icon(Icons.shield_outlined, color: Color(0xFF0C1115)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nexus Proxy',
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

  final ProxyController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final connected = controller.isConnected;
    final session = controller.session;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF171E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF26323B)),
      ),
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
            connected ? 'Proxy aktif' : 'Proxy mati',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            connected && session != null
                ? 'SOCKS5 ${session.endpoint}'
                : 'Tekan tombol untuk membuka tunnel SSH',
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

class _ServerForm extends StatelessWidget {
  const _ServerForm({
    required this.enabled,
    required this.hostController,
    required this.portController,
    required this.usernameController,
    required this.passwordController,
    required this.localPortController,
  });

  final bool enabled;
  final TextEditingController hostController;
  final TextEditingController portController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController localPortController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171E24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF26323B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Server',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _Field(
            controller: hostController,
            label: 'Host',
            icon: Icons.dns_outlined,
            enabled: enabled,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: portController,
                  label: 'SSH Port',
                  icon: Icons.settings_ethernet_outlined,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                  controller: localPortController,
                  label: 'Local SOCKS Port',
                  icon: Icons.lan_outlined,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Field(
            controller: usernameController,
            label: 'Username',
            icon: Icons.person_outline,
            enabled: enabled,
          ),
          const SizedBox(height: 12),
          _Field(
            controller: passwordController,
            label: 'Password',
            icon: Icons.key_outlined,
            enabled: enabled,
            obscureText: true,
          ),
        ],
      ),
    );
  }
}

class _UsagePanel extends StatelessWidget {
  const _UsagePanel({required this.config});

  final ProxyConfig config;

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
            'Gunakan di browser atau sistem',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SelectableText(
            'SOCKS5 proxy: ${config.localHost}:${config.localPort}',
            style: const TextStyle(color: Color(0xFFA8B3BD)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Arahkan aplikasi yang mendukung SOCKS5 ke alamat lokal tersebut setelah status Connected.',
            style: TextStyle(color: Color(0xFFA8B3BD)),
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
