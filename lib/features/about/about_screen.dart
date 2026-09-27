import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppTheme.space24),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentStart.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'AnikuPlay',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppTheme.space32),

            // Kredit Metadata
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: AppTheme.surface1,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppTheme.accentStart, size: 20),
                      const SizedBox(width: AppTheme.space8),
                      Text(
                        'Kredit Metadata & Gambar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space8),
                  Text(
                    'Data anime oleh AniList.co',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.infoCyan,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppTheme.space4),
                  const Text(
                    'Seluruh judul, sinopsis, poster, banner, genre, karakter, staf, studio, dan skor disediakan live melalui AniList GraphQL API public.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space16),

            // Kredit Video & Channel YouTube Resmi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: AppTheme.surface1,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.ondemand_video_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: AppTheme.space8),
                      Text(
                        'Kredit Streaming Video',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space8),
                  const Text(
                    'Video ditayangkan oleh channel YouTube resmi masing-masing / sumber yang dicantumkan developer.',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space12),
                  const Text(
                    'Daftar Channel / Sumber Resmi Terintegrasi:',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.space8),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChannelBadge(label: 'Muse Indonesia'),
                      _ChannelBadge(label: 'Ani-One Asia'),
                      _ChannelBadge(label: 'Bstation'),
                      _ChannelBadge(label: 'Crunchyroll'),
                      _ChannelBadge(label: 'Sumber Uji Developer'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space16),

            // Lisensi Open Source
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: AppTheme.surface1,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.code_rounded, color: AppTheme.gold, size: 20),
                      const SizedBox(width: AppTheme.space8),
                      Text(
                        'Komponen & Lisensi Open-Source',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space8),
                  const Text(
                    'Dibuat dengan Flutter Framework. Menggunakan paket open-source: flutter_riverpod, dio, sqflite, youtube_player_iframe, video_player, wakelock_plus, cached_network_image, dan flutter_local_notifications.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ChannelBadge extends StatelessWidget {
  final String label;

  const _ChannelBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
