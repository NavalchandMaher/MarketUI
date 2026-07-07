import 'package:flutter/material.dart';

import '../utils/constants.dart';

class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadiusGeometry borderRadius;

  const SkeletonLoader({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppConstants.radius),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: borderRadius,
      ),
    );
  }
}
