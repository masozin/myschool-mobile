import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layanan/sesi.dart';
import 'presensi_rombel_screen.dart';
import 'siswa_daftar_screen.dart';

/// Beranda setelah masuk: sapaan pengguna + dua menu utama.
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  Future<void> _keluar(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari aplikasi?'),
        content: const Text(
            'Anda perlu masuk lagi dengan email dan kata sandi untuk memakai aplikasi ini.'),
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
      appBar: AppBar(
        title: const Text('MySchool'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => _keluar(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: tema.colorScheme.primaryContainer,
                    child: Text(
                      pengguna.inisial,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: tema.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pengguna.nama,
                          style: tema.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (pengguna.ptk?.namaSekolah != null)
                          Text(pengguna.ptk!.namaSekolah!),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final peran in pengguna.peran)
                              Chip(
                                label: Text(peran),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _MenuKartu(
            ikon: Icons.fact_check_outlined,
            judul: 'Presensi',
            keterangan:
                'Isi dan periksa kehadiran siswa rombel Anda per tanggal.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PresensiRombelScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _MenuKartu(
            ikon: Icons.people_outline,
            judul: 'Data Siswa',
            keterangan: 'Lihat daftar dan biodata siswa di sekolah Anda.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SiswaDaftarScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuKartu extends StatelessWidget {
  const _MenuKartu({
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tema.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(ikon,
                    size: 28, color: tema.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: tema.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(keterangan),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
