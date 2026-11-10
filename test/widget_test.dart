// Pengujian dasar sementara: kerangka aplikasi contoh bawaan
// `flutter create` (penghitung) sudah diganti aplikasi MySchool,
// jadi pengujian widget lamanya tidak berlaku lagi. Pengujian
// terhadap model JSON ditambahkan bersama pengembangan fitur.

import 'package:flutter_test/flutter_test.dart';
import 'package:myschool_mobile/model/pengguna.dart';

void main() {
  test('Pengguna.fromJson membaca profil dan PTK', () {
    final pengguna = Pengguna.fromJson({
      'id': 1,
      'nama': 'Bu Ani',
      'email': 'ani@contoh.sch.id',
      'peran': ['Guru'],
      'ptk': {
        'id': 7,
        'nama_ptk': 'Ani, S.Pd.',
        'nip': '123456',
        'jabatan': 'Guru Kelas',
        'sekolah_id': 2,
        'nama_sekolah': 'SDN 01 Totorejo',
      },
    });

    expect(pengguna.nama, 'Bu Ani');
    expect(pengguna.peran, ['Guru']);
    expect(pengguna.ptk?.namaSekolah, 'SDN 01 Totorejo');
    expect(pengguna.inisial, 'BA');
  });
}
