import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chopper/chopper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'services/film_service.dart';
import 'controllers/film_controller.dart';
import 'controllers/auth_controller.dart';
import 'views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Load .env ──
  await dotenv.load(fileName: '.env');

  // ── Initialize Supabase ──
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // ── Setup Chopper Client ──
  final chopperClient = ChopperClient(
    baseUrl: Uri.parse('https://68ff8dfbe02b16d1753e765d.mockapi.io'),
    services: [FilmService.create()],
    converter: const JsonConverter(),
    interceptors: [HttpLoggingInterceptor()],
  );

  final filmService = chopperClient.getService<FilmService>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => FilmController(filmService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashView(),
    );
  }
}
