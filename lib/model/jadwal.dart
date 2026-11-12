/// Model jadwal pelajaran dari API /jadwal/...
///
/// Blok adalah satuan tampilan terkecil: satu pelajaran, satu
/// istirahat, atau satu kegiatan tetap, lengkap dengan rentang
/// waktunya ("07.00"–"07.35").

class BlokJadwal {
  const BlokJadwal({
    required this.mulai,
    required this.selesai,
    required this.jenis,
    required this.label,
    required this.sub,
  });

  factory BlokJadwal.fromJson(Map<String, dynamic> json) => BlokJadwal(
    mulai: json['mulai'] as String? ?? '',
    selesai: json['selesai'] as String? ?? '',
    jenis: json['jenis'] as String? ?? 'pelajaran',
    label: json['label'] as String? ?? '',
    sub: json['sub'] as String? ?? '',
  );

  final String mulai;
  final String selesai;

  /// 'pelajaran' | 'istirahat' | 'kegiatan'
  final String jenis;

  /// Judul utama: nama mapel (jadwal kelas) / nama rombel (jadwal guru).
  final String label;

  /// Keterangan kedua: nama guru / nama mapel.
  final String sub;

  static int _keMenit(String waktu) {
    final bagian = waktu.replaceAll(':', '.').split('.');
    if (bagian.length != 2) return -1;
    final jam = int.tryParse(bagian[0]) ?? 0;
    final menit = int.tryParse(bagian[1]) ?? 0;
    return jam * 60 + menit;
  }

  /// True bila blok ini sedang berlangsung menurut jam perangkat.
  bool get sedangBerlangsung {
    final sekarang = DateTime.now();
    final kini = sekarang.hour * 60 + sekarang.minute;
    final m = _keMenit(mulai);
    final s = _keMenit(selesai);
    return m >= 0 && m <= kini && kini < s;
  }

  bool get sudahLewat {
    final sekarang = DateTime.now();
    final kini = sekarang.hour * 60 + sekarang.minute;
    final s = _keMenit(selesai);
    return s >= 0 && kini >= s;
  }
}

class HariJadwal {
  const HariJadwal({
    required this.nomor,
    required this.nama,
    required this.blok,
  });

  factory HariJadwal.fromJson(Map<String, dynamic> json) => HariJadwal(
    nomor: json['nomor'] as int? ?? 0,
    nama: json['nama'] as String? ?? '',
    blok: (json['blok'] as List<dynamic>? ?? [])
        .map((e) => BlokJadwal.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int nomor;
  final String nama;
  final List<BlokJadwal> blok;
}

class KelasSekarang {
  const KelasSekarang({
    required this.rombel,
    required this.label,
    required this.sub,
    required this.mulai,
    required this.selesai,
  });

  factory KelasSekarang.fromJson(Map<String, dynamic> json) => KelasSekarang(
    rombel: json['rombel'] as String? ?? '',
    label: json['label'] as String? ?? '',
    sub: json['sub'] as String? ?? '',
    mulai: json['mulai'] as String? ?? '',
    selesai: json['selesai'] as String? ?? '',
  );

  final String rombel;
  final String label;
  final String sub;
  final String mulai;
  final String selesai;
}

/// Jawaban GET /jadwal/hari-ini.
class JadwalHariIni {
  const JadwalHariIni({
    required this.namaHari,
    required this.tanggal,
    required this.jam,
    this.sedang,
    this.berikutnya,
    required this.daftar,
    this.kelasSekarang,
  });

  factory JadwalHariIni.fromJson(Map<String, dynamic> json) {
    final hari = json['hari'] as Map<String, dynamic>? ?? {};
    return JadwalHariIni(
      namaHari: hari['nama'] as String? ?? '',
      tanggal: hari['tanggal'] as String? ?? '',
      jam: hari['jam'] as String? ?? '',
      sedang: json['sedang'] == null
          ? null
          : BlokJadwal.fromJson(json['sedang'] as Map<String, dynamic>),
      berikutnya: json['berikutnya'] == null
          ? null
          : BlokJadwal.fromJson(json['berikutnya'] as Map<String, dynamic>),
      daftar: (json['daftar'] as List<dynamic>? ?? [])
          .map((e) => BlokJadwal.fromJson(e as Map<String, dynamic>))
          .toList(),
      kelasSekarang: json['kelas_sekarang'] == null
          ? null
          : KelasSekarang.fromJson(
              json['kelas_sekarang'] as Map<String, dynamic>,
            ),
    );
  }

  final String namaHari;
  final String tanggal;
  final String jam;
  final BlokJadwal? sedang;
  final BlokJadwal? berikutnya;
  final List<BlokJadwal> daftar;
  final KelasSekarang? kelasSekarang;
}

/// Ringkasan rombel dari GET /jadwal/rombel.
class RombelJadwal {
  const RombelJadwal({
    required this.id,
    required this.namaRombel,
    this.tingkat,
    this.waliKelas,
  });

  factory RombelJadwal.fromJson(Map<String, dynamic> json) => RombelJadwal(
    id: json['id'] as int? ?? 0,
    namaRombel: json['nama_rombel'] as String? ?? '-',
    tingkat: json['tingkat'] as int?,
    waliKelas: json['wali_kelas'] as String?,
  );

  final int id;
  final String namaRombel;
  final int? tingkat;
  final String? waliKelas;
}
