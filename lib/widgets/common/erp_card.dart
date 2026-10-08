import 'package:flutter/material.dart';

class ErpCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Border? border;

  const ErpCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color _defaultBg = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _defaultBorder = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);

    return Card(
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        side: BorderSide(
          color: isDark ? (_defaultBorder) : const Color(0xFFCED4DA),
          width: 1,
        ),
      ),
      color: backgroundColor ?? _defaultBg,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

  }
}
