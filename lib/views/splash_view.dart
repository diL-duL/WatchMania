import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'login_view.dart';
import 'film_list_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textCtrl.forward();
    });
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final hasSession = await context.read<AuthController>().checkSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => hasSession ? const FilmListView() : const LoginView(),
        transitionsBuilder: (_, animation, a, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppTheme.purpleGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 32, spreadRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.movie_filter_rounded, size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    Text(
                      'FILMKU',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Kelola Koleksi Film Anda', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
