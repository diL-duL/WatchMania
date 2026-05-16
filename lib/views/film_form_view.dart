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
  late TextEditingController _judulCtrl, _ringkasanCtrl, _posterCtrl, _sampulCtrl, _kategoriCtrl, _trailerCtrl;
  late DateTime _selectedDate;
  late double _rating;
  bool _isSubmitting = false;
  int _step = 0;

  bool get isEdit => widget.film != null;

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
    _judulCtrl.dispose(); _ringkasanCtrl.dispose(); _posterCtrl.dispose();
    _sampulCtrl.dispose(); _kategoriCtrl.dispose(); _trailerCtrl.dispose();
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
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary, onPrimary: Colors.white, surface: AppTheme.surface, onSurface: AppTheme.textWhite),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
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
    final success = isEdit ? await ctrl.updateFilm(film) : await ctrl.addFilm(film);

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? (isEdit ? 'Film berhasil diupdate!' : 'Film berhasil ditambahkan!')
            : (ctrl.errorMessage ?? 'Terjadi kesalahan')),
        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
      ));
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const steps = ['Info', 'Media', 'Detail'];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Film' : 'Tambah Film'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // Step Indicator
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: List.generate(steps.length, (i) {
                final active = _step == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _step = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: active ? AppTheme.purpleGradient : null,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(steps[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppTheme.textDim)),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _step == 0 ? _infoStep() : _step == 1 ? _mediaStep() : _detailStep(),
                ),
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.divider.withValues(alpha: 0.5))),
            ),
            child: Row(children: [
              if (_step > 0) ...[
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Kembali', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: _step > 0 ? 2 : 1,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : (_step < 2 ? () => setState(() => _step++) : _submit),
                    child: _isSubmitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(_step < 2 ? 'Lanjut' : (isEdit ? 'Simpan' : 'Tambah Film'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _infoStep() {
    return Column(
      key: const ValueKey('info'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Informasi Dasar', Icons.info_outline_rounded),
        const SizedBox(height: 16),
        _label('Judul Film'),
        const SizedBox(height: 8),
        TextFormField(controller: _judulCtrl, style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'Masukkan judul film', prefixIcon: Icon(Icons.movie_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null),
        const SizedBox(height: 16),
        _label('Kategori'),
        const SizedBox(height: 8),
        TextFormField(controller: _kategoriCtrl, style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'Contoh: Action, Drama', prefixIcon: Icon(Icons.category_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Kategori wajib diisi' : null),
        const SizedBox(height: 16),
        _label('Ringkasan'),
        const SizedBox(height: 8),
        TextFormField(controller: _ringkasanCtrl, style: const TextStyle(color: AppTheme.textWhite), maxLines: 4,
          decoration: const InputDecoration(hintText: 'Tulis sinopsis film...', alignLabelWithHint: true),
          validator: (v) => v == null || v.trim().isEmpty ? 'Ringkasan wajib diisi' : null),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _mediaStep() {
    return Column(
      key: const ValueKey('media'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Media', Icons.image_outlined),
        const SizedBox(height: 16),
        _label('URL Poster'),
        const SizedBox(height: 8),
        TextFormField(controller: _posterCtrl, style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'https://example.com/poster.jpg', prefixIcon: Icon(Icons.image_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'URL poster wajib diisi' : null),
        if (_posterCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_posterCtrl.text, height: 110, width: 80, fit: BoxFit.cover, errorBuilder: (_, e, s) => const SizedBox.shrink())),
        ],
        const SizedBox(height: 16),
        _label('URL Sampul'),
        const SizedBox(height: 8),
        TextFormField(controller: _sampulCtrl, style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'https://example.com/cover.jpg', prefixIcon: Icon(Icons.panorama_rounded)),
          validator: (v) => v == null || v.trim().isEmpty ? 'URL sampul wajib diisi' : null),
        const SizedBox(height: 16),
        _label('URL Trailer (Opsional)'),
        const SizedBox(height: 8),
        TextFormField(controller: _trailerCtrl, style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(hintText: 'https://youtube.com/watch?v=...', prefixIcon: Icon(Icons.play_circle_outline_rounded))),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _detailStep() {
    return Column(
      key: const ValueKey('detail'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Detail', Icons.tune_rounded),
        const SizedBox(height: 16),
        _label('Tanggal Rilis'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 14),
              Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: AppTheme.textWhite, fontSize: 15)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.textGrey),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _label('Skor Rating'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(gradient: AppTheme.purpleGradient, borderRadius: BorderRadius.circular(10)),
            child: Text('${_rating.round()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.divider)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(i < (_rating / 20).ceil() ? Icons.star_rounded : Icons.star_outline_rounded, color: AppTheme.primary, size: 26),
            ))),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.primary,
                inactiveTrackColor: AppTheme.divider,
                thumbColor: AppTheme.primary,
                overlayColor: AppTheme.primary.withValues(alpha: 0.15),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(value: _rating, min: 0, max: 100, divisions: 100, onChanged: (v) => setState(() => _rating = v)),
            ),
          ]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3));

  Widget _header(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primary.withValues(alpha: 0.08), Colors.transparent]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: AppTheme.primary, fontSize: 15, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
