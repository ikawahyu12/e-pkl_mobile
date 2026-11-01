import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'epkl_colors.dart';

/// Wordmark "EPKL".
///
/// TODO: ganti dengan aset logo asli (Image.asset) kalau file logonya sudah
/// ditambahkan ke project.
class EpklLogo extends StatelessWidget {
  final double ukuran;
  const EpklLogo({super.key, this.ukuran = 30});

  @override
  Widget build(BuildContext context) {
    return Text(
      'EPKL',
      style: TextStyle(
        color: EpklColors.biru,
        fontSize: ukuran,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: -1,
        height: 1,
      ),
    );
  }
}

/// App bar putih untuk halaman tab dengan judul di kiri
/// (Siswa Bimbingan, Monitoring, Profil Akun).
class EpklTitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String judul;
  final List<Widget>? actions;

  const EpklTitleAppBar({super.key, required this.judul, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Text(
        judul,
        style: const TextStyle(
          color: EpklColors.teks,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),
      actions: actions,
    );
  }
}

/// App bar biru bergradien untuk halaman dalam (Presensi, Jurnal, Detail,
/// Formulir Penilaian, dst.) dengan tombol kembali di kiri.
class EpklGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String judul;
  final List<Widget>? actions;

  /// Default: `Navigator.maybePop`.
  final VoidCallback? onKembali;

  const EpklGradientAppBar({
    super.key,
    required this.judul,
    this.actions,
    this.onKembali,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleSpacing: 0,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: EpklColors.gradienUtama),
        child: SizedBox.expand(),
      ),
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.chevron_left, size: 30),
        onPressed: onKembali ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        judul,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      actions: actions,
    );
  }
}

/// App bar beranda: logo di kiri, lonceng notifikasi dan avatar di kanan.
class EpklHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Tampilkan titik merah pada lonceng.
  final bool adaNotifikasiBaru;
  final VoidCallback? onNotifikasi;
  final VoidCallback? onProfil;

  const EpklHomeAppBar({
    super.key,
    this.adaNotifikasiBaru = false,
    this.onNotifikasi,
    this.onProfil,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: false,
      titleSpacing: 16,
      title: const Align(
        alignment: Alignment.centerLeft,
        child: EpklLogo(),
      ),
      actions: [
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: onNotifikasi,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: EpklColors.biru,
                size: 26,
              ),
              if (adaNotifikasiBaru)
                Positioned(
                  right: 1,
                  top: 1,
                  child: Container(
                    key: const ValueKey('titik-notifikasi'),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: EpklColors.merah,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Tooltip(
            message: 'Profil',
            child: InkResponse(
              onTap: onProfil,
              radius: 22,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: EpklColors.biruSoft,
                child: Icon(Icons.person, color: EpklColors.biru, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}