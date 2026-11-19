import 'package:flutter/material.dart';

import '../home/guru_home_page.dart';
import '../monitoring/monitoring_page.dart';
import '../profil/profil_guru_page.dart';

import '../../../data/repositories/guru_auth_repository.dart';
import '../auth/guru_login_page.dart';
import '../siswa_bimbingan/siswa_bimbingan_page.dart';

class GuruMainPage extends StatefulWidget {
  final GuruAuthRepository repository;

  const GuruMainPage({super.key, required this.repository});

  @override
  State<GuruMainPage> createState() => _GuruMainPageState();
}

class _GuruMainPageState extends State<GuruMainPage> {
  static const _warnaUtama = Color(0xFF1677FF);

  int _currentIndex = 0;
  final List<Widget?> _halaman = List<Widget?>.filled(4, null);

  @override
  void initState() {
    super.initState();
    _halaman[0] = _buatHalaman(0);
  }

  void _pilihTab(int index) {
    assert(index >= 0 && index < 4);
    if (index == _currentIndex) return;

    _halaman[index] ??= _buatHalaman(index);
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buatHalaman(int index) {
    switch (index) {
      case 0:
        return GuruHomePage(onPindahTab: _pilihTab);
      case 1:
        return const SiswaBimbinganPage();
      case 2:
        return const MonitoringPage();
      case 3:
        return ProfilGuruPage(
          authRepository: widget.repository,
          onLogout: _keluar,
        );
      default:
        throw RangeError.index(index, _tabNavigasi, 'index');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          for (final halaman in _halaman) halaman ?? const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFE9EFF7)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF17365D).withValues(alpha: 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var index = 0; index < _tabNavigasi.length; index++)
                  Expanded(
                    child: _TombolNavigasi(
                      item: _tabNavigasi[index],
                      terpilih: index == _currentIndex,
                      onTap: () => _pilihTab(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
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

const _tabNavigasi = [
  _ItemNavigasi(Icons.home_rounded, Icons.home_outlined, 'Beranda'),
  _ItemNavigasi(Icons.people_rounded, Icons.people_outline_rounded, 'Siswa'),
  _ItemNavigasi(Icons.monitor_rounded, Icons.monitor_outlined, 'Monitoring'),
  _ItemNavigasi(Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
];

class _ItemNavigasi {
  final IconData ikonAktif;
  final IconData ikon;
  final String label;

  const _ItemNavigasi(this.ikonAktif, this.ikon, this.label);
}

class _TombolNavigasi extends StatelessWidget {
  final _ItemNavigasi item;
  final bool terpilih;
  final VoidCallback onTap;

  const _TombolNavigasi({
    required this.item,
    required this.terpilih,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final warna = terpilih
        ? _GuruMainPageState._warnaUtama
        : const Color(0xFF475569);

    return Semantics(
      button: true,
      selected: terpilih,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: terpilih ? 48 : 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: terpilih
                        ? const Color(0xFFEAF3FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AnimatedScale(
                    scale: terpilih ? 1 : 0.92,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: Icon(
                      terpilih ? item.ikonAktif : item.ikon,
                      size: 21,
                      color: warna,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    color: warna,
                    fontSize: 11,
                    fontWeight: terpilih ? FontWeight.w800 : FontWeight.w700,
                  ),
                  child: Text(item.label, maxLines: 1),
                ),
              ],
            ),
          ),
        ),
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
