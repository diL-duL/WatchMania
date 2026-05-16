import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  Future<void> _editName() async {
    final auth = context.read<AuthController>();
    final nameCtrl = TextEditingController(text: auth.currentUser?.nama ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Nama'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (newName != null && newName.trim().isNotEmpty && mounted) {
      final success = await auth.updateName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Nama berhasil diupdate!' : 'Gagal mengupdate nama'),
            backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
          ),
        );
      }
    }
    nameCtrl.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?', style: TextStyle(color: AppTheme.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthController>().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          final user = auth.currentUser;
          if (user == null) return const SizedBox.shrink();

          final initials = user.nama.isNotEmpty
              ? user.nama.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
              : '?';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Avatar ──
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppTheme.backgroundBlack),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Name ──
                Text(user.nama, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),

                // ── Role Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: user.isAdmin ? AppTheme.goldGradient : null,
                    color: user.isAdmin ? null : AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(30),
                    border: user.isAdmin ? null : Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                        size: 18,
                        color: user.isAdmin ? AppTheme.backgroundBlack : AppTheme.textGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.isAdmin ? 'Admin' : 'User',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: user.isAdmin ? AppTheme.backgroundBlack : AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // ── Info Cards ──
                _buildInfoTile(Icons.person_outline_rounded, 'Nama', user.nama, onEdit: _editName),
                _buildInfoTile(Icons.email_outlined, 'Email', user.email),
                _buildInfoTile(Icons.shield_outlined, 'Role', user.isAdmin ? 'Administrator' : 'User'),
                if (user.createdAt != null)
                  _buildInfoTile(
                    Icons.calendar_today_rounded,
                    'Bergabung',
                    '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}',
                  ),

                const SizedBox(height: 36),

                // ── Logout ──
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {VoidCallback? onEdit}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textDarkGrey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppTheme.textWhite, fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryGold, size: 20),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}
