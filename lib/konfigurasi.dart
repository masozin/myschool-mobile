/// Konfigurasi bawaan aplikasi.
///
/// Alamat server dapat diganti dari layar login (mis. untuk
/// pengujian ke server lokal lewat Wi-Fi: http://192.168.1.10:8000)
/// dan tersimpan di perangkat; nilai di sini hanya awalan.
const String kAlamatServerBawaan = 'https://myschool.ozinsq.my.id';

/// Nama-nama bulan & hari Bahasa Indonesia untuk tampilan tanggal.
const List<String> kNamaBulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const List<String> kNamaHari = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

/// "Senin, 10 November 2026" — DateTime.weekday: 1=Senin .. 7=Minggu.
String formatTanggalPanjang(DateTime t) =>
    '${kNamaHari[t.weekday - 1]}, ${t.day} ${kNamaBulan[t.month - 1]} ${t.year}';

/// "2026-11-10" untuk parameter API.
String formatTanggalApi(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-'
    '${t.month.toString().padLeft(2, '0')}-'
    '${t.day.toString().padLeft(2, '0')}';

/// Ubah "2026-11-10" / "2026-11-10T00:00:00.000000Z" menjadi
/// "10 November 2026"; kembalikan apa adanya bila tak dikenal.
String formatTanggalDariApi(Object? nilai) {
  if (nilai == null) return '-';
  final teks = nilai.toString();
  final cocok = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(teks);
  if (cocok == null) return teks;
  final bulan = int.parse(cocok.group(2)!);
  final hari = int.parse(cocok.group(3)!);
  return '$hari ${kNamaBulan[bulan - 1]} ${cocok.group(1)}';
}
