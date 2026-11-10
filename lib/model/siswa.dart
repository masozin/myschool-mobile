/// Model data siswa dari endpoint /api/siswa*.
class RombelSiswa {
  const RombelSiswa({required this.id, required this.namaRombel, this.tingkat});

  factory RombelSiswa.fromJson(Map<String, dynamic> json) => RombelSiswa(
        id: json['id'] as int,
        namaRombel: json['nama_rombel'] as String? ?? '-',
        tingkat: json['tingkat'] as int?,
      );

  final int id;
  final String namaRombel;
  final int? tingkat;
}

class SiswaRingkas {
  const SiswaRingkas({
    required this.id,
    required this.namaSiswa,
    this.nisn,
    this.nis,
    this.jenisKelamin,
    this.tempatLahir,
    this.tglLahir,
    this.rombel,
  });

  factory SiswaRingkas.fromJson(Map<String, dynamic> json) => SiswaRingkas(
        id: json['siswa_id'] as int,
        namaSiswa: json['nama_siswa'] as String? ?? '-',
        nisn: json['nisn'] as String?,
        nis: json['nis'] as String?,
        jenisKelamin: json['jenis_kelamin'] as String?,
        tempatLahir: json['tempat_lahir'] as String?,
        tglLahir: json['tgl_lahir'] as String?,
        rombel: json['rombel'] == null
            ? null
            : RombelSiswa.fromJson(json['rombel'] as Map<String, dynamic>),
      );

  final int id;
  final String namaSiswa;
  final String? nisn;
  final String? nis;
  final String? jenisKelamin;
  final String? tempatLahir;
  final String? tglLahir;
  final RombelSiswa? rombel;

  String get inisial {
    final kata = namaSiswa.trim().split(RegExp(r'\s+'));
    if (kata.isEmpty || kata.first.isEmpty) return '?';
    if (kata.length == 1) return kata.first.substring(0, 1).toUpperCase();
    return (kata[0].substring(0, 1) + kata[1].substring(0, 1)).toUpperCase();
  }
}

class SiswaDetail {
  const SiswaDetail({
    required this.ringkas,
    this.agama,
    this.alamat,
    this.disabilitas,
    this.namaAyah,
    this.namaIbu,
    this.namaWali,
    this.noHp,
    this.statusRegistrasi,
    this.tanggalDiterima,
  });

  factory SiswaDetail.fromJson(Map<String, dynamic> json) => SiswaDetail(
        ringkas: SiswaRingkas.fromJson(json),
        agama: json['agama'] as String?,
        alamat: json['alamat'] as String?,
        disabilitas: json['disabilitas'] as String?,
        namaAyah: json['nama_ayah'] as String?,
        namaIbu: json['nama_ibu'] as String?,
        namaWali: json['nama_wali'] as String?,
        noHp: json['no_hp'] as String?,
        statusRegistrasi: json['status_registrasi'] as String?,
        tanggalDiterima: json['tanggal_diterima'] as String?,
      );

  final SiswaRingkas ringkas;
  final String? agama;
  final String? alamat;
  final String? disabilitas;
  final String? namaAyah;
  final String? namaIbu;
  final String? namaWali;
  final String? noHp;
  final String? statusRegistrasi;
  final String? tanggalDiterima;
}
