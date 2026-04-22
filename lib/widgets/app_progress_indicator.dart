import 'package:flutter/material.dart';
import 'package:sport_studio/core/theme/app_colors.dart';

class AppProgressIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppProgressIndicator({
    super.key,
    this.size = 40,
    this.strokeWidth = 3,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color:
              color ??
              AppColors.primary, // Updated default color to deepBlueColor
        ),
      ),
    );
  }
}
