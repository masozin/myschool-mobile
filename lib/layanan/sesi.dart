import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../konfigurasi.dart';
import '../model/pengguna.dart';
import 'api_client.dart';

/// Keadaan sesi aplikasi: token Sanctum, alamat server, dan
/// profil pengguna. Disimpan aman di perangkat agar guru tidak
/// perlu masuk berulang kali.
class Sesi extends ChangeNotifier {
  static const _kunciToken = 'token_api';
  static const _kunciServer = 'alamat_server';

  final _penyimpanan = const FlutterSecureStorage();

  Pengguna? pengguna;
  String? _token;
  String alamatServer = kAlamatServerBawaan;

  /// True selama pemulihan sesi awal berjalan (layar pemuat).
  bool memeriksa = true;

  bool get sudahMasuk => pengguna != null;

  ApiClient get api => ApiClient(
        alamatServer: alamatServer,
        token: _token,
        onTidakSah: _tokenDitolak,
      );

  /// Pulihkan sesi tersimpan saat aplikasi dibuka.
  Future<void> pulihkan() async {
    try {
      alamatServer =
          await _penyimpanan.read(key: _kunciServer) ?? kAlamatServerBawaan;
      _token = await _penyimpanan.read(key: _kunciToken);

      if (_token != null) {
        final data = await api.getJson('/saya');
        pengguna = Pengguna.fromJson(data['pengguna'] as Map<String, dynamic>);
      }
    } catch (_) {
      _token = null;
      pengguna = null;
    } finally {
      memeriksa = false;
      notifyListeners();
    }
  }

  /// Masuk dengan email + kata sandi akun web.
  Future<void> masuk({
    required String email,
    required String kataSandi,
    required String alamat,
  }) async {
    alamatServer = alamat.trim().replaceAll(RegExp(r'/+$'), '');
    final klien = ApiClient(alamatServer: alamatServer);
    final data = await klien.postJson('/login', {
      'email': email.trim(),
      'password': kataSandi,
      'nama_perangkat': 'Aplikasi MySchool (Android)',
    });

    _token = data['token'] as String;
    pengguna = Pengguna.fromJson(data['pengguna'] as Map<String, dynamic>);

    await _penyimpanan.write(key: _kunciToken, value: _token);
    await _penyimpanan.write(key: _kunciServer, value: alamatServer);
    notifyListeners();
  }

  /// Keluar: cabut token di server (bila sempat) lalu bersihkan perangkat.
  Future<void> keluar() async {
    try {
      if (_token != null) await api.postJson('/logout', {});
    } catch (_) {
      // Abaikan — token tetap dibersihkan dari perangkat.
    }
    await _bersihkan();
  }

  void _tokenDitolak() {
    if (pengguna == null && _token == null) return;
    _bersihkan();
  }

  Future<void> _bersihkan() async {
    _token = null;
    pengguna = null;
    await _penyimpanan.delete(key: _kunciToken);
    notifyListeners();
  }
}
