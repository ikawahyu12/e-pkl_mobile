import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/guru/home/guru_home_page.dart';
import 'features/guru/presensi/presensi.dart';
import 'features/guru/profil/profil_guru_page.dart';
import 'features/guru/siswa_bimbingan/siswa_bimbingan_page.dart';
import 'features/guru/notifikasi/notifikasi_guru_page.dart';
import 'shared/widgets/epkl_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  runApp(const EPKLApp());
}

class EPKLApp extends StatelessWidget {
  const EPKLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-PKL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: EpklColors.biru),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const GuruMainPage(),
    );
  }
}

class GuruMainPage extends StatefulWidget {
  const GuruMainPage({super.key});

  @override
  State<GuruMainPage> createState() => _GuruMainPageState();
}

class _GuruMainPageState extends State<GuruMainPage> {
  int _index = 0;

  void _pindahTab(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final halaman = <Widget>[
      GuruHomePage(onPindahTab: _pindahTab),
      const SiswaBimbinganPage(),
      const PresensiPage(),
      const ProfilGuruPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: halaman),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _pindahTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: EpklColors.biru,
        unselectedItemColor: EpklColors.teksSekunder,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
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
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check_rounded),
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
