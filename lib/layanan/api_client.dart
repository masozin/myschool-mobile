import 'dart:convert';

import 'package:http/http.dart' as http;

/// Kesalahan dari server/API, membawa pesan yang layak tampil.
class ApiGagal implements Exception {
  ApiGagal(this.pesan, {this.kodeStatus});

  final String pesan;
  final int? kodeStatus;

  @override
  String toString() => pesan;
}

/// Klien HTTP tipis ke API MySchool (/api/...).
/// Token & alamat server dikelola oleh pemanggil (layanan Sesi).
class ApiClient {
  ApiClient({required this.alamatServer, this.token, this.onTidakSah});

  /// Alamat dasar TANPA garis miring akhir, mis. https://myschool.ozinsq.my.id
  final String alamatServer;
  final String? token;

  /// Dipanggil bila server menjawab 401 (token tidak sah/kedaluwarsa).
  final void Function()? onTidakSah;

  Uri _uri(String path, Map<String, String>? params) {
    final dasar = alamatServer.endsWith('/')
        ? alamatServer.substring(0, alamatServer.length - 1)
        : alamatServer;
    return Uri.parse('$dasar/api$path').replace(queryParameters: params);
  }

  Map<String, String> _headers() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _urai(http.Response respons) {
    Map<String, dynamic> data = {};
    try {
      final hasil = jsonDecode(utf8.decode(respons.bodyBytes));
      if (hasil is Map<String, dynamic>) data = hasil;
    } catch (_) {
      // Badan bukan JSON — perlakukan sebagai kesalahan umum di bawah.
    }

    if (respons.statusCode >= 200 && respons.statusCode < 300) {
      return data;
    }

    if (respons.statusCode == 401) {
      onTidakSah?.call();
    }

    final pesan = data['message'] as String? ??
        'Server menjawab ${respons.statusCode}. Coba lagi sebentar.';
    throw ApiGagal(pesan, kodeStatus: respons.statusCode);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? params,
  }) async {
    final respons = await http
        .get(_uri(path, params), headers: _headers())
        .timeout(const Duration(seconds: 30));
    return _urai(respons);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final respons = await http
        .post(_uri(path, null), headers: _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));
    return _urai(respons);
  }
}
