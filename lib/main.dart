import 'package:flutter/material.dart';

import 'features/guru/common/guru_ui.dart';
import 'features/guru/notifikasi/notifikasi_guru_page.dart';
import 'features/guru/profil/profil_guru_page.dart';
import 'features/guru/siswa_bimbingan/siswa_bimbingan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-PKL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kBiru),
        useMaterial3: true,
      ),
      home: const GuruMainPage(),
    );
  }
}

/// Kerangka halaman guru dengan bottom navigation.
/// TODO: pindahkan ke features/guru/main/ dan ganti placeholder
/// Beranda & Monitoring dengan halaman buatan anggota lain.
class GuruMainPage extends StatefulWidget {
  const GuruMainPage({super.key});

  @override
  State<GuruMainPage> createState() => _GuruMainPageState();
}

class _GuruMainPageState extends State<GuruMainPage> {
  int _index = 1; // mulai dari tab Siswa

  @override
  Widget build(BuildContext context) {
    final halaman = <Widget>[
      _PlaceholderBeranda(
        onBukaNotifikasi: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotifikasiGuruPage()),
        ),
      ),
      const SiswaBimbinganPage(),
      const _Placeholder(judul: 'Monitoring'),
      const ProfilGuruPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: halaman),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kBiru,
        unselectedItemColor: kTeksSekunder,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups_rounded),
            label: 'Siswa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Monitoring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderBeranda extends StatelessWidget {
  final VoidCallback onBukaNotifikasi;

  const _PlaceholderBeranda({required this.onBukaNotifikasi});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Beranda\n(belum dikerjakan)',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTeksSekunder),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onBukaNotifikasi,
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('Buka Notifikasi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String judul;

  const _Placeholder({required this.judul});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          '$judul\n(belum dikerjakan)',
          textAlign: TextAlign.center,
          style: const TextStyle(color: kTeksSekunder),
        ),
      ),
    );
  }
}
