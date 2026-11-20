import 'package:e_pkl/data/models/profil_guru_model.dart';
import 'package:e_pkl/data/repositories/profil_guru_repository.dart';
import 'package:e_pkl/features/guru/profil/edit_profil_guru_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('edit profile offers gallery and camera photo sources', (
    tester,
  ) async {
    const profil = ProfilGuru(
      nama: 'Guru Uji',
      nip: '123',
      sekolah: 'SMK',
      bimbingan: '0 siswa',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfilGuruPage(
          profil: profil,
          repository: ProfilGuruRepositoryMock(),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Ganti foto profil'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih dari galeri'), findsOneWidget);
    expect(find.text('Ambil dengan kamera'), findsOneWidget);
  });
}
