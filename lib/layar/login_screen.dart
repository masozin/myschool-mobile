import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/api_client.dart';
import '../layanan/sesi.dart';

/// Layar masuk: email atau NIP + kata sandi akun web MySchool.
/// Alamat server dapat diganti (untuk pengujian server lokal).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _kataSandi = TextEditingController();
  final _server = TextEditingController();
  bool _sibuk = false;
  bool _sembunyiSandi = true;
  bool _tampilkanServer = false;
  String? _galat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_server.text.isEmpty) {
      _server.text = context.read<Sesi>().alamatServer;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _kataSandi.dispose();
    _server.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (_email.text.trim().isEmpty || _kataSandi.text.isEmpty) {
      setState(() => _galat = 'Isi email/NIP dan kata sandi dulu.');
      return;
    }
    setState(() {
      _sibuk = true;
      _galat = null;
    });
    try {
      await context.read<Sesi>().masuk(
            email: _email.text,
            kataSandi: _kataSandi.text,
            alamat: _server.text,
          );
      // Berhasil: gerbang di main.dart berpindah ke Beranda sendiri.
    } on ApiGagal catch (e) {
      setState(() => _galat = e.pesan);
    } catch (_) {
      setState(() => _galat =
          'Tidak dapat terhubung ke server. Periksa alamat server dan jaringan Anda.');
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.school, size: 64, color: tema.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'MySchool',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Aplikasi Guru — Presensi & Data Siswa',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyMedium
                      ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Email atau NIP',
                    hintText: 'Guru masuk dengan NIP-nya',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _kataSandi,
                  obscureText: _sembunyiSandi,
                  decoration: InputDecoration(
                    labelText: 'Kata sandi',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_sembunyiSandi
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _sembunyiSandi = !_sembunyiSandi),
                    ),
                  ),
                  onSubmitted: (_) => _masuk(),
                ),
                if (_galat != null) ...[
                  const SizedBox(height: 16),
                  MaterialBanner(
                    content: Text(_galat!),
                    backgroundColor: tema.colorScheme.errorContainer,
                    actions: [
                      TextButton(
                        onPressed: () => setState(() => _galat = null),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _sibuk ? null : _masuk,
                  child: _sibuk
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Masuk'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _tampilkanServer = !_tampilkanServer),
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text('Alamat server'),
                ),
                if (_tampilkanServer)
                  TextField(
                    controller: _server,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Alamat server',
                      hintText: 'https://myschool.ozinsq.my.id',
                      border: OutlineInputBorder(),
                      helperText:
                          'Untuk uji lokal: http://<IP laptop>:8000 (Wi-Fi yang sama)',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
