import 'package:flutter/material.dart';

import 'epkl_colors.dart';

/// Tile baris berisi ikon, judul, keterangan, dan chevron
/// (mis. "Informasi Terbaru"). Bisa dipakai ulang untuk daftar menu/info.
class EpklInfoTile extends StatelessWidget {
  final IconData icon;
  final Color warnaIkon;
  final Color latarIkon;
  final String judul;
  final String? keterangan;
  final VoidCallback? onTap;

  const EpklInfoTile({
    super.key,
    required this.icon,
    required this.judul,
    this.keterangan,
    this.warnaIkon = EpklColors.biru,
    this.latarIkon = EpklColors.biruSoft,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: EpklColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: latarIkon,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: warnaIkon, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        color: EpklColors.teks,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    if (keterangan != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        keterangan!,
                        style: const TextStyle(
                          color: EpklColors.teksSekunder,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: EpklColors.teksSekunder),
            ],
          ),
        ),
      ),
    );
  }
}