import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/repositories/guru_auth_repository.dart';
import 'data/repositories/guru_auth_repository_api.dart';
import 'features/guru/auth/guru_reset_password_page.dart';
import 'features/guru/auth/guru_splash_page.dart';
import 'features/guru/informasi_jurnal/informasi_jurnal_page.dart';
import 'features/guru/notifikasi/notifikasi_route.dart';
import 'features/guru/presensi/buat_presensi.dart';
import 'shared/widgets/epkl_widgets.dart';

// Repository autentikasi Guru digunakan bersama oleh halaman aplikasi.
final guruAuthRepository = GuruAuthRepositoryApi();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal bahasa Indonesia.
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final GuruAuthRepository? repository;

  const MyApp({super.key, this.repository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GuruAuthRepository _repository;
  late final AppLinks _appLinks;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _lastHandledLink;

  @override
  void initState() {
    super.initState();

    _repository = widget.repository ?? guruAuthRepository;
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (Object error) =>
          debugPrint('Guru password reset link listener failed: $error'),
    );
    unawaited(_handleInitialLink());
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _handleIncomingLink(uri);
    } catch (error) {
      debugPrint('Guru password reset initial link failed: $error');
    }
  }

  void _handleIncomingLink(Uri uri) {
    if (uri.scheme != 'epkl' ||
        uri.host != 'guru' ||
        uri.path != '/reset-password' ||
        _lastHandledLink == uri) {
      return;
    }
    _lastHandledLink = uri;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => GuruResetPasswordPage(
            repository: _repository,
            email: uri.queryParameters['email'] ?? '',
            token: uri.queryParameters['token'] ?? '',
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'E-PKL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: EpklColors.biru,
          brightness: Brightness.light,
        ),
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          displayMedium: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          displaySmall: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: EpklColors.teks,
          ),
          titleSmall: TextStyle(
            fontWeight: FontWeight.w600,
            color: EpklColors.teks,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w600,
            color: EpklColors.teks,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w500,
            color: EpklColors.teks,
          ),
          bodySmall: TextStyle(
            fontWeight: FontWeight.w500,
            color: EpklColors.teksSekunder,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
          labelMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: EpklColors.teks,
          ),
          labelSmall: TextStyle(
            fontWeight: FontWeight.w600,
            color: EpklColors.teks,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FB),
          foregroundColor: EpklColors.teks,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: EpklColors.teks,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF8FAFC),
          labelStyle: TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: EpklColors.biru, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: EpklColors.biru,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: EpklColors.biru,
            textStyle: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

      // Aplikasi dimulai dari Splash Screen Guru.
      home: GuruSplashPage(repository: _repository),

      onGenerateRoute: (settings) {
        // Rute Notifikasi Guru.
        final routeNotifikasi = ruteNotifikasi(settings);
        if (routeNotifikasi != null) {
          return routeNotifikasi;
        }

        // Rute Buat Presensi.
        if (settings.name == '/guru/presensi') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const BuatPresensiPage(),
          );
        }

        if (settings.name == '/guru/jurnal') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const InformasiJurnalPage(),
          );
        }

        // Halaman yang belum tersedia.
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
