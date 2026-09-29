import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String type; // success, warning, danger, info, muted

  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: colors.$1, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.$1,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (type) {
      case 'success': return (AppColors.success, AppColors.successSurface);
      case 'warning': return (AppColors.warning, AppColors.warningSurface);
      case 'danger': return (AppColors.danger, AppColors.dangerSurface);
      case 'info': return (AppColors.info, AppColors.infoSurface);
      default: return (AppColors.textMuted, AppColors.borderLight);
    }
  }
}
