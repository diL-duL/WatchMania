import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/film_model.dart';
import '../services/film_service.dart';

class FilmController extends ChangeNotifier {
  final FilmService _filmService;

  List<Film> _films = [];
  List<Film> _filteredFilms = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  FilmController(this._filmService);

  // ── Getters ──
  List<Film> get films => _searchQuery.isEmpty ? _films : _filteredFilms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // ── Search ──
  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredFilms = _films;
    } else {
      _filteredFilms = _films
          .where((film) =>
              film.judul.toLowerCase().contains(query.toLowerCase()) ||
              film.kategori.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // ── CRUD Operations ──

  /// Fetch all films from API
  Future<void> fetchFilms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _filmService.getFilms();
      if (response.isSuccessful) {
        final List<dynamic> data = response.body is String
            ? jsonDecode(response.body)
            : response.body;
        _films = data.map((json) => Film.fromJson(json)).toList();
        // Re-apply search filter if active
        if (_searchQuery.isNotEmpty) {
          setSearchQuery(_searchQuery);
        }
      } else {
        _errorMessage = 'Gagal memuat data film (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new film
  Future<bool> addFilm(Film film) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _filmService.createFilm(film.toJson());
      if (response.isSuccessful) {
        await fetchFilms(); // Refresh list
        return true;
      } else {
        _errorMessage = 'Gagal menambahkan film (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Update an existing film
  Future<bool> updateFilm(Film film) async {
    if (film.id == null) {
      _errorMessage = 'ID film tidak ditemukan';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _filmService.updateFilm(film.id!, film.toJson());
      if (response.isSuccessful) {
        await fetchFilms(); // Refresh list
        return true;
      } else {
        _errorMessage = 'Gagal mengupdate film (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Delete a film by ID
  Future<bool> deleteFilm(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _filmService.deleteFilm(id);
      if (response.isSuccessful) {
        _films.removeWhere((film) => film.id == id);
        if (_searchQuery.isNotEmpty) {
          setSearchQuery(_searchQuery);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Gagal menghapus film (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
