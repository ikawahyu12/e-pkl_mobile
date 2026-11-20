import 'package:flutter/material.dart';

import '../../../data/repositories/guru_auth_repository.dart';
import '../../../data/repositories/guru_auth_repository_api.dart';
import '../../../shared/widgets/epkl_widgets.dart';

/// Halaman keamanan akun: ganti kata sandi.
/// Mendukung mode opsional maupun mode wajib ganti saat login pertama kali.
class GantiPasswordPage extends StatefulWidget {
  final GuruAuthRepository? repository;
  final bool wajibGanti;
  final VoidCallback? onPasswordChanged;

  const GantiPasswordPage({
    super.key,
    this.repository,
    this.wajibGanti = false,
    this.onPasswordChanged,
  }) : assert(!wajibGanti || onPasswordChanged != null);

  @override
  State<GantiPasswordPage> createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  static const _biru = Color(0xFF2F6FED);
  static const _garis = Color(0xFFE6E9EE);
  static const _isiField = Color(0xFFF8F9FB);
  static const _merah = Color(0xFFE0245E);

  late final GuruAuthRepository _repo;
  final _formKey = GlobalKey<FormState>();
  final _lamaCtrl = TextEditingController();
  final _baruCtrl = TextEditingController();
  final _konfirmCtrl = TextEditingController();

  bool _lihatLama = false;
  bool _lihatBaru = false;
  bool _lihatKonfirm = false;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? GuruAuthRepositoryApi();
  }

  @override
  void dispose() {
    _lamaCtrl.dispose();
    _baruCtrl.dispose();
    _konfirmCtrl.dispose();
    super.dispose();
  }

  String _pesan(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _snack(String teks, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(teks),
          backgroundColor: error ? Colors.red.shade600 : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String? _validasiLama(String? v) =>
      (v == null || v.isEmpty) ? 'Kata sandi lama wajib diisi' : null;

  String? _validasiBaru(String? v) {
    if (v == null || v.isEmpty) return 'Kata sandi baru wajib diisi';
    if (v.length < 8) return 'Minimal 8 karakter';
    if (v == _lamaCtrl.text) {
      return 'Kata sandi baru harus berbeda dari yang lama';
    }
    return null;
  }

  String? _validasiKonfirmasi(String? v) {
    if (v == null || v.isEmpty) return 'Konfirmasi wajib diisi';
    if (v != _baruCtrl.text) return 'Konfirmasi tidak sama';
    return null;
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _menyimpan = true);
    try {
      await _repo.gantiPassword(
        passwordLama: _lamaCtrl.text,
        passwordBaru: _baruCtrl.text,
        passwordBaruConfirmation: _konfirmCtrl.text,
      );
      if (!mounted) return;
      _snack('Kata sandi berhasil diubah.');
      if (widget.wajibGanti) {
        widget.onPasswordChanged!();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      final pesan = _pesan(e).trim();
      _snack(
        pesan.isEmpty ? 'Gagal mengubah kata sandi' : pesan,
        error: true,
      );
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  // ---------- tampilan ----------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.wajibGanti,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: EpklGradientAppBar(
          judul: widget.wajibGanti ? 'Wajib Ganti Kata Sandi' : 'Keamanan Akun',
          tampilkanTombolKembali: !widget.wajibGanti,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (widget.wajibGanti) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.deepOrange,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Kata sandi sementara harus diganti sebelum menggunakan aplikasi.',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _kartuInfo(),
                const SizedBox(height: 22),
                const Text(
                  'Ganti kata sandi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lamaCtrl,
                  enabled: !_menyimpan,
                  obscureText: !_lihatLama,
                  textInputAction: TextInputAction.next,
                  decoration: _dekor(
                    'Kata sandi lama',
                    Icons.lock_outline,
                    lihat: _lihatLama,
                    onToggle: () => setState(() => _lihatLama = !_lihatLama),
                  ),
                  validator: _validasiLama,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _baruCtrl,
                  enabled: !_menyimpan,
                  obscureText: !_lihatBaru,
                  textInputAction: TextInputAction.next,
                  decoration: _dekor(
                    'Kata sandi baru',
                    Icons.lock_reset_outlined,
                    helper: 'Minimal 8 karakter',
                    lihat: _lihatBaru,
                    onToggle: () => setState(() => _lihatBaru = !_lihatBaru),
                  ),
                  validator: _validasiBaru,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _konfirmCtrl,
                  enabled: !_menyimpan,
                  obscureText: !_lihatKonfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _simpan(),
                  decoration: _dekor(
                    'Konfirmasi kata sandi baru',
                    Icons.verified_user_outlined,
                    lihat: _lihatKonfirm,
                    onToggle: () =>
                        setState(() => _lihatKonfirm = !_lihatKonfirm),
                  ),
                  validator: _validasiKonfirmasi,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _menyimpan ? null : _simpan,
                    style: FilledButton.styleFrom(
                      backgroundColor: _biru,
                      disabledBackgroundColor: _biru.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _menyimpan
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Ubah kata sandi',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kartu biru muda berisi keterangan singkat, selaras dengan kartu di Profil Akun.
  Widget _kartuInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: _biru, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Setelah kata sandi diubah, perangkat lain yang masih login '
              'akan keluar otomatis. Perangkat ini tetap masuk.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF26446E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dekor(
    String label,
    IconData ikon, {
    String? helper,
    required bool lihat,
    required VoidCallback onToggle,
  }) {
    OutlineInputBorder batas(Color warna, [double lebar = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: warna, width: lebar),
        );

    return InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: Icon(ikon, size: 20),
      suffixIcon: IconButton(
        icon: Icon(
          lihat ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
        onPressed: onToggle,
      ),
      filled: true,
      fillColor: _isiField,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: batas(_garis),
      enabledBorder: batas(_garis),
      disabledBorder: batas(_garis),
      focusedBorder: batas(_biru, 1.6),
      errorBorder: batas(_merah),
      focusedErrorBorder: batas(_merah, 1.6),
    );
  }
}