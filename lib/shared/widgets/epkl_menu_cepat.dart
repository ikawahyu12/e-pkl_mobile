import 'package:flutter/material.dart';

import 'epkl_colors.dart';

/// Data satu tombol pada [EpklMenuCepat].
class EpklMenuCepatItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const EpklMenuCepatItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

/// Baris tombol menu cepat (ikon kotak membulat bergradien + label di bawah).
/// Item dibagi rata selebar baris.
class EpklMenuCepat extends StatelessWidget {
  final List<EpklMenuCepatItem> items;

  const EpklMenuCepat({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Expanded(child: _TombolMenuCepat(item: item)),
      ],
    );
  }
}

class _TombolMenuCepat extends StatelessWidget {
  final EpklMenuCepatItem item;
  const _TombolMenuCepat({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [EpklColors.biru, EpklColors.biruMuda],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: EpklColors.biru.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(item.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: EpklColors.teks,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}