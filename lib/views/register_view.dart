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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.register(_namaCtrl.text, _emailCtrl.text, _passwordCtrl.text);

    if (mounted && success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FilmListView()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Header ──
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.25), blurRadius: 20, spreadRadius: 2),
                          ],
                        ),
                        child: const Icon(Icons.person_add_rounded, size: 34, color: AppTheme.backgroundBlack),
                      ),
                      const SizedBox(height: 16),
                      Text('Buat Akun', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primaryGold, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text('Daftar untuk mulai menjelajah film', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 32),

                      // ── Form Card ──
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppTheme.dividerColor),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Error
                              Consumer<AuthController>(
                                builder: (context, auth, _) {
                                  if (auth.errorMessage != null) {
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
                                          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(child: Text(auth.errorMessage!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13))),
                                        ],
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                              // Nama
                              TextFormField(
                                controller: _namaCtrl,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: const InputDecoration(labelText: 'Nama Lengkap', hintText: 'John Doe', prefixIcon: Icon(Icons.person_outline_rounded)),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                              ),
                              const SizedBox(height: 16),

                              // Email
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
                              const SizedBox(height: 16),

                              // Password
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textDarkGrey),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                                  if (v.length < 6) return 'Minimal 6 karakter';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password
                              TextFormField(
                                controller: _confirmCtrl,
                                obscureText: _obscureConfirm,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: InputDecoration(
                                  labelText: 'Konfirmasi Password',
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textDarkGrey),
                                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                                  if (v != _passwordCtrl.text) return 'Password tidak cocok';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),

                              // Register Button
                              Consumer<AuthController>(
                                builder: (context, auth, _) {
                                  return SizedBox(
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading ? null : _handleRegister,
                                      child: auth.isLoading
                                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.backgroundBlack))
                                          : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Login link ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? ', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                          GestureDetector(
                            onTap: () {
                              context.read<AuthController>().clearError();
                              Navigator.pop(context);
                            },
                            child: const Text('Masuk', style: TextStyle(color: AppTheme.primaryGold, fontSize: 14, fontWeight: FontWeight.w700)),
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
