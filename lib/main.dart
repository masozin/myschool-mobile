import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'layanan/sesi.dart';
import 'layar/beranda_screen.dart';
import 'layar/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Sesi()..pulihkan(),
      child: const AplikasiMySchool(),
    ),
  );
}

/// Akar aplikasi: gerbang sesi — layar pemuat saat sesi dipulihkan,
/// Beranda bila sudah masuk, Login bila belum.
class AplikasiMySchool extends StatelessWidget {
  const AplikasiMySchool({super.key});

  @override
  Widget build(BuildContext context) {
    final sesi = context.watch<Sesi>();

    return MaterialApp(
      title: 'MySchool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7367F0)),
        useMaterial3: true,
      ),
      home: sesi.memeriksa
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : sesi.sudahMasuk
              ? const BerandaScreen()
              : const LoginScreen(),
    );
  }
}
