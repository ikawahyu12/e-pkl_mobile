import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Wajib di-import

import 'features/guru/main/main_page.dart';
import 'shared/widgets/epkl_widgets.dart';

// 2. Ubah fungsi main menjadi async
void main() async {
  // 3. Pastikan binding terinisialisasi sebelum memanggil await
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Inisialisasi format tanggal bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-PKL',
      debugShowCheckedModeBanner:
          false, // (Opsional) Menghilangkan banner debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: EpklColors.biru),
        useMaterial3: true,
      ),
      home: const GuruMainPage(),
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (context) => Scaffold(
          appBar: EpklGradientAppBar(judul: '${settings.name}'),
          body: Center(child: Text('Halaman ${settings.name} (placeholder)')),
        ),
      ),
    );
  }
}
