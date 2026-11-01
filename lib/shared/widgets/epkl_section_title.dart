import 'package:flutter/material.dart';

import 'epkl_colors.dart';

/// Judul seksi (mis. "Menu Cepat") dengan aksi opsional di kanan.
class EpklSectionTitle extends StatelessWidget {
  final String judul;
  final String? teksAksi;
  final VoidCallback? onAksi;

  const EpklSectionTitle(this.judul, {super.key, this.teksAksi, this.onAksi});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              judul,
              style: const TextStyle(
                color: EpklColors.teks,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          if (teksAksi != null)
            InkWell(
              onTap: onAksi,
              child: Text(
                teksAksi!,
                style: const TextStyle(
                  color: EpklColors.biru,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}