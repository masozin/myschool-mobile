import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/sesi.dart';
import '../konfigurasi.dart';
import '../model/info.dart';
import '../model/jadwal.dart';
import 'komponen.dart';

/// Beranda modern: sapaan, kartu "saat ini" bergradasi, linimasa
/// jadwal mengajar hari ini, dan menu cepat ke tab lain.
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key, required this.onBukaTab});

  /// Berpindah tab pada rangka utama (0 Beranda, 1 Jadwal,
  /// 2 Presensi, 3 Siswa).
  final ValueChanged<int> onBukaTab;

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  JadwalHariIni? _hariIni;
  InfoHariIni? _info;
  bool _memuat = true;
  String? _galatJadwal;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    try {
      final data = await context.read<Sesi>().api.getJson('/jadwal/hari-ini');
      if (!mounted) return;
      setState(() {
        _hariIni = JadwalHariIni.fromJson(data);
        _galatJadwal = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _galatJadwal = pesanJadwalDariGalat(e));
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
    // Info hari ini (kaldik & ulang tahun) — kegagalan diabaikan
    // diam-diam: kartunya cukup tidak ditampilkan.
    try {
      final dataInfo = await context.read<Sesi>().api.getJson('/info-hari-ini');
      if (!mounted) return;
      setState(() => _info = InfoHariIni.fromJson(dataInfo));
    } catch (_) {
      // Abaikan.
    }
  }

  String get _sapaan {
    final jam = DateTime.now().hour;
    if (jam < 11) return 'Selamat pagi';
    if (jam < 15) return 'Selamat siang';
    if (jam < 19) return 'Selamat sore';
    return 'Selamat malam';
  }

  Future<void> _keluar(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari aplikasi?'),
        content: const Text(
          'Anda perlu masuk lagi dengan email/NIP dan kata sandi untuk memakai aplikasi ini.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yakin == true && context.mounted) {
      await context.read<Sesi>().keluar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengguna = context.watch<Sesi>().pengguna!;
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _muat,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            children: [
              // ── Sapaan ────────────────────────────────────
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: tema.colorScheme.primary,
                    child: Text(
                      pengguna.inisial,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sapaan,
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          pengguna.nama,
                          style: tema.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pengguna.ptk?.namaSekolah != null)
                          Text(
                            pengguna.ptk!.namaSekolah!,
                            style: tema.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Keluar',
                    onPressed: () => _keluar(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Kartu saat ini ────────────────────────────
              _KartuSaatIni(
                hariIni: _hariIni,
                memuat: _memuat,
                galat: _galatJadwal,
                onTap: () => widget.onBukaTab(1),
              ),
              const SizedBox(height: 22),

              // ── Info hari ini: ucapan, kaldik, ulang tahun ──
              if (_info?.ultahSaya != null) ...[
                _KartuUcapanSaya(ultah: _info!.ultahSaya!),
                const SizedBox(height: 16),
              ],
              if (_info != null && _info!.kaldik.isNotEmpty) ...[
                _KartuKaldik(daftar: _info!.kaldik),
                const SizedBox(height: 16),
              ],
              if (_info != null && _info!.ulangTahun.isNotEmpty) ...[
                _KartuUlangTahun(daftar: _info!.ulangTahun),
                const SizedBox(height: 16),
              ],

              // ── Jadwal hari ini ───────────────────────────
              const JudulBagian(
                teks: 'Jadwal Mengajar Hari Ini',
                ikon: Icons.schedule,
              ),
              const SizedBox(height: 10),
              if (_memuat)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_galatJadwal != null)
                KartuModern(
                  child: Text(
                    _galatJadwal!,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: tema.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                LinimasaJadwal(
                  daftar: _hariIni?.daftar ?? const [],
                  teksKosong: 'Tidak ada jadwal mengajar hari ini.',
                ),
              const SizedBox(height: 10),

              // ── Menu cepat ────────────────────────────────
              const JudulBagian(teks: 'Menu Cepat', ikon: Icons.grid_view),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _MenuCepat(
                      ikon: Icons.calendar_month,
                      judul: 'Jadwal',
                      keterangan: 'Hari ini & seminggu',
                      onTap: () => widget.onBukaTab(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MenuCepat(
                      ikon: Icons.fact_check,
                      judul: 'Presensi',
                      keterangan: 'Isi kehadiran siswa',
                      onTap: () => widget.onBukaTab(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MenuCepat(
                      ikon: Icons.groups,
                      judul: 'Siswa',
                      keterangan: 'Daftar & biodata',
                      onTap: () => widget.onBukaTab(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu pahlawan bergradasi: keadaan jadwal tepat saat ini.
class _KartuSaatIni extends StatelessWidget {
  const _KartuSaatIni({
    required this.hariIni,
    required this.memuat,
    required this.galat,
    required this.onTap,
  });

  final JadwalHariIni? hariIni;
  final bool memuat;
  final String? galat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    String judul = 'Memuat jadwal…';
    String keterangan = '';
    IconData ikon = Icons.schedule;

    final data = hariIni;
    if (!memuat && galat != null) {
      judul = 'Jadwal belum tersedia';
      keterangan = galat!;
      ikon = Icons.cloud_off_outlined;
    } else if (!memuat && data != null) {
      if (data.sedang != null) {
        judul = 'Sedang mengajar ${data.sedang!.sub}';
        keterangan =
            'Kelas ${data.sedang!.label} • ${data.sedang!.mulai}–${data.sedang!.selesai}';
        ikon = Icons.co_present;
      } else if (data.kelasSekarang != null) {
        judul = 'Kelas Anda: ${data.kelasSekarang!.label}';
        keterangan =
            '${data.kelasSekarang!.rombel} • ${data.kelasSekarang!.mulai}–${data.kelasSekarang!.selesai}'
            '${data.kelasSekarang!.sub.isNotEmpty ? ' • ${data.kelasSekarang!.sub}' : ''}';
        ikon = Icons.meeting_room;
      } else if (data.berikutnya != null) {
        judul = 'Berikutnya: ${data.berikutnya!.sub}';
        keterangan =
            'Kelas ${data.berikutnya!.label} • mulai ${data.berikutnya!.mulai}';
        ikon = Icons.upcoming;
      } else {
        judul = 'Tidak ada jadwal saat ini';
        keterangan = 'Tidak ada lagi jadwal mengajar hari ini.';
        ikon = Icons.event_available;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [tema.colorScheme.primary, tema.colorScheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: tema.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    data == null
                        ? 'JADWAL HARI INI'
                        : '${data.namaHari.toUpperCase()} • ${data.tanggal.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(ikon, color: Colors.white, size: 26),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              judul,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
            if (keterangan.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                keterangan,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 13.5,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Row(
              children: [
                Text(
                  'Buka Jadwal Pelajaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCepat extends StatelessWidget {
  const _MenuCepat({
    required this.ikon,
    required this.judul,
    required this.keterangan,
    required this.onTap,
  });

  final IconData ikon;
  final String judul;
  final String keterangan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return KartuModern(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: tema.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ikon,
              size: 22,
              color: tema.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            judul,
            style: tema.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            keterangan,
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu perayaan bergradasi bila yang berulang tahun adalah
/// pengguna sendiri — ucapan resmi + doa dari server.
class _KartuUcapanSaya extends StatelessWidget {
  const _KartuUcapanSaya({required this.ultah});

  final UltahHariIni ultah;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [Colors.pink.shade400, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cake, color: Colors.white, size: 24),
              SizedBox(width: 9),
              Text(
                'HARI ISTIMEWA ANDA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ultah.ucapanJudul ?? 'Selamat Ulang Tahun, ${ultah.nama}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          if (ultah.ucapanDoa != null) ...[
            const SizedBox(height: 8),
            Text(
              ultah.ucapanDoa!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.94),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu kegiatan Kalender Pendidikan yang berlangsung hari ini.
class _KartuKaldik extends StatelessWidget {
  const _KartuKaldik({required this.daftar});

  final List<KaldikHariIni> daftar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return KartuModern(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.event_note,
                  size: 20,
                  color: Colors.amber.shade800,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Kalender Pendidikan Hari Ini',
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final k in daftar) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          k.kegiatan,
                          style: tema.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (k.tanggalMulai != null)
                          Text(
                            k.tanggalMulai == k.tanggalSelesai
                                ? formatTanggalDariApi(k.tanggalMulai)
                                : '${formatTanggalDariApi(k.tanggalMulai)} – ${formatTanggalDariApi(k.tanggalSelesai)}',
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: tema.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (k.isLibur)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'LIBUR',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: tema.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kartu daftar guru yang berulang tahun hari ini.
class _KartuUlangTahun extends StatelessWidget {
  const _KartuUlangTahun({required this.daftar});

  final List<UltahHariIni> daftar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return KartuModern(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.cake_outlined,
                  size: 20,
                  color: Colors.pink.shade600,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Ulang Tahun Hari Ini',
                  style: tema.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final u in daftar)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: tema.colorScheme.primaryContainer,
                    child: Text(
                      u.inisial,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: tema.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                u.nama,
                                style: tema.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (u.saya) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tema.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: const Text(
                                  'ANDA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          [
                            if (u.jabatan.isNotEmpty) u.jabatan,
                            if (u.usia != null) 'ke-${u.usia}',
                          ].join(' • '),
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.celebration,
                    size: 19,
                    color: Colors.pink.shade400,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
