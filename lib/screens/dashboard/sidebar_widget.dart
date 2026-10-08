import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';

class ErpSidebar extends StatelessWidget {
  const ErpSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;

    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: _baseColor,
        border: Border(right: BorderSide(color: _borderColor)),
      ),
      child: Column(
        children: [
          _buildBrandHeader(isDark, _borderColor, _textPrimary, _textSecondary),
          _buildBusinessKicker(provider, isDark, _borderColor, _textPrimary, _textSecondary),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('OPERASIONAL BISNIS', _textSecondary),
                  _buildNavItem(context, 'overview', 'Dashboard Eksekutif', Icons.dashboard_outlined, provider, isDark),
                  _buildNavItem(context, 'sales', 'Penjualan & Piutang', Icons.shopping_cart_outlined, provider, isDark),
                  _buildNavItem(context, 'purchasing', 'Pembelian & Hutang', Icons.local_shipping_outlined, provider, isDark),
                  _buildNavItem(context, 'inventory', 'Gudang & Stok', Icons.inventory_2_outlined, provider, isDark),
                  _buildNavItem(context, 'manufacturing', 'Manufaktur & BOM', Icons.precision_manufacturing_outlined, provider, isDark, badge: 'PRO'),
                  _buildNavItem(context, 'hr', 'SDM & Payroll', Icons.badge_outlined, provider, isDark, badge: 'PRO'),
                  _buildNavItem(context, 'accounting', 'Keuangan & Akuntansi', Icons.pie_chart_outline, provider, isDark),
                  const SizedBox(height: 16),
                  _buildSectionLabel('ADMINISTRASI & SISTEM', _textSecondary),
                  _buildNavItem(context, 'reports', 'Laporan Eksekutif', Icons.bar_chart_rounded, provider, isDark),
                  _buildNavItem(context, 'settings', 'Pengaturan Sistem', Icons.settings_outlined, provider, isDark),
                ],
              ),
            ),
          ),
          _buildFooter(context, provider, isDark, _borderColor, _textPrimary, _textSecondary),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(bool isDark, Color borderColor, Color textPrimary, Color textSecondary) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.layers, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enterprise ERP',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                'Core System',
                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessKicker(AppProvider provider, bool isDark, Color borderColor, Color textPrimary, Color textSecondary) {
    final biz = provider.selectedBusiness;
    final Color _subtleColor = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _subtleColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.business, color: textSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  biz?.name ?? 'PT Sinar Surya',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  biz?.code ?? 'Manufaktur',
                  style: GoogleFonts.ibmPlexSans(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        label,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String moduleId, String label, IconData icon, AppProvider provider, bool isDark, {String? badge}) {
    final isActive = provider.activeModule == moduleId;
    
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _subtleColor = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return GestureDetector(
      onTap: () => provider.switchModule(moduleId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _subtleColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? _primaryColor.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? _primaryColor : _textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? _textPrimary : _textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _subtleColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppProvider provider, bool isDark, Color borderColor, Color textPrimary, Color textSecondary) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Column(
        children: [
          // User profile row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text('AD', style: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.username,
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      provider.userRole.label,
                      style: GoogleFonts.ibmPlexSans(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, size: 18, color: Color(0xFFB3363B)),
                onPressed: () => provider.logout(),
                tooltip: 'Keluar',
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Role selector dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UserRole>(
                value: provider.userRole,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF),
                icon: Icon(Icons.arrow_drop_down, color: textSecondary, size: 20),
                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textPrimary),
                onChanged: (newRole) {
                  if (newRole != null) provider.setUserRole(newRole);
                },
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text('Peran: ${role.label}'),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
