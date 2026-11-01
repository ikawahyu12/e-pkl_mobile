import 'package:flutter/material.dart';

import 'epkl_colors.dart';

/// Tile ringkasan statistik (mis. "12 Siswa Bimbingan") dengan tautan
/// "Lihat detail" + panah di bawahnya.
class EpklStatTile extends StatelessWidget {
  final IconData icon;
  final Color warnaIkon;
  final Color latarIkon;

  /// Angka/nilai utama, mis. "12" atau "85%".
  final String nilai;
  final String label;
  final String teksAksi;
  final VoidCallback? onTap;

  const EpklStatTile({
    super.key,
    required this.icon,
    required this.nilai,
    required this.label,
    this.warnaIkon = EpklColors.biru,
    this.latarIkon = EpklColors.biruSoft,
    this.teksAksi = 'Lihat detail',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EpklColors.latarTile,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: EpklColors.borderTile),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: latarIkon,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: warnaIkon, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      nilai,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EpklColors.teks,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: EpklColors.teksSekunder,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      teksAksi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: EpklColors.biru,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward,
                    color: EpklColors.biru,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}