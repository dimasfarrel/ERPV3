import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'erp_card.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final String trendLabel;
  final bool trendUp;
  final IconData icon;
  final Color iconColor;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.trendLabel,
    required this.trendUp,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ErpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              ),
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 20)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: trendUp ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: trendUp ? AppColors.success : AppColors.danger),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(trendLabel, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
