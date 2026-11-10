import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../konfigurasi.dart';
import '../layanan/api_client.dart';
import '../layanan/sesi.dart';
import '../model/siswa.dart';

/// Biodata satu siswa dari GET /api/siswa/{id}.
/// Nomor NIK memang tidak dikirim server ke aplikasi mobile.
class SiswaDetailScreen extends StatefulWidget {
  const SiswaDetailScreen({super.key, required this.siswaId});

  final int siswaId;

  @override
  State<SiswaDetailScreen> createState() => _SiswaDetailScreenState();
}

class _SiswaDetailScreenState extends State<SiswaDetailScreen> {
  SiswaDetail? _detail;
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
          await context.read<Sesi>().api.getJson('/siswa/${widget.siswaId}');
      setState(() {
        _detail =
            SiswaDetail.fromJson(data['siswa'] as Map<String, dynamic>);
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
      appBar: AppBar(title: const Text('Detail Siswa')),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _galat != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 12),
                        Text(_galat!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _muat,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _isi(context),
    );
  }

  Widget _isi(BuildContext context) {
    final d = _detail!;
    final s = d.ringkas;
    final tema = Theme.of(context);

    final baris = <List<String>>[
      ['Nama', s.namaSiswa],
      ['NISN', s.nisn ?? '-'],
      ['NIS (sekolah)', s.nis ?? '-'],
      ['Jenis kelamin', s.jenisKelamin ?? '-'],
      [
        'Tempat, tanggal lahir',
        '${s.tempatLahir ?? '-'}, ${formatTanggalDariApi(s.tglLahir)}'
      ],
      ['Agama', d.agama ?? '-'],
      ['Rombel', s.rombel?.namaRombel ?? '-'],
      ['Status registrasi', d.statusRegistrasi ?? '-'],
      ['Tanggal diterima', formatTanggalDariApi(d.tanggalDiterima)],
      ['Alamat', d.alamat ?? '-'],
      ['Nama ayah', d.namaAyah ?? '-'],
      ['Nama ibu', d.namaIbu ?? '-'],
      ['Nama wali', d.namaWali ?? '-'],
      ['No. HP', d.noHp ?? '-'],
      if (d.disabilitas != null && d.disabilitas!.isNotEmpty)
        ['Disabilitas', d.disabilitas!],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: tema.colorScheme.primaryContainer,
              child: Text(
                s.inisial,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: tema.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                s.namaSiswa,
                style: tema.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < baris.length; i++) ...[
                ListTile(
                  dense: true,
                  title: Text(baris[i][0]),
                  subtitle: Text(
                    baris[i][1],
                    style: tema.textTheme.bodyLarge,
                  ),
                ),
                if (i < baris.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
