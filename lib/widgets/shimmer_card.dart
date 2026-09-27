import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../app/theme.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppTheme.radiusCard,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface1,
      highlightColor: AppTheme.surface2,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.surface1,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
