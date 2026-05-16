import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/film_controller.dart';
import '../models/film_model.dart';
import '../theme/app_theme.dart';
import 'film_detail_view.dart';
import 'film_form_view.dart';
import 'profile_view.dart';

class FilmListView extends StatefulWidget {
  const FilmListView({super.key});

  @override
  State<FilmListView> createState() => _FilmListViewState();
}

class _FilmListViewState extends State<FilmListView> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;
  bool _isGridView = true;
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilmController>().fetchFilms();
      _fabAnim.forward();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchCtrl.clear();
        context.read<FilmController>().setSearchQuery('');
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context, Film film) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Film'),
        content: Text('Hapus "${film.judul}"?', style: const TextStyle(color: AppTheme.textGrey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal', style: TextStyle(color: AppTheme.textGrey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
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
          content: Text(success ? 'Film berhasil dihapus!' : 'Gagal menghapus film'),
          backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthController>().isAdmin;
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.surface.withValues(alpha: 0.95),
            title: _isSearching
                ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 16),
                    decoration: const InputDecoration(hintText: 'Cari judul atau kategori...', border: InputBorder.none, filled: false),
                    onChanged: (v) => context.read<FilmController>().setSearchQuery(v),
                  )
                : Row(
                    children: [
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(gradient: AppTheme.purpleGradient, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.movie_filter_rounded, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text('FILMKU', style: Theme.of(context).appBarTheme.titleTextStyle),
                    ],
                  ),
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
                onPressed: _toggleSearch,
              ),
              if (!_isSearching)
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
                  onPressed: () => setState(() => _isGridView = !_isGridView),
                ),
              if (!_isSearching)
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileView())),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12, left: 4),
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      gradient: AppTheme.purpleGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        user != null && user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        body: Consumer<FilmController>(
          builder: (context, ctrl, _) {
            if (ctrl.isLoading && ctrl.films.isEmpty) return _buildShimmer();
            if (ctrl.errorMessage != null && ctrl.films.isEmpty) return _buildError(context, ctrl);
            if (ctrl.films.isEmpty) return _buildEmpty(context);
            return RefreshIndicator(
              onRefresh: () => ctrl.fetchFilms(),
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: _isGridView
                  ? _buildGrid(ctrl.films, isAdmin)
                  : _buildList(ctrl.films, isAdmin),
            );
          },
        ),
      ),
      floatingActionButton: isAdmin
          ? ScaleTransition(
              scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
              child: FloatingActionButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilmFormView()))
                    .then((_) { if (context.mounted) context.read<FilmController>().fetchFilms(); }),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            )
          : null,
    );
  }

  Widget _buildGrid(List<Film> films, bool isAdmin) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.58, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemCount: films.length,
      itemBuilder: (context, i) => _GridCard(
        film: films[i], index: i, isAdmin: isAdmin,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FilmDetailView(film: films[i])))
            .then((_) { if (context.mounted) context.read<FilmController>().fetchFilms(); }),
        onDelete: () => _confirmDelete(context, films[i]),
      ),
    );
  }

  Widget _buildList(List<Film> films, bool isAdmin) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: films.length,
      itemBuilder: (context, i) => _ListCard(
        film: films[i], index: i, isAdmin: isAdmin,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FilmDetailView(film: films[i])))
            .then((_) { if (context.mounted) context.read<FilmController>().fetchFilms(); }),
        onDelete: () => _confirmDelete(context, films[i]),
      ),
    );
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.58, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(color: AppTheme.shimmerBase, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Expanded(flex: 3, child: Container(decoration: BoxDecoration(color: AppTheme.shimmerHigh, borderRadius: const BorderRadius.vertical(top: Radius.circular(18))))),
            Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 10, decoration: BoxDecoration(color: AppTheme.shimmerHigh, borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: 6),
                Container(height: 8, width: 70, decoration: BoxDecoration(color: AppTheme.shimmerHigh, borderRadius: BorderRadius.circular(5))),
              ],
            ))),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, FilmController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppTheme.errorRed.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.wifi_off_rounded, size: 36, color: AppTheme.errorRed)),
          const SizedBox(height: 20),
          Text('Gagal Memuat', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(ctrl.errorMessage!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: () => ctrl.fetchFilms(), icon: const Icon(Icons.refresh_rounded), label: const Text('Coba Lagi')),
        ]),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.movie_creation_outlined, size: 36, color: AppTheme.primary.withValues(alpha: 0.6))),
          const SizedBox(height: 20),
          Text(_searchCtrl.text.isNotEmpty ? 'Tidak Ditemukan' : 'Belum Ada Film', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(_searchCtrl.text.isNotEmpty ? 'Coba kata kunci lain' : 'Film akan muncul di sini', style: Theme.of(context).textTheme.bodyMedium),
        ]),
      ),
    );
  }
}

// ── Grid Card ──
class _GridCard extends StatelessWidget {
  final Film film;
  final int index;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GridCard({required this.film, required this.index, required this.isAdmin, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (_, val, child) => Transform.translate(offset: Offset(0, 20 * (1 - val)), child: Opacity(opacity: val.clamp(0, 1), child: child)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Hero(
                      tag: 'poster_${film.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.network(film.gambarPoster, fit: BoxFit.cover,
                            errorBuilder: (_, e, s) => Container(color: AppTheme.surface, child: const Center(child: Icon(Icons.movie_rounded, color: AppTheme.primary, size: 36)))),
                        ),
                      ),
                    ),
                    // Rating badge
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(gradient: AppTheme.purpleGradient, borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 2),
                          Text('${film.skorRating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                        ]),
                      ),
                    ),
                    if (isAdmin)
                      Positioned(
                        top: 8, left: 8,
                        child: GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 15),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(film.judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textWhite), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(film.kategori, style: TextStyle(fontSize: 11, color: AppTheme.primary.withValues(alpha: 0.9), fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── List Card ──
class _ListCard extends StatelessWidget {
  final Film film;
  final int index;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ListCard({required this.film, required this.index, required this.isAdmin, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (_, val, child) => Transform.translate(offset: Offset(0, 20 * (1 - val)), child: Opacity(opacity: val.clamp(0, 1), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            splashColor: AppTheme.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Hero(
                    tag: 'poster_${film.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 72, height: 100,
                        child: Image.network(film.gambarPoster, fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => Container(color: AppTheme.surface, child: const Center(child: Icon(Icons.movie_rounded, color: AppTheme.primary, size: 28)))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(film.judul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                        child: Text(film.kategori, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ),
                      const SizedBox(height: 6),
                      Text(film.ringkasan, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(gradient: AppTheme.purpleGradient, borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 2),
                        Text('${film.skorRating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppTheme.errorRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 16),
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
