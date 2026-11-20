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
        for (final item in items) Expanded(child: _TombolMenuCepat(item: item)),
      ],
    );
  }
}

class _TombolMenuCepat extends StatelessWidget {
  final EpklMenuCepatItem item;
  const _TombolMenuCepat({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ink(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1266E8), Color(0xFF55B8FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: EpklColors.biru.withValues(alpha: 0.24),
                      blurRadius: 13,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -9,
                        top: -12,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -13,
                        bottom: -19,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.13),
                              width: 6,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(item.icon, color: Colors.white, size: 25),
                      ),
                    ],
                  ),
                ),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
