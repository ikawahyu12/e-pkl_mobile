import 'package:flutter/material.dart';

import '../home/guru_home_page.dart';
import '../presensi/presensi.dart';
import '../profil/profil_guru_page.dart';

class GuruMainPage extends StatefulWidget {
  const GuruMainPage({super.key});

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
        return const PresensiPage();
      case 3:
        return const ProfilGuruPage();
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
