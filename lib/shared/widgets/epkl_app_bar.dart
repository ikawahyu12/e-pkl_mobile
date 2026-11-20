import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'epkl_colors.dart';

/// Logo E-PKL yang digunakan pada header aplikasi.
class EpklLogo extends StatelessWidget {
  final double ukuran;
  const EpklLogo({super.key, this.ukuran = 30});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_epkl.png',
      width: ukuran * 2.3,
      height: ukuran,
      fit: BoxFit.contain,
      semanticLabel: 'Logo E-PKL',
    );
  }
}

class _EpklAppBarBackdrop extends StatelessWidget {
  const _EpklAppBarBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF124FC4), EpklColors.biru, Color(0xFF39A9E8)],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          right: -34,
          top: -76,
          child: Container(
            width: 172,
            height: 172,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 72,
          bottom: -96,
          child: Container(
            width: 142,
            height: 142,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

/// App bar putih untuk halaman tab dengan judul di kiri
/// (Siswa Bimbingan, Monitoring, Profil Akun).
class EpklTitleAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double tinggiToolbar = 64;

  final String judul;
  final List<Widget>? actions;

  const EpklTitleAppBar({super.key, required this.judul, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(tinggiToolbar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: tinggiToolbar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.white,
      elevation: 1,
      scrolledUnderElevation: 0,
      shadowColor: EpklColors.biru.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
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
  static const double tinggiToolbar = 68;

  final String judul;
  final List<Widget>? actions;
  final bool tampilkanTombolKembali;

  /// Default: `Navigator.maybePop`.
  final VoidCallback? onKembali;

  const EpklGradientAppBar({
    super.key,
    required this.judul,
    this.actions,
    this.tampilkanTombolKembali = true,
    this.onKembali,
  });

  @override
  Size get preferredSize => const Size.fromHeight(tinggiToolbar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: tinggiToolbar,
      automaticallyImplyLeading: false,
      leadingWidth: tampilkanTombolKembali ? 68 : 16,
      elevation: 2,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: EpklColors.biru.withValues(alpha: 0.22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleSpacing: 8,
      flexibleSpace: const _EpklAppBarBackdrop(),
      leading: tampilkanTombolKembali
          ? Padding(
              padding: const EdgeInsets.only(left: 14),
              child: IconButton(
                tooltip: 'Kembali',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 21),
                onPressed: onKembali ?? () => Navigator.of(context).maybePop(),
              ),
            )
          : null,
      title: Text(
        judul,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 19,
          letterSpacing: 0.1,
        ),
      ),
      actions: actions,
    );
  }
}

/// App bar beranda: logo di kiri, lonceng notifikasi dan avatar di kanan.
class EpklHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double tinggiToolbar = 68;

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
  Size get preferredSize => const Size.fromHeight(tinggiToolbar);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: tinggiToolbar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 2,
      scrolledUnderElevation: 0,
      shadowColor: EpklColors.biru.withValues(alpha: 0.22),
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleSpacing: 16,
      flexibleSpace: const _EpklAppBarBackdrop(),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F3B87).withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const EpklLogo(ukuran: 28),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          child: IconButton(
            tooltip: 'Notifikasi',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
            ),
            onPressed: onNotifikasi,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 23),
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
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 12),
          child: Tooltip(
            message: 'Profil',
            child: InkResponse(
              onTap: onProfil,
              radius: 22,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: const CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    color: EpklColors.biru,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
