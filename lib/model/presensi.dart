/// Model-model presensi dari endpoint /api/presensi/*.
class SemesterRingkas {
  const SemesterRingkas({
    required this.id,
    required this.tahunPelajaran,
    required this.semester,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  factory SemesterRingkas.fromJson(Map<String, dynamic> json) =>
      SemesterRingkas(
        id: json['id'] as int,
        tahunPelajaran: json['tahun_pelajaran'] as String? ?? '-',
        semester: json['semester'] as String? ?? '-',
        tanggalMulai: json['tanggal_mulai'] as String?,
        tanggalSelesai: json['tanggal_selesai'] as String?,
      );

  final int id;
  final String tahunPelajaran;
  final String semester;
  final String? tanggalMulai;
  final String? tanggalSelesai;

  String get label => '$tahunPelajaran - $semester';

  DateTime? get mulaiDate =>
      tanggalMulai == null ? null : DateTime.tryParse(tanggalMulai!);
  DateTime? get selesaiDate =>
      tanggalSelesai == null ? null : DateTime.tryParse(tanggalSelesai!);
}

class RombelRingkas {
  const RombelRingkas({
    required this.id,
    required this.namaRombel,
    this.tingkat,
    this.namaSekolah,
    this.waliKelas,
    this.bolehIsi = false,
  });

  factory RombelRingkas.fromJson(Map<String, dynamic> json) => RombelRingkas(
        id: json['id'] as int,
        namaRombel: json['nama_rombel'] as String? ?? '-',
        tingkat: json['tingkat'] as int?,
        namaSekolah: json['nama_sekolah'] as String?,
        waliKelas: json['wali_kelas'] as String?,
        bolehIsi: json['boleh_isi'] as bool? ?? false,
      );

  final int id;
  final String namaRombel;
  final int? tingkat;
  final String? namaSekolah;
  final String? waliKelas;
  final bool bolehIsi;
}

/// Satu baris roster presensi; status & keterangan dapat diubah
/// di layar sebelum disimpan.
class BarisPresensi {
  BarisPresensi({
    required this.siswaId,
    required this.namaSiswa,
    this.nisn,
    this.jenisKelamin,
    this.status,
    this.keterangan,
    this.terisi = false,
    this.diisiOleh,
  });

  factory BarisPresensi.fromJson(Map<String, dynamic> json) => BarisPresensi(
        siswaId: json['siswa_id'] as int,
        namaSiswa: json['nama_siswa'] as String? ?? '-',
        nisn: json['nisn'] as String?,
        jenisKelamin: json['jenis_kelamin'] as String?,
        status: json['status'] as String?,
        keterangan: json['keterangan'] as String?,
        terisi: json['terisi'] as bool? ?? false,
        diisiOleh: json['diisi_oleh'] as String?,
      );

  final int siswaId;
  final String namaSiswa;
  final String? nisn;
  final String? jenisKelamin;
  final bool terisi;
  final String? diisiOleh;

  /// hadir | izin | sakit | alpa | null (belum dipilih)
  String? status;
  String? keterangan;
}

/// Empat status presensi yang sah di server.
const List<String> kStatusPresensi = ['hadir', 'izin', 'sakit', 'alpa'];

const Map<String, String> kLabelStatus = {
  'hadir': 'Hadir',
  'izin': 'Izin',
  'sakit': 'Sakit',
  'alpa': 'Alpa',
};
