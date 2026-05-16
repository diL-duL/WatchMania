import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'film_list_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _namaCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthController>().register(_namaCtrl.text, _emailCtrl.text, _passwordCtrl.text);
    if (mounted && success) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const FilmListView()), (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.person_add_rounded, size: 34, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Text('Buat Akun', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.textWhite, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Daftar untuk mulai menjelajah film', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 28),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.divider),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8))],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Consumer<AuthController>(
                                builder: (context2, auth, child) {
                                  if (auth.errorMessage == null) return const SizedBox.shrink();
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(auth.errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13))),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              TextFormField(
                                controller: _namaCtrl,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: const InputDecoration(labelText: 'Nama Lengkap', hintText: 'John Doe', prefixIcon: Icon(Icons.person_outline_rounded)),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: const InputDecoration(labelText: 'Email', hintText: 'nama@email.com', prefixIcon: Icon(Icons.email_outlined)),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                                  if (!v.contains('@')) return 'Email tidak valid';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePass,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: InputDecoration(
                                  labelText: 'Password', hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textDim),
                                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                                  if (v.length < 6) return 'Minimal 6 karakter';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: InputDecoration(
                                  labelText: 'Konfirmasi Password', hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textDim),
                                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                                  if (v != _passwordCtrl.text) return 'Password tidak cocok';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Consumer<AuthController>(
                                builder: (context2, auth, child) => SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _handleRegister,
                                    child: auth.isLoading
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                        : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? ', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                          GestureDetector(
                            onTap: () {
                              context.read<AuthController>().clearError();
                              Navigator.pop(context);
                            },
                            child: const Text('Masuk', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
