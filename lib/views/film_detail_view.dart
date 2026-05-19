import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../controllers/film_controller.dart';
import '../models/film_model.dart';
import '../theme/app_theme.dart';
import 'film_form_view.dart';

class FilmDetailView extends StatelessWidget {
  final Film film;
  const FilmDetailView({super.key, required this.film});

  String _formatDate(int ts) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(ts * 1000));
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
          // Hero Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.surface,
            leading: _circleBtn(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
            actions: [
              if (isAdmin) _circleBtn(
                icon: Icons.edit_rounded,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FilmFormView(film: film)))
                    .then((_) { if (context.mounted) Navigator.pop(context); }),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(film.gambarSampul, fit: BoxFit.cover,
                    errorBuilder: (_, e, s) => Container(color: AppTheme.surface, child: const Icon(Icons.image_not_supported, color: AppTheme.textDim, size: 60))),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.bgBlack.withValues(alpha: 0.5), AppTheme.bgBlack],
                        stops: const [0.2, 0.65, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poster + Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Hero(
                          tag: 'poster_${film.id}',
                          child: Container(
                            width: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 6))],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: AspectRatio(
                                aspectRatio: 2 / 3,
                                child: Image.network(
                                  film.gambarPoster,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, e, s) => Container(color: AppTheme.card, child: const Icon(Icons.movie_rounded, color: AppTheme.primary, size: 40)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(film.judul, style: Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(height: 8),
                            Chip(label: Text(film.kategori), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.textGrey),
                              const SizedBox(width: 6),
                              Text(_formatDate(film.tanggalRilis), style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                            ]),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Rating Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(children: [
                        SizedBox(
                          width: 60, height: 60,
                          child: Stack(alignment: Alignment.center, children: [
                            CircularProgressIndicator(
                              value: film.skorRating / 100,
                              strokeWidth: 5,
                              backgroundColor: AppTheme.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                film.skorRating >= 70 ? AppTheme.primary : film.skorRating >= 40 ? AppTheme.accent : AppTheme.errorRed,
                              ),
                            ),
                            Text('${film.skorRating}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textWhite)),
                          ]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Skor Rating', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (i) => Icon(
                                i < (film.skorRating / 20).ceil() ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: AppTheme.primary, size: 22,
                              )),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    // Synopsis
                    Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
                    const SizedBox(height: 10),
                    Text(film.ringkasan, style: const TextStyle(color: AppTheme.textGrey, fontSize: 15, height: 1.7)),
                    const SizedBox(height: 24),

                    // Trailer
                    if (film.urlTrailer.isNotEmpty) ...[
                      Text('Trailer', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.tryParse(film.urlTrailer);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tidak dapat membuka link trailer')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(gradient: AppTheme.purpleGradient, borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Buka Trailer', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(film.urlTrailer, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new_rounded, color: AppTheme.primary, size: 16),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Admin Actions
                    if (isAdmin) ...[
                      Row(children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FilmFormView(film: film)))
                                  .then((_) { if (context.mounted) Navigator.pop(context); }),
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: const Text('Edit'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorRed, side: const BorderSide(color: AppTheme.errorRed, width: 1.5)),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus Film'),
                                    content: Text('Hapus "${film.judul}"?', style: const TextStyle(color: AppTheme.textGrey)),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: AppTheme.textGrey))),
                                      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed), onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
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
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              label: const Text('Hapus'),
                            ),
                          ),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
