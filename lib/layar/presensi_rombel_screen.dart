import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/api_client.dart';
import '../layanan/sesi.dart';
import '../model/presensi.dart';
import 'komponen.dart';
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
      final data = await context.read<Sesi>().api.getJson(
        '/presensi/rombel-saya',
      );
      setState(() {
        _semester = SemesterRingkas.fromJson(
          data['semester'] as Map<String, dynamic>,
        );
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
      appBar: AppBar(title: const Text('Presensi')),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _galat != null
          ? TampilGalat(pesan: _galat!, onUlang: _muat)
          : RefreshIndicator(
              onRefresh: _muat,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                children: [
                  const JudulBagian(
                    teks: 'Pilih Rombel',
                    ikon: Icons.meeting_room,
                  ),
                  if (_semester != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: Text(
                        'Semester ${_semester!.label} — ketuk rombel untuk mengisi presensinya.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (_rombel.isEmpty)
                    const PesanKosong(
                      ikon: Icons.meeting_room_outlined,
                      teks:
                          'Tidak ada rombel yang dapat Anda lihat pada semester ini.',
                    ),
                  for (final r in _rombel) ...[
                    KartuModern(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PresensiIsiScreen(rombel: r),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${r.tingkat ?? '-'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.namaRombel,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                if (r.waliKelas != null)
                                  Text(
                                    'Wali: ${r.waliKelas}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: r.bolehIsi
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              r.bolehIsi ? 'Bisa diisi' : 'Lihat saja',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: r.bolehIsi
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
    );
  }
}
