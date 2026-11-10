import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/api_client.dart';
import '../layanan/sesi.dart';
import '../model/siswa.dart';
import 'siswa_detail_screen.dart';

/// Daftar siswa sekolah pengguna pada semester aktif.
/// Pencarian dan saringan rombel bekerja di perangkat dari
/// data yang sudah dimuat.
class SiswaDaftarScreen extends StatefulWidget {
  const SiswaDaftarScreen({super.key});

  @override
  State<SiswaDaftarScreen> createState() => _SiswaDaftarScreenState();
}

class _SiswaDaftarScreenState extends State<SiswaDaftarScreen> {
  List<SiswaRingkas> _semua = [];
  bool _memuat = true;
  String? _galat;
  String _cari = '';
  int? _rombelId;

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
      final data = await context.read<Sesi>().api.getJson('/siswa');
      setState(() {
        _semua = (data['siswa'] as List<dynamic>)
            .map((e) => SiswaRingkas.fromJson(e as Map<String, dynamic>))
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

  List<SiswaRingkas> get _tampil {
    final kunci = _cari.trim().toLowerCase();
    return _semua.where((s) {
      if (_rombelId != null && s.rombel?.id != _rombelId) return false;
      if (kunci.isEmpty) return true;
      return s.namaSiswa.toLowerCase().contains(kunci) ||
          (s.nisn ?? '').contains(kunci) ||
          (s.nis ?? '').contains(kunci);
    }).toList();
  }

  List<RombelSiswa> get _daftarRombel {
    final peta = <int, RombelSiswa>{};
    for (final s in _semua) {
      if (s.rombel != null) peta[s.rombel!.id] = s.rombel!;
    }
    return peta.values.toList()
      ..sort((a, b) => a.namaRombel.compareTo(b.namaRombel));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Siswa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nama, NISN, atau NIS…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _cari = v),
            ),
          ),
          if (_daftarRombel.length > 1)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: const Text('Semua rombel'),
                      selected: _rombelId == null,
                      onSelected: (_) => setState(() => _rombelId = null),
                    ),
                  ),
                  for (final r in _daftarRombel)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(r.namaRombel),
                        selected: _rombelId == r.id,
                        onSelected: (_) => setState(() => _rombelId = r.id),
                      ),
                    ),
                ],
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
                    : _tampil.isEmpty
                        ? const Center(child: Text('Tidak ada siswa cocok.'))
                        : ListView.builder(
                            itemCount: _tampil.length,
                            itemBuilder: (ctx, i) {
                              final s = _tampil[i];
                              return ListTile(
                                leading: CircleAvatar(child: Text(s.inisial)),
                                title: Text(s.namaSiswa),
                                subtitle: Text([
                                  if (s.rombel != null) s.rombel!.namaRombel,
                                  if (s.nisn != null) 'NISN ${s.nisn}',
                                ].join(' · ')),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SiswaDetailScreen(siswaId: s.id),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          if (!_memuat && _galat == null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Menampilkan ${_tampil.length} dari ${_semua.length} siswa',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
