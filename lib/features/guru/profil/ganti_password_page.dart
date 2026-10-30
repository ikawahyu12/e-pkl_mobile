import 'package:flutter/material.dart';

import '../../../data/repositories/profil_guru_repository.dart';

class GantiPasswordPage extends StatefulWidget {
  final ProfilGuruRepository repository;

  const GantiPasswordPage({super.key, required this.repository});

  @override
  State<GantiPasswordPage> createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _lamaC = TextEditingController();
  final _baruC = TextEditingController();
  final _konfirmasiC = TextEditingController();

  bool _lihatLama = false;
  bool _lihatBaru = false;
  bool _lihatKonfirmasi = false;
  bool _menyimpan = false;

  @override
  void dispose() {
    _lamaC.dispose();
    _baruC.dispose();
    _konfirmasiC.dispose();
    super.dispose();
  }

  String? _validasiLama(String? v) =>
      (v == null || v.isEmpty) ? 'Kata sandi lama wajib diisi' : null;

  String? _validasiBaru(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi baru wajib diisi';
    if (v.length < 8) return 'Minimal 8 karakter';
    if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'[0-9]').hasMatch(v)) {
      return 'Gunakan kombinasi huruf dan angka';
    }
    if (v == _lamaC.text) return 'Tidak boleh sama dengan kata sandi lama';
    return null;
  }

  String? _validasiKonfirmasi(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
    if (v != _baruC.text) return 'Konfirmasi tidak cocok';
    return null;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _menyimpan = true);
    try {
      await widget.repository.gantiPassword(
        passwordLama: _lamaC.text,
        passwordBaru: _baruC.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final pesan = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(pesan.isEmpty ? 'Gagal mengubah kata sandi' : pesan),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required bool lihat,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    TextInputAction aksi = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !lihat,
      textInputAction: aksi,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(lihat ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keamanan Akun')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Ganti kata sandi',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _field(
                controller: _lamaC,
                label: 'Kata sandi lama',
                lihat: _lihatLama,
                onToggle: () => setState(() => _lihatLama = !_lihatLama),
                validator: _validasiLama,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _baruC,
                label: 'Kata sandi baru',
                lihat: _lihatBaru,
                onToggle: () => setState(() => _lihatBaru = !_lihatBaru),
                validator: _validasiBaru,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _konfirmasiC,
                label: 'Konfirmasi kata sandi baru',
                lihat: _lihatKonfirmasi,
                onToggle: () =>
                    setState(() => _lihatKonfirmasi = !_lihatKonfirmasi),
                validator: _validasiKonfirmasi,
                aksi: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _menyimpan ? null : _simpan,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ubah kata sandi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}