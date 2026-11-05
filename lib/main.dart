import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/repositories/guru_auth_repository.dart';
import 'data/repositories/guru_auth_repository_api.dart';
import 'features/guru/auth/guru_splash_page.dart';
import 'features/guru/presensi/buat_presensi.dart';
import 'shared/widgets/epkl_widgets.dart';
import 'features/guru/notifikasi/notifikasi_route.dart';

// Repository autentikasi Guru digunakan bersama oleh halaman aplikasi.
final guruAuthRepository = GuruAuthRepositoryApi();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal bahasa Indonesia.
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final GuruAuthRepository? repository;

  const MyApp({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-PKL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: EpklColors.biru),
        useMaterial3: true,
      ),

      // Aplikasi dimulai dari Splash Screen Guru.
      home: GuruSplashPage(repository: repository ?? guruAuthRepository),

      onGenerateRoute: (settings) {
        // Rute Notifikasi Guru
        final routeNotifikasi = ruteNotifikasi(settings);
        if (routeNotifikasi != null) {
          return routeNotifikasi;
        }

        // Rute Buat Presensi
        if (settings.name == '/guru/presensi') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const BuatPresensiPage(),
          );
        }

        // Halaman yang belum tersedia
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => Scaffold(
            appBar: EpklGradientAppBar(judul: '${settings.name}'),
            body: Center(
              child: Text('Halaman ${settings.name} belum tersedia.'),
            ),
          ),
        );
      },
    );
  }
}
