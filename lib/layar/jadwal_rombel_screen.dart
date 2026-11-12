import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/sesi.dart';
import '../model/jadwal.dart';
import 'komponen.dart';

/// Jadwal lengkap satu rombel selama seminggu: pemilih hari
/// berbentuk chip + linimasa blok hari terpilih.
class JadwalRombelScreen extends StatefulWidget {
  const JadwalRombelScreen({super.key, required this.rombelId});

  final int rombelId;

  @override
  State<JadwalRombelScreen> createState() => _JadwalRombelScreenState();
}

class _JadwalRombelScreenState extends State<JadwalRombelScreen> {
  RombelJadwal? _rombel;
  List<HariJadwal> _hari = const [];
  bool _memuat = true;
  String? _galat;
  int _pilihan = 0;

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
        '/jadwal/rombel/${widget.rombelId}',
      );
      if (!mounted) return;
      final hari = (data['hari'] as List<dynamic>? ?? [])
          .map((e) => HariJadwal.fromJson(e as Map<String, dynamic>))
          .toList();
      final hariIni = DateTime.now().weekday;
      var pilihan = hari.indexWhere((h) => h.nomor == hariIni);
      if (pilihan < 0) pilihan = 0;
      setState(() {
        _rombel = RombelJadwal.fromJson(data['rombel'] as Map<String, dynamic>);
        _hari = hari;
        _pilihan = pilihan;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _galat = pesanJadwalDariGalat(e));
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _rombel == null ? 'Jadwal Kelas' : 'Kelas ${_rombel!.namaRombel}',
        ),
      ),
      body: _memuat
          ? const TampilMuat()
          : _galat != null
          ? TampilGalat(pesan: _galat!, onUlang: _muat)
          : Column(
              children: [
                if (_rombel?.waliKelas != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: KartuModern(
                      child: Row(
                        children: [
                          Icon(Icons.person, color: tema.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Wali Kelas: ${_rombel!.waliKelas}',
                              style: tema.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _hari.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(_hari[i].nama),
                              selected: i == _pilihan,
                              onSelected: (_) => setState(() => _pilihan = i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _muat,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                      children: [
                        if (_hari.isEmpty)
                          const PesanKosong(
                            ikon: Icons.event_busy_outlined,
                            teks:
                                'Kelas ini belum mempunyai hari aktif pada kerangkanya.',
                          )
                        else
                          LinimasaJadwal(
                            daftar:
                                _hari[_pilihan.clamp(0, _hari.length - 1)].blok,
                            teksKosong: 'Tidak ada jadwal pada hari ini.',
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
