import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../app/theme.dart';
import 'shimmer_card.dart';

class AnimeCard extends StatefulWidget {
  final String title;
  final String? imageUrl;
  final double? rating;
  final String? subtitle;
  final VoidCallback onTap;

  const AnimeCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.rating,
    this.subtitle,
    required this.onTap,
  });

  @override
  State<AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface1,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: widget.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerBox(),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.surface2,
                          child: const Icon(Icons.broken_image, color: AppTheme.textSecondary),
                        ),
                      )
                    else
                      Container(
                        color: AppTheme.surface2,
                        child: const Icon(Icons.movie_rounded, color: AppTheme.textSecondary, size: 40),
                      ),
                    if (widget.rating != null)
                      Positioned(
                        top: AppTheme.space8,
                        right: AppTheme.space8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.gold, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                (widget.rating! / 10).toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
