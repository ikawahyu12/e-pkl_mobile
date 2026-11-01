import 'package:flutter/material.dart';

import 'features/guru/home/guru_home_page.dart';
import 'shared/widgets/epkl_widgets.dart';

/// Preview lokal beranda guru. Jalankan dengan:
/// flutter run -t lib/guru_home_preview.dart
/// Aman dihapus kapan saja; tidak dipakai aplikasi utama.
void main() => runApp(const _Preview());

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: EpklColors.biru),
      ),
      onGenerateRoute: (s) => MaterialPageRoute(
        settings: s,
        builder: (ctx) => s.name == '/'
            ? GuruHomePage(
                onPindahTab: (i) => ScaffoldMessenger.of(ctx)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text('Pindah ke tab index $i'),
                    behavior: SnackBarBehavior.floating,
                  )),
              )
            : Scaffold(
                appBar: EpklGradientAppBar(judul: '${s.name}'),
                body: Center(child: Text('Halaman ${s.name} (placeholder)')),
              ),
      ),
    );
  }
}