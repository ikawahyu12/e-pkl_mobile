import 'package:flutter/material.dart';

import '../../../data/repositories/guru_auth_repository.dart';
import 'guru_forgot_password_page.dart';
import 'guru_register_page.dart';
import '../profil/ganti_password_page.dart';
import '../../../shared/widgets/epkl_colors.dart';
import '../main/main_page.dart';

const _latarLogin = Color(0xFFF2F7FD);
const _fieldBorder = Color(0xFFCBD5E1);
const _fieldText = Color(0xFF334155);
const _errorBackground = Color(0xFFE8B4BA);

class GuruLoginPage extends StatefulWidget {
  final GuruAuthRepository repository;

  const GuruLoginPage({super.key, required this.repository});

  @override
  State<GuruLoginPage> createState() => _GuruLoginPageState();
}

class _GuruLoginPageState extends State<GuruLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final session = await widget.repository.masuk(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );
      if (!session.isValidGuruSession) {
        throw const GuruAuthException(
          'Sesi tidak valid atau akun ini bukan akun Guru.',
        );
      }
      if (!mounted) return;
      final navigator = Navigator.of(context);
      if (session.wajibGantiPassword) {
        await navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => GantiPasswordPage(
              repository: widget.repository,
              wajibGanti: true,
              onPasswordChanged: () => navigator.pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => GuruMainPage(repository: widget.repository),
                ),
                (_) => false,
              ),
            ),
          ),
        );
      } else {
        await navigator.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => GuruMainPage(repository: widget.repository),
          ),
        );
      }
    } on GuruAuthException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validasiIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username wajib diisi';
    }
    return null;
  }

  String? _validasiPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _latarLogin,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final headerHeight = constraints.maxHeight * (343 / 832);
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: _LoginHeader(
                      errorMessage: _errorMessage,
                      onDismissError: () =>
                          setState(() => _errorMessage = null),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                    constraints: const BoxConstraints(maxWidth: 460),
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: EpklColors.biruSoft),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7999BA).withValues(alpha: .08),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Silakan masuk dengan akun Guru.',
                            style: TextStyle(
                              color: _fieldText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _LoginFieldLabel('Username'),
                          const SizedBox(height: 7),
                          TextFormField(
                            key: const ValueKey('guru-identifier'),
                            controller: _identifierController,
                            enabled: !_loading,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            enableSuggestions: false,
                            autofillHints: const [AutofillHints.username],
                            validator: _validasiIdentifier,
                            style: const TextStyle(
                              color: _fieldText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _dekorasiInput(
                              hint: 'Masukkan username',
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(height: 13),
                          const _LoginFieldLabel('Password'),
                          const SizedBox(height: 7),
                          TextFormField(
                            key: const ValueKey('guru-password'),
                            controller: _passwordController,
                            enabled: !_loading,
                            obscureText: !_passwordVisible,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: _validasiPassword,
                            onFieldSubmitted: (_) => _masuk(),
                            style: const TextStyle(
                              color: _fieldText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _dekorasiInput(
                              hint: '••••••••••••',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                key: const ValueKey(
                                  'toggle-password-visibility',
                                ),
                                tooltip: _passwordVisible
                                    ? 'Sembunyikan password'
                                    : 'Tampilkan password',
                                onPressed: _loading
                                    ? null
                                    : () => setState(
                                        () => _passwordVisible =
                                            !_passwordVisible,
                                      ),
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: _fieldText,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              key: const ValueKey('guru-forgot-password-link'),
                              onPressed: _loading
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              GuruForgotPasswordPage(
                                                repository: widget.repository,
                                              ),
                                        ),
                                      );
                                    },
                              child: const Text('Lupa Password?'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 45,
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: EpklColors.gradienUtama,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: EpklColors.biru.withValues(
                                        alpha: .2,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  key: const ValueKey('guru-login-submit'),
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _loading ? null : _masuk,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          right: -14,
                                          top: -25,
                                          child: Container(
                                            width: 86,
                                            height: 86,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: .12,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: _loading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Masuk',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_rounded,
                                                      color: Colors.white,
                                                      size: 17,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            key: const ValueKey('guru-register-link'),
                            onPressed: _loading
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => GuruRegisterPage(
                                        repository: widget.repository,
                                      ),
                                    ),
                                  ),
                            child: const Text('Belum punya akun Guru? Daftar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _dekorasiInput({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _fieldText, fontSize: 13),
      prefixIcon: Icon(icon, color: _fieldText, size: 20),
      prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      suffixIcon: suffixIcon,
      suffixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      filled: true,
      fillColor: _latarLogin,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _fieldBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: EpklColors.biru, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: EpklColors.merah),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: EpklColors.merah, width: 1.4),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onDismissError;

  const _LoginHeader({
    required this.errorMessage,
    required this.onDismissError,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF124FC4),
                        EpklColors.biru,
                        Color(0xFF39A9E8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                CustomPaint(painter: _LoginWavePainter()),
              ],
            ),
          ),
        ),
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 142,
              height: 74,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .72),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B3C91).withValues(alpha: .2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo_epkl.png',
                width: 112,
                height: 49,
                fit: BoxFit.contain,
                semanticLabel: 'Logo E-PKL',
              ),
            ),
          ),
        ),
        Positioned(
          left: 33,
          right: 22,
          top: 201,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Masuk ke aplikasi pencatatan jurnal & kehadiran PKL Guru Pembimbing.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .92),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        if (errorMessage != null)
          Positioned(
            left: 31,
            right: 31,
            bottom: -2,
            child: Container(
              constraints: const BoxConstraints(minHeight: 45),
              padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
              decoration: BoxDecoration(
                color: _errorBackground,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFD92727),
                    size: 23,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFD92727),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup pesan',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDismissError,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Color(0xFFD92727),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _LoginWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .46, size.height)
      ..cubicTo(
        size.width * .66,
        size.height * .72,
        size.width * .8,
        size.height * .82,
        size.width,
        size.height * .52,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: .08));
  }

  @override
  bool shouldRepaint(covariant _LoginWavePainter oldDelegate) => false;
}

class _LoginFieldLabel extends StatelessWidget {
  final String text;

  const _LoginFieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0C2340),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
