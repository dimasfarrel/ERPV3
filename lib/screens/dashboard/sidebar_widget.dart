import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';

class ErpSidebar extends StatelessWidget {
  const ErpSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: AppColors.sidebarGradient,
        boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(4, 0))],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Menu Utama'),
                  _buildNavItem(context, 'overview', 'Dashboard', Icons.grid_view_rounded, provider),
                  _buildNavItem(context, 'sales', 'Penjualan (Sales)', Icons.attach_money_rounded, provider, badge: null),
                  _buildNavItem(context, 'purchasing', 'Pembelian (Purchase)', Icons.shopping_cart_outlined, provider, badge: '2 PO'),
                  _buildNavItem(context, 'inventory', 'Inventori & Stok', Icons.inventory_2_outlined, provider),
                  _buildNavItem(context, 'accounting', 'Keuangan & Pajak', Icons.description_outlined, provider),
                  const SizedBox(height: 16),
                  _buildSectionLabel('Administrasi'),
                  _buildNavItem(context, 'reports', 'Laporan Eksekutif', Icons.bar_chart_rounded, provider),
                  _buildNavItem(context, 'settings', 'Pengaturan Sistem', Icons.settings_outlined, provider),
                ],
              ),
            ),
          ),
          _buildFooter(context, provider),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text('M', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ERP Malang', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Enterprise Suite', style: GoogleFonts.inter(fontSize: 11, color: AppColors.sidebarText)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.sidebarText.withOpacity(0.6), letterSpacing: 0.8)),
    );
  }

  Widget _buildNavItem(BuildContext context, String moduleId, String label, IconData icon, AppProvider provider, {String? badge}) {
    final isActive = provider.activeModule == moduleId;

    return GestureDetector(
      onTap: () => provider.switchModule(moduleId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isActive ? Colors.white : AppColors.sidebarText),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.sidebarText),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? Colors.white : AppColors.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppProvider provider) {
    final initials = provider.username.length >= 2
      ? provider.username.substring(0, 2).toUpperCase()
      : provider.username.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF334155)))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(initials, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.username, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
                Text('Super Administrator', style: GoogleFonts.inter(fontSize: 11, color: AppColors.sidebarText)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.sidebarText),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Konfirmasi Logout', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  content: Text('Apakah Anda yakin ingin keluar dari sistem?', style: GoogleFonts.inter()),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    ElevatedButton(
                      onPressed: () { Navigator.pop(ctx); provider.logout(); },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
