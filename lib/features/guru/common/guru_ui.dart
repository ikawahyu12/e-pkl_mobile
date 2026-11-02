import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/siswa_bimbingan_model.dart';

// ---------------------------------------------------------------------------
// Warna (diambil dari frame Figma)
// ---------------------------------------------------------------------------
const Color kBiru = Color(0xFF1677FF);
const Color kBiruMuda = Color(0xFF6EC1FF);
const Color kBiruLembut = Color(0xFFE6F1FF);
const Color kTeks = Color(0xFF111827);
const Color kTeksSekunder = Color(0xFF6B7280);
const Color kBorder = Color(0xFFE5E7EB);
const Color kLatarAbu = Color(0xFFF5F7FB);
const Color kLatarField = Color(0xFFF1F5F9);

// ---------------------------------------------------------------------------
// Responsif
// ---------------------------------------------------------------------------

/// Padding horizontal halaman: lebih rapat di layar kecil, lega di tablet.
double hPadding(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < 360) return 14;
  if (w < 600) return 20;
  return 24;
}

/// Menahan konten agar tidak melebar di tablet / Chrome, dan menaruhnya
/// di tengah. Di HP lebar konten tetap penuh.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 640});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Komponen umum
// ---------------------------------------------------------------------------

void tampilkanSnack(BuildContext context, String pesan, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class KartuPutih extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const KartuPutih({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AvatarInisial extends StatelessWidget {
  final String inisial;
  final double radius;

  const AvatarInisial({super.key, required this.inisial, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: kBiruLembut,
      child: Text(
        inisial,
        style: TextStyle(
          color: kBiru,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}

class StatusKehadiranChip extends StatelessWidget {
  final StatusKehadiran status;

  const StatusKehadiranChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      StatusKehadiran.hadir => (
        const Color(0xFFD9F7E5),
        const Color(0xFF15803D),
      ),
      StatusKehadiran.izin => (
        const Color(0xFFFFEDC2),
        const Color(0xFFB45309),
      ),
      StatusKehadiran.alpha => (
        const Color(0xFFFEE2E2),
        const Color(0xFFDC2626),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Pill predikat (A, B+, ...). Warna mengikuti rata-rata nilai.
class PredikatChip extends StatelessWidget {
  final String predikat;
  final double rata;

  const PredikatChip({super.key, required this.predikat, required this.rata});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = rata >= 80
        ? (const Color(0xFFD9F7E5), const Color(0xFF15803D))
        : rata >= 65
        ? (const Color(0xFFFFEDC2), const Color(0xFFB45309))
        : (const Color(0xFFFEE2E2), const Color(0xFFDC2626));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        predikat,
        style: TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Header biru bergradasi (halaman formulir & hasil penilaian).
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GradientAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: kToolbarHeight + 8,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [kBiru, kBiruMuda],
          ),
        ),
      ),
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 32),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final aktif = onPressed != null && !loading;
    return Opacity(
      opacity: onPressed == null && !loading ? 0.5 : 1,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [kBiru, kBiruMuda],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: aktif ? onPressed : null,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu ringkas siswa (avatar inisial, nama, NIS • kelas, instansi).
/// Dipakai di formulir dan hasil penilaian.
class RingkasanSiswaCard extends StatelessWidget {
  final SiswaBimbingan siswa;

  const RingkasanSiswaCard({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    return KartuPutih(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInisial(inisial: siswa.inisial, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: kTeks,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIS: ${siswa.nis} • ${siswa.kelas}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: kTeksSekunder,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: kBorder),
          ),
          Row(
            children: [
              const Icon(Icons.business_outlined, size: 16, color: kBiru),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  siswa.instansi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: kTeks,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu rata-rata nilai + predikat. [rata] null -> tampil "–".
class RataRataCard extends StatelessWidget {
  final double? rata;
  final String? predikat;

  const RataRataCard({super.key, required this.rata, required this.predikat});

  @override
  Widget build(BuildContext context) {
    return KartuPutih(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RATA-RATA NILAI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kTeksSekunder,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rata == null ? '–' : rata!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: kBiru,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          if (rata != null && predikat != null)
            PredikatChip(predikat: predikat!, rata: rata!),
        ],
      ),
    );
  }
}

/// Pesan untuk kondisi kosong / error, dengan tombol aksi opsional.
class StatePesan extends StatelessWidget {
  final IconData icon;
  final String pesan;
  final String? aksiLabel;
  final VoidCallback? onAksi;

  const StatePesan({
    super.key,
    required this.icon,
    required this.pesan,
    this.aksiLabel,
    this.onAksi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: kTeksSekunder),
            const SizedBox(height: 12),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTeksSekunder, fontSize: 14),
            ),
            if (aksiLabel != null && onAksi != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAksi, child: Text(aksiLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
