/// Model info hari ini dari GET /api/info-hari-ini:
/// kegiatan Kalender Pendidikan + PTK yang berulang tahun.

class KaldikHariIni {
  const KaldikHariIni({
    required this.kegiatan,
    required this.jenis,
    required this.isLibur,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  factory KaldikHariIni.fromJson(Map<String, dynamic> json) => KaldikHariIni(
    kegiatan: json['kegiatan'] as String? ?? '-',
    jenis: json['jenis'] as String? ?? '',
    isLibur: json['is_libur'] as bool? ?? false,
    tanggalMulai: json['tanggal_mulai'] as String?,
    tanggalSelesai: json['tanggal_selesai'] as String?,
  );

  final String kegiatan;
  final String jenis;
  final bool isLibur;
  final String? tanggalMulai;
  final String? tanggalSelesai;
}

class UltahHariIni {
  const UltahHariIni({
    required this.id,
    required this.nama,
    required this.jabatan,
    this.usia,
    required this.saya,
    this.ucapanJudul,
    this.ucapanDoa,
  });

  factory UltahHariIni.fromJson(Map<String, dynamic> json) => UltahHariIni(
    id: json['id'] as int? ?? 0,
    nama: json['nama'] as String? ?? '-',
    jabatan: json['jabatan'] as String? ?? '',
    usia: json['usia'] as int?,
    saya: json['saya'] as bool? ?? false,
    ucapanJudul: json['ucapan_judul'] as String?,
    ucapanDoa: json['ucapan_doa'] as String?,
  );

  final int id;
  final String nama;
  final String jabatan;
  final int? usia;

  /// True bila yang berulang tahun adalah pengguna yang masuk.
  final bool saya;

  /// Ucapan resmi + doa — hanya terisi bila [saya] true.
  final String? ucapanJudul;
  final String? ucapanDoa;

  String get inisial {
    final kata = nama.trim().split(RegExp(r'\s+'));
    if (kata.isEmpty || kata.first.isEmpty) return '?';
    if (kata.length == 1) return kata.first.substring(0, 1).toUpperCase();
    return (kata[0].substring(0, 1) + kata[1].substring(0, 1)).toUpperCase();
  }
}

class InfoHariIni {
  const InfoHariIni({required this.kaldik, required this.ulangTahun});

  factory InfoHariIni.fromJson(Map<String, dynamic> json) => InfoHariIni(
    kaldik: (json['kaldik'] as List<dynamic>? ?? [])
        .map((e) => KaldikHariIni.fromJson(e as Map<String, dynamic>))
        .toList(),
    ulangTahun: (json['ulang_tahun'] as List<dynamic>? ?? [])
        .map((e) => UltahHariIni.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final List<KaldikHariIni> kaldik;
  final List<UltahHariIni> ulangTahun;

  /// Data ulang tahun pengguna sendiri, bila hari ini ia berulang tahun.
  UltahHariIni? get ultahSaya {
    for (final u in ulangTahun) {
      if (u.saya) return u;
    }
    return null;
  }
}
