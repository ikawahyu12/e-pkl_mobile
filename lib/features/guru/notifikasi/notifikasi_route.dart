import 'package:flutter/material.dart';

import 'notifikasi_guru_page.dart';

/// Nama rute notifikasi. Harus sama dengan GuruTujuan.notifikasi di
/// shared/utils/guru_navigasi.dart.
const String ruteNotifikasiGuru = '/guru/notifikasi';

/// Pembuat rute untuk halaman notifikasi. Pasang di MaterialApp:
///   onGenerateRoute: ruteNotifikasi,
/// Mengembalikan null untuk rute lain, jadi tidak mengganggu rute teman.
Route<dynamic>? ruteNotifikasi(RouteSettings settings) {
  if (settings.name != ruteNotifikasiGuru) return null;
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => const NotifikasiGuruPage(),
  );
}
