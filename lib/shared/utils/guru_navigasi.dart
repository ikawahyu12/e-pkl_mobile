import 'package:flutter/material.dart';

/// Tujuan navigasi yang bisa dicapai dari pintasan/beranda guru.
///
/// - Tujuan **tab** ([tab] != null) membuka tab di shell, jadi tidak
///   pernah membuat halaman baru.
/// - Tujuan **halaman** ([rute] != null) di-push lewat named route.
///
/// Urutan tab mengikuti desain: Beranda(0), Siswa(1), Monitoring(2), Profil(3).
/// Nama rute di bawah harus didaftarkan di `onGenerateRoute` / `routes`
/// aplikasi (tinggal samakan string-nya, atau ubah di sini).
enum GuruTujuan {
  siswaBimbingan(tab: 1),
  monitoring(tab: 2),
  profil(tab: 3),
  notifikasi(rute: '/guru/notifikasi'),
  presensi(rute: '/guru/presensi'),
  jurnal(rute: '/guru/jurnal');

  const GuruTujuan({this.tab, this.rute});

  /// Index tab pada bottom navigation, atau null jika bukan tab.
  final int? tab;

  /// Nama rute untuk halaman yang di-push, atau null jika berupa tab.
  final String? rute;

  bool get adalahTab => tab != null;
}

/// Callback untuk berpindah tab (disediakan shell/bottom navigation).
typedef GuruPindahTab = void Function(int index);

/// Callback generik yang dipakai halaman untuk meminta navigasi.
typedef GuruNavigasiCallback = void Function(GuruTujuan tujuan);

/// Helper navigasi supaya tidak terjadi halaman dobel.
abstract final class GuruNavigasi {
  /// Membuka [tujuan].
  ///
  /// - Tab: memanggil [onPindahTab] (tidak ada push sama sekali).
  /// - Halaman: `pushNamed`, kecuali halaman dengan rute yang sama sudah
  ///   berada di paling atas (mis. tombol ditekan dua kali cepat).
  static Future<void> buka(
    BuildContext context,
    GuruTujuan tujuan, {
    GuruPindahTab? onPindahTab,
    Object? arguments,
  }) async {
    final tab = tujuan.tab;
    if (tab != null) {
      assert(
        onPindahTab != null,
        'Tujuan ${tujuan.name} adalah tab, sediakan onPindahTab dari shell.',
      );
      onPindahTab?.call(tab);
      return;
    }

    final navigator = Navigator.of(context);
    final rute = tujuan.rute!;
    if (_sudahDiAtas(navigator, rute)) return;
    await navigator.pushNamed(rute, arguments: arguments);
  }

  /// True jika halaman teratas saat ini sudah memakai nama rute [rute].
  static bool _sudahDiAtas(NavigatorState navigator, String rute) {
    var diAtas = false;
    // Predicate langsung true -> tidak ada halaman yang di-pop, hanya mengintip.
    navigator.popUntil((route) {
      diAtas = route.settings.name == rute;
      return true;
    });
    return diAtas;
  }
}