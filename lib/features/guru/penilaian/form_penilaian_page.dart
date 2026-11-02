import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/penilaian_model.dart';
import '../../../data/models/siswa_bimbingan_model.dart';
import '../../../data/repositories/penilaian_repository.dart';
import '../common/guru_ui.dart';
import 'hasil_penilaian_page.dart';

/// Formulir penilaian siswa.
/// Bila [penilaianAwal] diisi, formulir terisi otomatis (mode ubah nilai).
/// Setelah berhasil disimpan, halaman diganti ke [HasilPenilaianPage] dan
/// halaman pemanggil menerima [Penilaian] hasil simpan lewat Navigator.
class FormPenilaianPage extends StatefulWidget {
  final SiswaBimbingan siswa;
  final Penilaian? penilaianAwal;
  final PenilaianRepository? repository;

  const FormPenilaianPage({
    super.key,
    required this.siswa,
    this.penilaianAwal,
    this.repository,
  });

  @override
  State<FormPenilaianPage> createState() => _FormPenilaianPageState();
}

class _FormPenilaianPageState extends State<FormPenilaianPage> {
  late final PenilaianRepository _repo =
      widget.repository ?? PenilaianRepositoryMock();

  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _ctrl;
  late final TextEditingController _catatan;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    final awal = widget.penilaianAwal;
    _ctrl = List.generate(
      Penilaian.namaAspek.length,
      (i) => TextEditingController(
        text: awal != null && i < awal.nilai.length ? '${awal.nilai[i]}' : '',
      ),
    );
    _catatan = TextEditingController(text: awal?.catatan ?? '');
  }

  @override
  void dispose() {
    for (final c in _ctrl) {
      c.dispose();
    }
    _catatan.dispose();
    super.dispose();
  }

  /// Daftar nilai bila SEMUA aspek valid (0–100), selain itu null.
  List<int>? _nilaiValid() {
    final hasil = <int>[];
    for (final c in _ctrl) {
      final v = int.tryParse(c.text.trim());
      if (!Penilaian.nilaiValid(v)) return null;
      hasil.add(v!);
    }
    return hasil;
  }

  String? _validasiNilai(String? v) {
    final teks = (v ?? '').trim();
    if (teks.isEmpty) return 'Wajib';
    if (!Penilaian.nilaiValid(int.tryParse(teks))) return '0–100';
    return null;
  }

  Future<void> _simpan() async {
    FocusScope.of(context).unfocus();
    final nilai = _nilaiValid();
    if (!(_formKey.currentState?.validate() ?? false) || nilai == null) {
      tampilkanSnack(context, 'Periksa kembali nilai yang diisi', error: true);
      return;
    }

    setState(() => _menyimpan = true);
    try {
      final tersimpan = await _repo.simpanPenilaian(
        Penilaian(
          siswaId: widget.siswa.id,
          nilai: nilai,
          catatan: _catatan.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement<void, Penilaian>(
        MaterialPageRoute<void>(
          builder: (_) => HasilPenilaianPage(
            siswaId: widget.siswa.id,
            siswa: widget.siswa,
            penilaian: tersimpan,
            baruDisimpan: true,
            penilaianRepository: _repo,
          ),
        ),
        result: tersimpan,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      tampilkanSnack(context, 'Gagal menyimpan nilai. Coba lagi.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = hPadding(context);
    final nilai = _nilaiValid();
    final rata = nilai == null ? null : Penilaian.hitungRata(nilai);

    return Scaffold(
      backgroundColor: kLatarAbu,
      appBar: const GradientAppBar(title: 'Formulir Penilaian'),
      body: SafeArea(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RingkasanSiswaCard(siswa: widget.siswa),
                  const SizedBox(height: 16),
                  KartuPutih(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aspek Penilaian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTeks,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Isi nilai 0–100 untuk setiap aspek',
                          style: TextStyle(fontSize: 12, color: kTeksSekunder),
                        ),
                        const SizedBox(height: 14),
                        for (var i = 0; i < Penilaian.namaAspek.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == Penilaian.namaAspek.length - 1
                                  ? 0
                                  : 10,
                            ),
                            child: _BarisAspek(
                              label: Penilaian.namaAspek[i],
                              controller: _ctrl[i],
                              validator: _validasiNilai,
                              onChanged: (_) => setState(() {}),
                              enabled: !_menyimpan,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RataRataCard(
                    rata: rata,
                    predikat: rata == null
                        ? null
                        : Penilaian.hitungPredikat(rata),
                  ),
                  const SizedBox(height: 16),
                  KartuPutih(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catatan Penilaian',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTeks,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _catatan,
                          enabled: !_menyimpan,
                          minLines: 3,
                          maxLines: 5,
                          maxLength: 300,
                          style: const TextStyle(fontSize: 13.5, height: 1.4),
                          decoration: InputDecoration(
                            hintText: 'Tulis catatan penilaian (opsional)',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                            ),
                            filled: true,
                            fillColor: kLatarField,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: kBiru),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Simpan Nilai',
                    loading: _menyimpan,
                    onPressed: _simpan,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarisAspek extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _BarisAspek({
    required this.label,
    required this.controller,
    required this.validator,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 11),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: kTeks,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 72,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kTeks,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: kLatarField,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              errorStyle: const TextStyle(fontSize: 11, height: 1.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kBiru),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
