import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/guru_auth_session.dart';
import '../../../data/repositories/guru_auth_repository.dart';
import '../main/main_page.dart';
import '../profil/ganti_password_page.dart';
import 'guru_login_page.dart';

const _splashCorner = Color(0xFFF0F9FF);

class GuruSplashPage extends StatefulWidget {
  final GuruAuthRepository repository;

  const GuruSplashPage({super.key, required this.repository});

  @override
  State<GuruSplashPage> createState() => _GuruSplashPageState();
}

class _GuruSplashPageState extends State<GuruSplashPage> {
  @override
  void initState() {
    super.initState();
    _periksaSesi();
  }

  Future<void> _periksaSesi() async {
    GuruAuthSession? session;
    try {
      session = await widget.repository.pulihkanSesi();
    } on GuruAuthException {
      // An unavailable or unverifiable session must never enter the dashboard.
    }

    await Future<void>.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final Widget tujuan;
    if (session?.isValidGuruSession != true) {
      tujuan = GuruLoginPage(repository: widget.repository);
    } else if (session!.wajibGantiPassword) {
      tujuan = GantiPasswordPage(
        repository: widget.repository,
        wajibGanti: true,
        onPasswordChanged: () => navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => GuruMainPage(repository: widget.repository),
          ),
          (_) => false,
        ),
      );
    } else {
      tujuan = GuruMainPage(repository: widget.repository);
    }

    await navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => tujuan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const Positioned(
              left: -60,
              top: -40,
              child: _SplashCircle(size: 240),
            ),
            const Positioned(
              right: -30,
              bottom: -60,
              child: _SplashCircle(size: 220),
            ),
            SafeArea(
              child: Align(
                alignment: const Alignment(0, 0.05),
                child: Image.asset(
                  'assets/images/epkl_logo_splash.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashCircle extends StatelessWidget {
  final double size;

  const _SplashCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: _splashCorner, shape: BoxShape.circle),
      ),
    );
  }
}
