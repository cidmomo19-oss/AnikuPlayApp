import 'package:flutter/material.dart';
import '../app/theme.dart';

class EpisodeTile extends StatelessWidget {
  final int episodeNumber;
  final String videoType;
  final String sourceChannel;
  final bool isWatched;
  final bool isDownloaded;
  final VoidCallback onTap;
  final VoidCallback? onDownloadTap;

  const EpisodeTile({
    super.key,
    required this.episodeNumber,
    required this.videoType,
    required this.sourceChannel,
    this.isWatched = false,
    this.isDownloaded = false,
    required this.onTap,
    this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space8),
      decoration: BoxDecoration(
        color: AppTheme.surface1,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: isWatched
              ? AppTheme.accentStart.withValues(alpha: 0.3)
              : AppTheme.surface2,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isWatched ? AppTheme.primaryGradient : null,
            color: isWatched ? null : AppTheme.surface2,
          ),
          child: Center(
            child: Text(
              '$episodeNumber',
              style: TextStyle(
                color: isWatched ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          'Episode $episodeNumber',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14,
              ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: videoType == 'youtube'
                    ? Colors.red.withValues(alpha: 0.2)
                    : AppTheme.infoCyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                videoType.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: videoType == 'youtube'
                      ? Colors.redAccent
                      : AppTheme.infoCyan,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.space8),
            Expanded(
              child: Text(
                sourceChannel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
              ),
            ),
          ],
        ),
        trailing: videoType == 'direct'
            ? IconButton(
                icon: Icon(
                  isDownloaded ? Icons.check_circle_rounded : Icons.download_rounded,
                  color: isDownloaded ? AppTheme.infoCyan : AppTheme.textSecondary,
                ),
                onPressed: isDownloaded ? null : onDownloadTap,
              )
            : const Icon(Icons.play_circle_fill_rounded, color: AppTheme.accentStart),
      ),
    );
  }
}
