import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/api_client.dart';
import '../layanan/sesi.dart';
import '../model/presensi.dart';
import 'presensi_isi_screen.dart';

/// Pilih rombel untuk presensi — daftar mengikuti peran pengguna
/// dan semester aktif (dari GET /api/presensi/rombel-saya).
class PresensiRombelScreen extends StatefulWidget {
  const PresensiRombelScreen({super.key});

  @override
  State<PresensiRombelScreen> createState() => _PresensiRombelScreenState();
}

class _PresensiRombelScreenState extends State<PresensiRombelScreen> {
  SemesterRingkas? _semester;
  List<RombelRingkas> _rombel = [];
  bool _memuat = true;
  String? _galat;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() {
      _memuat = true;
      _galat = null;
    });
    try {
      final data =
          await context.read<Sesi>().api.getJson('/presensi/rombel-saya');
      setState(() {
        _semester = SemesterRingkas.fromJson(
            data['semester'] as Map<String, dynamic>);
        _rombel = (data['rombel'] as List<dynamic>)
            .map((e) => RombelRingkas.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } on ApiGagal catch (e) {
      setState(() => _galat = e.pesan);
    } catch (_) {
      setState(() => _galat = 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presensi — Pilih Rombel')),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _galat != null
              ? _GalatTampil(pesan: _galat!, onCobaLagi: _muat)
              : RefreshIndicator(
                  onRefresh: _muat,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_semester != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Semester ${_semester!.label}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      if (_rombel.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(
                            child: Text(
                                'Tidak ada rombel yang dapat Anda lihat pada semester ini.'),
                          ),
                        ),
                      for (final r in _rombel)
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${r.tingkat ?? '-'}'),
                            ),
                            title: Text(r.namaRombel),
                            subtitle: Text(
                              [
                                if (r.waliKelas != null)
                                  'Wali: ${r.waliKelas}',
                                if (r.namaSekolah != null) r.namaSekolah!,
                              ].join(' · '),
                            ),
                            trailing: Chip(
                              label: Text(
                                  r.bolehIsi ? 'Bisa diisi' : 'Lihat saja'),
                              visualDensity: VisualDensity.compact,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PresensiIsiScreen(rombel: r),
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

class _GalatTampil extends StatelessWidget {
  const _GalatTampil({required this.pesan, required this.onCobaLagi});

  final String pesan;
  final Future<void> Function() onCobaLagi;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onCobaLagi,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
