import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../konfigurasi.dart';
import '../layanan/api_client.dart';
import '../layanan/sesi.dart';
import '../model/presensi.dart';

/// Isi presensi satu rombel pada satu tanggal. Aturan tanggal,
/// roster, dan hak mengisi ditegakkan server (sama seperti web);
/// layar ini hanya menampilkan hasilnya dan mengirim pilihan guru.
/// Siswa yang belum dipilih statusnya TIDAK ikut terkirim.
class PresensiIsiScreen extends StatefulWidget {
  const PresensiIsiScreen({super.key, required this.rombel});

  final RombelRingkas rombel;

  @override
  State<PresensiIsiScreen> createState() => _PresensiIsiScreenState();
}

class _PresensiIsiScreenState extends State<PresensiIsiScreen> {
  DateTime _tanggal = DateTime.now();
  SemesterRingkas? _semester;
  List<BarisPresensi> _baris = [];
  bool _bolehIsi = false;
  bool _memuat = true;
  bool _menyimpan = false;
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
        '/presensi/roster',
        params: {
          'rombel_id': '${widget.rombel.id}',
          'tanggal': formatTanggalApi(_tanggal),
        },
      );
      setState(() {
        _semester = SemesterRingkas.fromJson(
            data['semester'] as Map<String, dynamic>);
        _bolehIsi = data['boleh_isi'] as bool? ?? false;
        _baris = (data['siswa'] as List<dynamic>)
            .map((e) => BarisPresensi.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } on ApiGagal catch (e) {
      setState(() {
        _galat = e.pesan;
        _baris = [];
        _bolehIsi = false;
      });
    } catch (_) {
      setState(() => _galat = 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _memuat = false);
    }
  }

  Future<void> _pilihTanggal() async {
    final hariIni = DateTime.now();
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: _semester?.mulaiDate ?? DateTime(2020),
      lastDate: hariIni,
      helpText: 'Pilih tanggal presensi',
    );
    if (dipilih != null) {
      setState(() => _tanggal = dipilih);
      await _muat();
    }
  }

  void _semuaHadir() {
    setState(() {
      for (final b in _baris) {
        b.status ??= 'hadir';
      }
    });
  }

  Future<void> _simpan() async {
    final terpilih = _baris.where((b) => b.status != null).toList();
    if (terpilih.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Belum ada siswa yang dipilih statusnya.')),
      );
      return;
    }
    setState(() => _menyimpan = true);
    try {
      final data = await context.read<Sesi>().api.postJson('/presensi', {
        'rombel_id': widget.rombel.id,
        'tanggal': formatTanggalApi(_tanggal),
        'presensi': [
          for (final b in terpilih)
            {
              'siswa_id': b.siswaId,
              'status': b.status,
              'keterangan': b.keterangan,
            },
        ],
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] as String? ?? 'Tersimpan.')),
      );
      await _muat();
    } on ApiGagal catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.pesan)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Map<String, int> get _ringkasan {
    final hasil = <String, int>{for (final s in kStatusPresensi) s: 0};
    var belum = 0;
    for (final b in _baris) {
      if (b.status == null) {
        belum++;
      } else {
        hasil[b.status!] = (hasil[b.status!] ?? 0) + 1;
      }
    }
    hasil['belum'] = belum;
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    final ringkasan = _ringkasan;
    return Scaffold(
      appBar: AppBar(title: Text('Presensi ${widget.rombel.namaRombel}')),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatTanggalPanjang(_tanggal),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _memuat ? null : _pilihTanggal,
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Ganti tanggal'),
                      ),
                    ],
                  ),
                  if (!_memuat && _galat == null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final s in kStatusPresensi)
                          Chip(
                            label: Text('${kLabelStatus[s]}: ${ringkasan[s]}'),
                            visualDensity: VisualDensity.compact,
                          ),
                        Chip(
                          label: Text('Belum dipilih: ${ringkasan['belum']}'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                  if (!_bolehIsi && !_memuat && _galat == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Mode lihat saja — Anda tidak mengisi presensi rombel/tanggal ini.',
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _memuat
                ? const Center(child: CircularProgressIndicator())
                : _galat != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_busy_outlined, size: 48),
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
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _baris.length,
                        itemBuilder: (ctx, i) => _KartuSiswa(
                          baris: _baris[i],
                          dapatDiisi: _bolehIsi,
                          onBerubah: () => setState(() {}),
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _bolehIsi && _galat == null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: _menyimpan ? null : _semuaHadir,
                      child: const Text('Semua Hadir'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _menyimpan ? null : _simpan,
                        icon: _menyimpan
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Simpan Presensi'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

/// Kartu satu siswa: nama, NISN, dan empat tombol status.
/// Mengetuk status yang sama sekali lagi membatalkannya.
class _KartuSiswa extends StatelessWidget {
  const _KartuSiswa({
    required this.baris,
    required this.dapatDiisi,
    required this.onBerubah,
  });

  final BarisPresensi baris;
  final bool dapatDiisi;
  final VoidCallback onBerubah;

  static const _warnaStatus = <String, Color>{
    'hadir': Colors.green,
    'izin': Colors.amber,
    'sakit': Colors.deepOrange,
    'alpa': Colors.red,
  };

  static const _singkatan = <String, String>{
    'hadir': 'H',
    'izin': 'I',
    'sakit': 'S',
    'alpa': 'A',
  };

  Future<void> _ubahKeterangan(BuildContext context) async {
    final pengendali = TextEditingController(text: baris.keterangan ?? '');
    final hasil = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Keterangan — ${baris.namaSiswa}'),
        content: TextField(
          controller: pengendali,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Mis. sakit demam, izin acara keluarga',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, pengendali.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (hasil != null) {
      baris.keterangan = hasil.isEmpty ? null : hasil;
      onBerubah();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baris.namaSiswa,
                        style: tema.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        [
                          if (baris.nisn != null) 'NISN ${baris.nisn}',
                          if (baris.diisiOleh != null)
                            'Diisi ${baris.diisiOleh}',
                        ].join(' · '),
                        style: tema.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (dapatDiisi)
                  IconButton(
                    icon: Icon(
                      baris.keterangan == null
                          ? Icons.note_add_outlined
                          : Icons.note,
                      size: 20,
                    ),
                    tooltip: 'Keterangan',
                    onPressed: () => _ubahKeterangan(context),
                  ),
              ],
            ),
            if (baris.keterangan != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Text(
                  'Ket: ${baris.keterangan}',
                  style: tema.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final status in kStatusPresensi) ...[
                  Expanded(
                    child: _TombolStatus(
                      label: _singkatan[status]!,
                      nama: kLabelStatus[status]!,
                      warna: _warnaStatus[status]!,
                      terpilih: baris.status == status,
                      aktif: dapatDiisi,
                      onTap: () {
                        baris.status =
                            baris.status == status ? null : status;
                        onBerubah();
                      },
                    ),
                  ),
                  if (status != kStatusPresensi.last)
                    const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TombolStatus extends StatelessWidget {
  const _TombolStatus({
    required this.label,
    required this.nama,
    required this.warna,
    required this.terpilih,
    required this.aktif,
    required this.onTap,
  });

  final String label;
  final String nama;
  final Color warna;
  final bool terpilih;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: nama,
      child: Material(
        color: terpilih ? warna : warna.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: aktif ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: terpilih ? Colors.white : warna,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
