import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/sesi.dart';
import '../model/jadwal.dart';
import 'jadwal_rombel_screen.dart';
import 'komponen.dart';

/// Layar Jadwal Pelajaran dengan tiga tampilan:
/// Hari Ini • Jadwal Saya (seminggu) • Semua Kelas.
class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal Pelajaran'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Hari Ini'),
              Tab(text: 'Jadwal Saya'),
              Tab(text: 'Semua Kelas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_TabHariIni(), _TabJadwalSaya(), _TabSemuaKelas()],
        ),
      ),
    );
  }
}

// ── Tab 1: Hari Ini ──────────────────────────────────────────

class _TabHariIni extends StatefulWidget {
  const _TabHariIni();

  @override
  State<_TabHariIni> createState() => _TabHariIniState();
}

class _TabHariIniState extends State<_TabHariIni>
    with AutomaticKeepAliveClientMixin {
  JadwalHariIni? _data;
  bool _memuat = true;
  String? _galat;

  @override
  bool get wantKeepAlive => true;

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
      final data = await context.read<Sesi>().api.getJson('/jadwal/hari-ini');
      if (!mounted) return;
      setState(() => _data = JadwalHariIni.fromJson(data));
    } catch (e) {
      if (!mounted) return;
      setState(() => _galat = pesanJadwalDariGalat(e));
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_memuat) return const TampilMuat();
    if (_galat != null) {
      return TampilGalat(pesan: _galat!, onUlang: _muat);
    }
    final data = _data!;
    final tema = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _muat,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          Text(
            '${data.namaHari}, ${data.tanggal}',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.sedang != null
                ? 'Anda sedang mengajar ${data.sedang!.sub} di kelas ${data.sedang!.label}.'
                : data.berikutnya != null
                ? 'Mengajar berikutnya: ${data.berikutnya!.sub} di kelas ${data.berikutnya!.label}, pukul ${data.berikutnya!.mulai}.'
                : 'Tidak ada jadwal mengajar yang tersisa hari ini.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          if (data.kelasSekarang != null) ...[
            const SizedBox(height: 12),
            KartuModern(
              child: Row(
                children: [
                  Icon(Icons.meeting_room, color: tema.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelas Anda (${data.kelasSekarang!.rombel}) sekarang',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${data.kelasSekarang!.label}'
                          '${data.kelasSekarang!.sub.isNotEmpty ? ' — ${data.kelasSekarang!.sub}' : ''}',
                          style: tema.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${data.kelasSekarang!.mulai}–${data.kelasSekarang!.selesai}',
                          style: tema.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          LinimasaJadwal(
            daftar: data.daftar,
            teksKosong: 'Tidak ada jadwal mengajar hari ini.',
          ),
        ],
      ),
    );
  }
}

// ── Tab 2: Jadwal Saya (seminggu) ────────────────────────────

class _TabJadwalSaya extends StatefulWidget {
  const _TabJadwalSaya();

  @override
  State<_TabJadwalSaya> createState() => _TabJadwalSayaState();
}

class _TabJadwalSayaState extends State<_TabJadwalSaya>
    with AutomaticKeepAliveClientMixin {
  List<HariJadwal> _hari = const [];
  bool _memuat = true;
  String? _galat;
  int _pilihan = 0;

  @override
  bool get wantKeepAlive => true;

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
      final data = await context.read<Sesi>().api.getJson('/jadwal/saya');
      if (!mounted) return;
      final hari = (data['hari'] as List<dynamic>? ?? [])
          .map((e) => HariJadwal.fromJson(e as Map<String, dynamic>))
          .toList();
      final hariIni = DateTime.now().weekday; // 1=Senin .. 7=Minggu
      var pilihan = hari.indexWhere((h) => h.nomor == hariIni);
      if (pilihan < 0) pilihan = 0;
      setState(() {
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
    super.build(context);
    if (_memuat) return const TampilMuat();
    if (_galat != null) {
      return TampilGalat(pesan: _galat!, onUlang: _muat);
    }
    if (_hari.isEmpty) {
      return const PesanKosong(
        ikon: Icons.event_busy_outlined,
        teks: 'Belum ada jadwal mengajar pada semester aktif.',
      );
    }
    final terpilih = _hari[_pilihan.clamp(0, _hari.length - 1)];

    return Column(
      children: [
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
                LinimasaJadwal(
                  daftar: terpilih.blok,
                  teksKosong:
                      'Tidak ada jadwal mengajar pada hari ${terpilih.nama}.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab 3: Semua Kelas ───────────────────────────────────────

class _TabSemuaKelas extends StatefulWidget {
  const _TabSemuaKelas();

  @override
  State<_TabSemuaKelas> createState() => _TabSemuaKelasState();
}

class _TabSemuaKelasState extends State<_TabSemuaKelas>
    with AutomaticKeepAliveClientMixin {
  List<RombelJadwal> _rombel = const [];
  bool _memuat = true;
  String? _galat;

  @override
  bool get wantKeepAlive => true;

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
      final data = await context.read<Sesi>().api.getJson('/jadwal/rombel');
      if (!mounted) return;
      setState(() {
        _rombel = (data['rombel'] as List<dynamic>? ?? [])
            .map((e) => RombelJadwal.fromJson(e as Map<String, dynamic>))
            .toList();
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
    super.build(context);
    if (_memuat) return const TampilMuat();
    if (_galat != null) {
      return TampilGalat(pesan: _galat!, onUlang: _muat);
    }
    final tema = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _muat,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          const JudulBagian(
            teks: 'Jadwal Keseluruhan — per Kelas',
            ikon: Icons.meeting_room,
          ),
          const SizedBox(height: 6),
          Text(
            'Ketuk satu kelas untuk melihat jadwal lengkapnya selama seminggu.',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (_rombel.isEmpty)
            const PesanKosong(
              ikon: Icons.meeting_room_outlined,
              teks: 'Belum ada rombel pada semester aktif.',
            )
          else
            for (final r in _rombel) ...[
              KartuModern(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JadwalRombelScreen(rombelId: r.id),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.meeting_room,
                        color: tema.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelas ${r.namaRombel}',
                            style: tema.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (r.waliKelas != null)
                            Text(
                              'Wali Kelas: ${r.waliKelas}',
                              style: tema.textTheme.bodySmall?.copyWith(
                                color: tema.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}
