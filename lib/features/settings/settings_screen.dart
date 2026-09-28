import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../about/about_screen.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface1,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync_rounded, color: AppTheme.accentStart),
                  title: const Text('Refresh Katalog Anime'),
                  subtitle: const Text('Perbarui data catalog.json dari Gist'),
                  onTap: () {
                    ref.invalidate(catalogProvider);
                    ref.invalidate(aniListBatchProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Katalog sedang diperbarui...'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppTheme.surface2),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppTheme.infoCyan),
                  title: const Text('Tentang Aplikasi'),
                  subtitle: const Text('Kredit, lisensi, dan informasi pengembang'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
