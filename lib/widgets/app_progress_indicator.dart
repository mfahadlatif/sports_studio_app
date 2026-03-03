import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';

class AppProgressIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppProgressIndicator({
    super.key,
    this.size = 56, // Updated default size to 56
    this.strokeWidth = 4,
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
