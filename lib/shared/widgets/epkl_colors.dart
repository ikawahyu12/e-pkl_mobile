import 'package:flutter/material.dart';

/// Token warna bersama untuk fitur guru.
///
/// Nilainya disamakan dengan warna yang sudah dipakai di halaman Profil
/// supaya tampilan antar-halaman konsisten.
abstract final class EpklColors {
  // Brand
  static const biru = Color(0xFF1677FF);
  static const biruMuda = Color(0xFF6EC1FF);

  // Teks dan garis
  static const teks = Color(0xFF111827);
  static const teksSekunder = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);

  // Latar tile ringkasan (cyan lembut di desain beranda)
  static const latarTile = Color(0xFFE8FAFB);
  static const borderTile = Color(0xFFD3F1F4);

  // Pasangan warna ikon + latar ikon
  static const biruSoft = Color(0xFFDCEBFF);
  static const hijau = Color(0xFF16A34A);
  static const hijauSoft = Color(0xFFDCF5E3);
  static const kuning = Color(0xFFD97706);
  static const kuningSoft = Color(0xFFFFF1C2);
  static const merah = Color(0xFFE11D48);

  /// Gradien biru utama (hero card, app bar halaman dalam, tombol menu cepat).
  static const gradienUtama = LinearGradient(
    colors: [biru, biruMuda],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}