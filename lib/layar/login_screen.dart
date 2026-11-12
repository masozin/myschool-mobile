import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/api_client.dart';
import '../layanan/sesi.dart';

/// Layar masuk modern: kepala bergradasi dengan logo, kartu
/// formulir putih melayang di bawahnya. Email/NIP + kata sandi
/// akun web MySchool; alamat server dapat diganti untuk
/// pengujian ke server lokal.
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
      // Berhasil: gerbang di main.dart berpindah ke rangka utama sendiri.
    } on ApiGagal catch (e) {
      setState(() => _galat = e.pesan);
    } catch (_) {
      setState(
        () => _galat =
            'Tidak dapat terhubung ke server. Periksa alamat server dan jaringan Anda.',
      );
    } finally {
      if (mounted) setState(() => _sibuk = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Kepala bergradasi ──────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                MediaQuery.of(context).padding.top + 36,
                24,
                64,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [tema.colorScheme.primary, tema.colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MySchool',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aplikasi Guru — Jadwal, Presensi & Data Siswa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Kartu formulir ─────────────────────────────
            Transform.translate(
              offset: const Offset(0, -36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Selamat datang kembali',
                        style: tema.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Masuk dengan akun web Anda — guru cukup memakai NIP.',
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Email atau NIP',
                          hintText: 'Guru masuk dengan NIP-nya',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _kataSandi,
                        obscureText: _sembunyiSandi,
                        decoration: InputDecoration(
                          labelText: 'Kata sandi',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _sembunyiSandi
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _sembunyiSandi = !_sembunyiSandi,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _masuk(),
                      ),
                      if (_galat != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: tema.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 19,
                                color: tema.colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  _galat!,
                                  style: TextStyle(
                                    color: tema.colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _sibuk ? null : _masuk,
                        child: _sibuk
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Masuk'),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () => setState(
                          () => _tampilkanServer = !_tampilkanServer,
                        ),
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
                            helperText:
                                'Untuk uji lokal: http://<IP laptop>:8000 (Wi-Fi yang sama)',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
