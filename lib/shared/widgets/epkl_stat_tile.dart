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
      color: Colors.white,
      elevation: 1,
      shadowColor: warnaIkon.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: warnaIkon.withValues(alpha: 0.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -35,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: warnaIkon.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          InkWell(
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
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: latarIkon,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: warnaIkon, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          nilai,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: EpklColors.teks,
                            fontSize: 25,
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: latarIkon.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            teksAksi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: EpklColors.biru,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: EpklColors.biru,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
