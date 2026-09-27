import 'package:flutter/material.dart';
import '../app/theme.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
          border: Border.all(
            color: AppTheme.accentStart.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
