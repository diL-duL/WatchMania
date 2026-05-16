import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/film_controller.dart';
import '../models/film_model.dart';
import '../theme/app_theme.dart';
import 'film_form_view.dart';

class FilmDetailView extends StatelessWidget {
  final Film film;
  const FilmDetailView({super.key, required this.film});

  String _formatDate(int timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthController>().isAdmin;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ──
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.surfaceDark,
            leading: _circleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              if (isAdmin)
                _circleButton(
                  icon: Icons.edit_rounded,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FilmFormView(film: film))).then((_) {
                      if (context.mounted) Navigator.pop(context);
                    });
                  },
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    film.gambarSampul,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => Container(color: AppTheme.surfaceDark, child: const Icon(Icons.image_not_supported, color: AppTheme.textDarkGrey, size: 64)),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.backgroundBlack.withValues(alpha: 0.5),
                          AppTheme.backgroundBlack,
                        ],
                        stops: const [0.2, 0.65, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Poster + Info Row ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Poster with shadow
                        Hero(
                          tag: 'poster_${film.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 120,
                                height: 175,
                                child: Image.network(
                                  film.gambarPoster,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, e, s) => Container(
                                    color: AppTheme.cardDark,
                                    child: const Icon(Icons.movie_rounded, color: AppTheme.primaryGold, size: 48),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title & meta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(film.judul, style: Theme.of(context).textTheme.headlineLarge),
                              const SizedBox(height: 8),
                              // Category
                              Chip(
                                label: Text(film.kategori),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(height: 10),
                              // Date
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.textGrey),
                                  const SizedBox(width: 6),
                                  Text(_formatDate(film.tanggalRilis), style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Rating Card ──
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          // Circular rating
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: film.skorRating / 100,
                                  strokeWidth: 5,
                                  backgroundColor: AppTheme.dividerColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    film.skorRating >= 70 ? AppTheme.primaryGold : film.skorRating >= 40 ? AppTheme.accentAmber : AppTheme.errorRed,
                                  ),
                                ),
                                Text(
                                  '${film.skorRating}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textWhite),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Skor Rating', style: TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (i) {
                                    return Icon(
                                      i < (film.skorRating / 20).ceil() ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: AppTheme.primaryGold,
                                      size: 24,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Synopsis ──
                    Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryGold)),
                    const SizedBox(height: 10),
                    Text(film.ringkasan, style: const TextStyle(color: AppTheme.textGrey, fontSize: 15, height: 1.7)),
                    const SizedBox(height: 24),

                    // ── Trailer ──
                    if (film.urlTrailer.isNotEmpty) ...[
                      Text('Trailer', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryGold)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(gradient: AppTheme.goldGradient, borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.play_arrow_rounded, color: AppTheme.backgroundBlack, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Text(film.urlTrailer, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Admin Actions ──
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => FilmFormView(film: film))).then((_) {
                                    if (context.mounted) Navigator.pop(context);
                                  });
                                },
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                label: const Text('Edit'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.errorRed,
                                  side: const BorderSide(color: AppTheme.errorRed, width: 1.5),
                                ),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Film'),
                                      content: Text('Hapus "${film.judul}"?', style: const TextStyle(color: AppTheme.textGrey)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: AppTheme.textGrey))),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && context.mounted) {
                                    final success = await context.read<FilmController>().deleteFilm(film.id!);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(success ? 'Film dihapus!' : 'Gagal menghapus'),
                                        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                                      ));
                                      if (success) Navigator.pop(context);
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                label: const Text('Hapus'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppTheme.primaryGold, size: 20),
        ),
      ),
    );
  }
}
