import 'package:flutter/material.dart';

import '../home/guru_home_page.dart';
import '../monitoring/monitoring_page.dart';
import '../profil/profil_guru_page.dart';

import '../../../data/repositories/guru_auth_repository.dart';
import '../auth/guru_login_page.dart';

class GuruMainPage extends StatefulWidget {
  final GuruAuthRepository repository;

  const GuruMainPage({super.key, required this.repository});

  @override
  State<GuruMainPage> createState() => _GuruMainPageState();
}

class _GuruMainPageState extends State<GuruMainPage> {
  int _currentIndex = 0;

  void _pilihTab(int index) {
    assert(index >= 0 && index < 4);
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _halamanAktif() {
    switch (_currentIndex) {
      case 0:
        return GuruHomePage(onPindahTab: _pilihTab);
      case 1:
        return const _HalamanBelumTersedia(judul: 'Siswa');
      case 2:
        return const MonitoringPage();
      case 3:
        return ProfilGuruPage(onLogout: _keluar);
      default:
        return GuruHomePage(onPindahTab: _pilihTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _halamanAktif(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF48A2E6),
        unselectedItemColor: Colors.grey,
        onTap: _pilihTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Siswa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Future<void> _keluar() async {
    GuruAuthException? logoutError;
    try {
      await widget.repository.keluar();
    } on GuruAuthException catch (error) {
      logoutError = error;
    } catch (_) {
      logoutError = const GuruAuthException(
        'Sesi lokal tidak dapat dibersihkan sepenuhnya.',
      );
    }

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => GuruLoginPage(repository: widget.repository),
      ),
      (route) => false,
    );

    if (logoutError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '${logoutError!.message} Anda sudah keluar dari aplikasi.',
            ),
          ),
        );
      });
    }
  }
}

class _HalamanBelumTersedia extends StatelessWidget {
  const _HalamanBelumTersedia({required this.judul});

  final String judul;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(judul)),
      body: Center(child: Text('Halaman $judul belum tersedia')),
    );
  }
}