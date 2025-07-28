import 'package:flutter/material.dart';

import '../theme/neo_brutalism_theme.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.color = NeoBrutalismTheme.primaryWhite,
    this.borderColor = NeoBrutalismTheme.primaryBlack,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: NeoBrutalismTheme.neoBox(
          color: color,
          borderColor: borderColor,
        ),
        child: child,
      ),
    );
  }
}
