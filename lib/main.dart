import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'layanan/sesi.dart';
import 'layar/beranda_screen.dart';
import 'layar/jadwal_screen.dart';
import 'layar/login_screen.dart';
import 'layar/presensi_rombel_screen.dart';
import 'layar/siswa_daftar_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Sesi()..pulihkan(),
      child: const AplikasiMySchool(),
    ),
  );
}

/// Akar aplikasi: gerbang sesi — layar pemuat saat sesi dipulihkan,
/// rangka utama bila sudah masuk, Login bila belum.
class AplikasiMySchool extends StatelessWidget {
  const AplikasiMySchool({super.key});

  @override
  Widget build(BuildContext context) {
    final sesi = context.watch<Sesi>();

    return MaterialApp(
      title: 'MySchool',
      debugShowCheckedModeBanner: false,
      theme: temaMySchool(),
      home: sesi.memeriksa
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : sesi.sudahMasuk
          ? const UtamaScreen()
          : const LoginScreen(),
    );
  }
}

/// Tema Material 3 modern: ungu khas MySchool, permukaan bersih,
/// sudut membulat besar, bayangan lembut.
ThemeData temaMySchool() {
  const biji = Color(0xFF7367F0);
  final skema = ColorScheme.fromSeed(seedColor: biji);
  return ThemeData(
    colorScheme: skema,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF5F5F8),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF5F5F8),
      foregroundColor: skema.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: skema.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      height: 66,
      indicatorColor: skema.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final terpilih = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: terpilih ? FontWeight.w700 : FontWeight.w500,
          color: terpilih ? skema.primary : skema.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final terpilih = states.contains(WidgetState.selected);
        return IconThemeData(
          color: terpilih ? skema.primary : skema.onSurfaceVariant,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: skema.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: skema.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: skema.primary, width: 1.6),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13.5,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: skema.outlineVariant,
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Rangka utama setelah masuk: empat tab dengan bilah navigasi
/// bawah modern — Beranda, Jadwal, Presensi, Siswa.
class UtamaScreen extends StatefulWidget {
  const UtamaScreen({super.key});

  @override
  State<UtamaScreen> createState() => _UtamaScreenState();
}

class _UtamaScreenState extends State<UtamaScreen> {
  int _tab = 0;

  void _bukaTab(int indeks) => setState(() => _tab = indeks);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          BerandaScreen(onBukaTab: _bukaTab),
          const JadwalScreen(),
          const PresensiRombelScreen(),
          const SiswaDaftarScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _bukaTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Presensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Siswa',
          ),
        ],
      ),
    );
  }
}
