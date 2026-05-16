import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/film_controller.dart';
import '../models/film_model.dart';
import '../theme/app_theme.dart';

class FilmFormView extends StatefulWidget {
  final Film? film;
  const FilmFormView({super.key, this.film});

  @override
  State<FilmFormView> createState() => _FilmFormViewState();
}

class _FilmFormViewState extends State<FilmFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulCtrl;
  late TextEditingController _ringkasanCtrl;
  late TextEditingController _posterCtrl;
  late TextEditingController _sampulCtrl;
  late TextEditingController _kategoriCtrl;
  late TextEditingController _trailerCtrl;
  late DateTime _selectedDate;
  late double _rating;
  bool _isSubmitting = false;
  int _currentStep = 0;

  bool get isEditMode => widget.film != null;

  @override
  void initState() {
    super.initState();
    final f = widget.film;
    _judulCtrl = TextEditingController(text: f?.judul ?? '');
    _ringkasanCtrl = TextEditingController(text: f?.ringkasan ?? '');
    _posterCtrl = TextEditingController(text: f?.gambarPoster ?? '');
    _sampulCtrl = TextEditingController(text: f?.gambarSampul ?? '');
    _kategoriCtrl = TextEditingController(text: f?.kategori ?? '');
    _trailerCtrl = TextEditingController(text: f?.urlTrailer ?? '');
    _selectedDate = f != null ? DateTime.fromMillisecondsSinceEpoch(f.tanggalRilis * 1000) : DateTime.now();
    _rating = f?.skorRating.toDouble() ?? 50.0;
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _ringkasanCtrl.dispose();
    _posterCtrl.dispose();
    _sampulCtrl.dispose();
    _kategoriCtrl.dispose();
    _trailerCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primaryGold, onPrimary: AppTheme.backgroundBlack, surface: AppTheme.surfaceDark, onSurface: AppTheme.textWhite),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final film = Film(
      id: widget.film?.id,
      judul: _judulCtrl.text.trim(),
      ringkasan: _ringkasanCtrl.text.trim(),
      gambarPoster: _posterCtrl.text.trim(),
      gambarSampul: _sampulCtrl.text.trim(),
      tanggalRilis: _selectedDate.millisecondsSinceEpoch ~/ 1000,
      skorRating: _rating.round(),
      kategori: _kategoriCtrl.text.trim(),
      urlTrailer: _trailerCtrl.text.trim(),
    );

    final ctrl = context.read<FilmController>();
    final success = isEditMode ? await ctrl.updateFilm(film) : await ctrl.addFilm(film);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Film berhasil diupdate!' : 'Film berhasil ditambahkan!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ctrl.errorMessage ?? 'Terjadi kesalahan'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['Info', 'Media', 'Detail'];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Film' : 'Tambah Film'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // ── Step Indicator ──
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(steps.length, (i) {
                final isActive = _currentStep == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentStep = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppTheme.goldGradient : null,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(
                          steps[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppTheme.backgroundBlack : AppTheme.textDarkGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // ── Form Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _currentStep == 0
                      ? _buildInfoStep()
                      : _currentStep == 1
                          ? _buildMediaStep()
                          : _buildDetailStep(),
                ),
              ),
            ),
          ),
          // ── Bottom Action Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(top: BorderSide(color: AppTheme.dividerColor.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentStep--),
                        child: const Text('Kembali'),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : _currentStep < 2
                              ? () => setState(() => _currentStep++)
                              : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.backgroundBlack))
                          : Text(
                              _currentStep < 2 ? 'Lanjut' : (isEditMode ? 'Simpan' : 'Tambah Film'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Info ──
  Widget _buildInfoStep() {
    return Column(
      key: const ValueKey('info'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Informasi Dasar', Icons.info_outline_rounded),
        const SizedBox(height: 16),
        _label('Judul Film'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _judulCtrl,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'Masukkan judul film', prefixIcon: Icon(Icons.movie_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
        ),
        const SizedBox(height: 18),
        _label('Kategori'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _kategoriCtrl,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'Contoh: Action, Drama', prefixIcon: Icon(Icons.category_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Kategori wajib diisi' : null,
        ),
        const SizedBox(height: 18),
        _label('Ringkasan'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _ringkasanCtrl,
          style: const TextStyle(color: AppTheme.textWhite),
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Tulis sinopsis film...', alignLabelWithHint: true),
          validator: (v) => v == null || v.trim().isEmpty ? 'Ringkasan wajib diisi' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Step 2: Media ──
  Widget _buildMediaStep() {
    return Column(
      key: const ValueKey('media'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Media', Icons.image_outlined),
        const SizedBox(height: 16),
        _label('URL Poster'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _posterCtrl,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'https://example.com/poster.jpg', prefixIcon: Icon(Icons.image_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'URL poster wajib diisi' : null,
        ),
        if (_posterCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(_posterCtrl.text, height: 120, width: 85, fit: BoxFit.cover, errorBuilder: (_, e, s) => const SizedBox.shrink()),
          ),
        ],
        const SizedBox(height: 18),
        _label('URL Sampul'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _sampulCtrl,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'https://example.com/cover.jpg', prefixIcon: Icon(Icons.panorama_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'URL sampul wajib diisi' : null,
        ),
        const SizedBox(height: 18),
        _label('URL Trailer (Opsional)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _trailerCtrl,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'https://youtube.com/watch?v=...', prefixIcon: Icon(Icons.play_circle_outline_rounded)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Step 3: Detail ──
  Widget _buildDetailStep() {
    return Column(
      key: const ValueKey('detail'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Detail', Icons.tune_rounded),
        const SizedBox(height: 16),
        _label('Tanggal Rilis'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryGold, size: 20),
                const SizedBox(width: 14),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 15),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textGrey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('Skor Rating'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '${_rating.round()}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.backgroundBlack),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      i < (_rating / 20).ceil() ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppTheme.primaryGold,
                      size: 28,
                    ),
                  );
                }),
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppTheme.primaryGold,
                  inactiveTrackColor: AppTheme.dividerColor,
                  thumbColor: AppTheme.primaryGold,
                  overlayColor: AppTheme.primaryGold.withValues(alpha: 0.15),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(value: _rating, min: 0, max: 100, divisions: 100, onChanged: (v) => setState(() => _rating = v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3));
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryGold.withValues(alpha: 0.08), Colors.transparent]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 24),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
