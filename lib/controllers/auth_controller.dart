import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ──
  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // ── Check existing session ──
  Future<bool> checkSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _fetchProfile(session.user.id);
        _isLoading = false;
        notifyListeners();
        return _currentUser != null;
      }
    } catch (e) {
      debugPrint('Session check error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Login ──
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        await _fetchProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login gagal. Periksa email dan password Anda.';
      }
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Register ──
  Future<bool> register(String nama, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user != null) {
        // Insert profile into profiles table
        await _supabase.from('profiles').insert({
          'id': response.user!.id,
          'email': email.trim(),
          'nama': nama.trim(),
          'role': 'user',
        });

        await _fetchProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Registrasi gagal. Coba lagi.';
      }
    } on AuthException catch (e) {
      _errorMessage = _mapAuthError(e.message);
    } on PostgrestException catch (e) {
      _errorMessage = 'Database error: ${e.message}';
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ── Logout ──
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ── Update profile name ──
  Future<bool> updateName(String nama) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabase
          .from('profiles')
          .update({'nama': nama.trim()})
          .eq('id', _currentUser!.id);

      _currentUser = UserProfile(
        id: _currentUser!.id,
        email: _currentUser!.email,
        nama: nama.trim(),
        role: _currentUser!.role,
        createdAt: _currentUser!.createdAt,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate nama: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Fetch profile from Supabase ──
  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('Fetch profile error: $e');
      _currentUser = null;
    }
  }

  // ── Map auth error messages to Indonesian ──
  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah.';
    } else if (message.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi.';
    } else if (message.contains('User already registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    } else if (message.contains('Password should be')) {
      return 'Password minimal 6 karakter.';
    } else if (message.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    return message;
  }

  // ── Clear error ──
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
