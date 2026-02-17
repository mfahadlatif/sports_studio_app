import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'glass_container.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double iconSize;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showText = true,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.premiumGradient,
            boxShadow: AppColors.premiumShadow,
            border: Border.all(color: AppColors.glassBorder, width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.sports_cricket_rounded,
                size: iconSize,
                color: Colors.white.withOpacity(0.9),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.premiumGradient.createShader(bounds),
            child: const Text(
              'Sports Studio',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
