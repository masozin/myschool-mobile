/// Model pengguna dari GET /api/saya dan POST /api/login.
class PtkRingkas {
  const PtkRingkas({
    required this.id,
    required this.namaPtk,
    this.nip,
    this.jabatan,
    this.sekolahId,
    this.namaSekolah,
  });

  factory PtkRingkas.fromJson(Map<String, dynamic> json) => PtkRingkas(
        id: json['id'] as int,
        namaPtk: json['nama_ptk'] as String? ?? '-',
        nip: json['nip'] as String?,
        jabatan: json['jabatan'] as String?,
        sekolahId: json['sekolah_id'] as int?,
        namaSekolah: json['nama_sekolah'] as String?,
      );

  final int id;
  final String namaPtk;
  final String? nip;
  final String? jabatan;
  final int? sekolahId;
  final String? namaSekolah;
}

class Pengguna {
  const Pengguna({
    required this.id,
    required this.nama,
    required this.email,
    required this.peran,
    this.ptk,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) => Pengguna(
        id: json['id'] as int,
        nama: json['nama'] as String? ?? '-',
        email: json['email'] as String? ?? '-',
        peran: (json['peran'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        ptk: json['ptk'] == null
            ? null
            : PtkRingkas.fromJson(json['ptk'] as Map<String, dynamic>),
      );

  final int id;
  final String nama;
  final String email;
  final List<String> peran;
  final PtkRingkas? ptk;

  /// Inisial untuk avatar (maksimal dua kata pertama).
  String get inisial {
    final kata = nama.trim().split(RegExp(r'\s+'));
    if (kata.isEmpty || kata.first.isEmpty) return '?';
    if (kata.length == 1) return kata.first.substring(0, 1).toUpperCase();
    return (kata[0].substring(0, 1) + kata[1].substring(0, 1)).toUpperCase();
  }
}
