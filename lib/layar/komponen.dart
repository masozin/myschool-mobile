import 'package:flutter/material.dart';

import '../model/jadwal.dart';

/// Kartu putih modern: sudut membulat besar, bayangan sangat
/// lembut, tanpa garis tepi keras.
class KartuModern extends StatelessWidget {
  const KartuModern({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isi = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return isi;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: isi,
    );
  }
}

/// Judul bagian dengan ikon kecil di depannya.
class JudulBagian extends StatelessWidget {
  const JudulBagian({super.key, required this.teks, this.ikon});

  final String teks;
  final IconData? ikon;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      children: [
        if (ikon != null) ...[
          Icon(ikon, size: 19, color: tema.colorScheme.primary),
          const SizedBox(width: 8),
        ],
        Text(
          teks,
          style: tema.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Satu baris linimasa jadwal: rel waktu di kiri (titik + garis),
/// kartu isi di kanan. Dipakai di Beranda & layar Jadwal.
class BlokJadwalBaris extends StatelessWidget {
  const BlokJadwalBaris({super.key, required this.blok, this.terakhir = false});

  final BlokJadwal blok;
  final bool terakhir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = switch (blok.jenis) {
      'istirahat' => Colors.blueGrey,
      'kegiatan' => Colors.orange.shade700,
      _ => tema.colorScheme.primary,
    };
    final berlangsung = blok.sedangBerlangsung;
    final lewat = blok.sudahLewat && !berlangsung;

    return Opacity(
      opacity: lewat ? 0.55 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  blok.mulai,
                  style: tema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: berlangsung ? warna : null,
                  ),
                ),
                Text(
                  blok.selesai,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: berlangsung ? warna : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: warna, width: 2.5),
                ),
              ),
              if (!terakhir)
                Container(
                  width: 2,
                  height: 44,
                  color: tema.colorScheme.outlineVariant,
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: berlangsung
                    ? tema.colorScheme.primaryContainer
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          blok.label.isEmpty ? '—' : blok.label,
                          style: tema.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (berlangsung)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: warna,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: const Text(
                            'SEKARANG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (blok.sub.isNotEmpty)
                    Text(
                      blok.sub,
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
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

/// Daftar blok menjadi linimasa; tampilkan pesan kosong bila tak ada.
class LinimasaJadwal extends StatelessWidget {
  const LinimasaJadwal({
    super.key,
    required this.daftar,
    required this.teksKosong,
  });

  final List<BlokJadwal> daftar;
  final String teksKosong;

  @override
  Widget build(BuildContext context) {
    if (daftar.isEmpty) {
      return PesanKosong(ikon: Icons.event_busy_outlined, teks: teksKosong);
    }
    return Column(
      children: [
        for (var i = 0; i < daftar.length; i++)
          BlokJadwalBaris(blok: daftar[i], terakhir: i == daftar.length - 1),
      ],
    );
  }
}

class PesanKosong extends StatelessWidget {
  const PesanKosong({super.key, required this.ikon, required this.teks});

  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          Icon(ikon, size: 42, color: tema.colorScheme.outline),
          const SizedBox(height: 10),
          Text(
            teks,
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class TampilMuat extends StatelessWidget {
  const TampilMuat({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class TampilGalat extends StatelessWidget {
  const TampilGalat({super.key, required this.pesan, required this.onUlang});

  final String pesan;
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 44),
            const SizedBox(height: 12),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: onUlang,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pesan ramah bila server belum menyediakan fitur jadwal (404).
String pesanJadwalDariGalat(Object galat) {
  final teks = galat.toString();
  if (teks.contains('404')) {
    return 'Fitur jadwal belum tersedia di server ini. '
        'Server perlu diperbarui dulu oleh pengelola.';
  }
  return teks;
}
