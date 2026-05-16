import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'register_view.dart';
import 'film_list_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthController>().login(_emailCtrl.text, _passwordCtrl.text);
    if (mounted && success) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FilmListView()));
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
                      // Logo
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleGradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: 2)],
                        ),
                        child: const Icon(Icons.movie_filter_rounded, size: 38, color: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      Text('FILMKU', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.textWhite, fontWeight: FontWeight.w800, letterSpacing: 3)),
                      const SizedBox(height: 4),
                      Text('Masuk ke akun Anda', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 36),

                      // Form Card
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
                              // Error
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
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                style: const TextStyle(color: AppTheme.textWhite),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: '••••••••',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textDim),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                                  if (v.length < 6) return 'Minimal 6 karakter';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              Consumer<AuthController>(
                                builder: (context2, auth, child) => SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : _handleLogin,
                                    child: auth.isLoading
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                        : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                          const Text('Belum punya akun? ', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                          GestureDetector(
                            onTap: () {
                              context.read<AuthController>().clearError();
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterView()));
                            },
                            child: const Text('Daftar', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
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
