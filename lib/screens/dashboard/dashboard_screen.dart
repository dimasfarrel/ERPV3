import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import 'sidebar_widget.dart';
import 'overview_module.dart';
import '../sales/sales_module.dart';
import '../sales/sales_form_screen.dart';
import '../purchasing/purchasing_module.dart';
import '../purchasing/purchasing_form_screen.dart';
import '../inventory/inventory_module.dart';
import '../manufacturing/manufacturing_module.dart';
import '../hr/hr_module.dart';
import '../accounting/accounting_module.dart';
import '../reports/reports_module.dart';
import '../settings/settings_module.dart';
import '../lite/lite_erp_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;

    // Design Tokens
    final Color _canvasColor = isDark ? const Color(0xFF11171D) : const Color(0xFFF6F8FA);

    // If User activated LITE MODE, render the touchscreen POS & retail shop view!
    if (provider.edition == AppEdition.lite) {
      return const LiteErpScreen();
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      drawer: isMobile ? const Drawer(child: ErpSidebar()) : null,
      body: Builder(
        builder: (context) => Row(
          children: [
            if (!isMobile && provider.isSidebarOpen) const ErpSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopbar(context, provider, isMobile, isDark),
                  _buildTabBar(context, provider, isDark),
                  Expanded(
                    child: Container(
                      color: _canvasColor,
                      child: _buildCurrentModule(provider, provider.activeModule),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopbar(BuildContext context, AppProvider provider, bool isMobile, bool isDark) {
    final biz = provider.selectedBusiness?.name ?? 'PT Sinar Surya';
    final cc = provider.selectedCostCenter?.code ?? 'CC-PROD';
    final wh = provider.selectedWarehouse?.name ?? 'Gudang Utama';

    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _baseColor,
        border: Border(
          bottom: BorderSide(color: _borderColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 20),
            onPressed: () {
              if (isMobile) {
                Scaffold.of(context).openDrawer();
              } else {
                provider.toggleSidebar();
              }
            },
            color: _textSecondary,
            tooltip: 'Toggle Sidebar',
            splashRadius: 20,
          ),
          const SizedBox(width: 8),

          // Multi-Tier Scope Badges (Unit Usaha, Cost Center, Gudang)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _contextTag(Icons.business, biz, () => provider.navigateTo(AppView.business), isDark),
                  const SizedBox(width: 6),
                  _contextTag(Icons.account_tree_outlined, cc, () => provider.navigateTo(AppView.costCenter), isDark),
                  const SizedBox(width: 6),
                  _contextTag(Icons.inventory_2_outlined, wh, () => provider.navigateTo(AppView.gudang), isDark),
                  const SizedBox(width: 12),
                  
                  // Live DB status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: provider.isUsingLiveDatabase 
                          ? const Color(0xFF087A65).withOpacity(0.1) 
                          : const Color(0xFF9A6200).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: provider.isUsingLiveDatabase 
                            ? const Color(0xFF087A65).withOpacity(0.3) 
                            : const Color(0xFF9A6200).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle, 
                          size: 8, 
                          color: provider.isUsingLiveDatabase ? const Color(0xFF087A65) : const Color(0xFF9A6200)
                        ),
                        const SizedBox(width: 6),
                        Text(
                          provider.isUsingLiveDatabase ? 'Live DB: ${provider.ip}' : 'Mode Mock',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: provider.isUsingLiveDatabase ? const Color(0xFF087A65) : const Color(0xFF9A6200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 16),
            SizedBox(
              width: 240,
              height: 36,
              child: TextField(
                onChanged: provider.setSearch,
                style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Cari... (Ctrl+K)',
                  hintStyle: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary),
                  prefixIcon: Icon(Icons.search, size: 18, color: _textSecondary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF11171D) : const Color(0xFFF6F8FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7)),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(width: 12),

          // VERSION SWITCHER BUTTON: PRO vs LITE
          GestureDetector(
            onTap: () => provider.toggleEdition(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'PRO',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12, 
                      fontWeight: FontWeight.w600, 
                      color: isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7)
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Theme Toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode_outlined,
              size: 20,
              color: _textSecondary,
            ),
            onPressed: () => provider.setThemeMode(!provider.isDarkMode),
            tooltip: 'Ganti Tema',
            splashRadius: 20,
          ),

          // Notifications
          IconButton(
            icon: Icon(Icons.notifications_none, size: 20, color: _textSecondary),
            tooltip: 'Notifikasi',
            splashRadius: 20,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru.'), duration: Duration(seconds: 1)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _contextTag(IconData icon, String label, VoidCallback onGanti, bool isDark) {
    final Color _subtleColor = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _subtleColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w500, color: _textSecondary),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onGanti,
            child: Text(
              'Ubah',
              style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600, color: _primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppProvider provider, bool isDark) {
    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _canvasColor = isDark ? const Color(0xFF11171D) : const Color(0xFFF6F8FA);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: _canvasColor,
        border: Border(
          bottom: BorderSide(color: _borderColor),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: provider.openTabs.map((tab) {
          final isActive = provider.activeModule == tab['id'];
          final isClosable = tab['closable'] == 'true';

          return GestureDetector(
            onTap: () => provider.switchModule(tab['id']!),
            child: Container(
              margin: const EdgeInsets.only(right: 4, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? _baseColor : Colors.transparent,
                border: Border(
                  top: BorderSide(color: isActive ? _borderColor : Colors.transparent),
                  left: BorderSide(color: isActive ? _borderColor : Colors.transparent),
                  right: BorderSide(color: isActive ? _borderColor : Colors.transparent),
                  // Bottom border is handled by the parent container or active state
                  bottom: BorderSide(color: isActive ? _baseColor : Colors.transparent, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab['name']!,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? _textPrimary : _textSecondary,
                    ),
                  ),
                  if (isClosable) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => provider.closeTab(tab['id']!),
                      child: Icon(
                        Icons.close, 
                        size: 14, 
                        color: isActive ? _textPrimary : _textSecondary
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentModule(AppProvider provider, String module) {
    if (module.startsWith('sales_form_')) {
      final targetId = module.substring('sales_form_'.length);
      return SalesFormScreen(onBack: () => provider.closeTab(module), targetId: targetId);
    }
    if (module.startsWith('purchasing_form_')) {
      final targetId = module.substring('purchasing_form_'.length);
      return PurchasingFormScreen(onBack: () => provider.closeTab(module), targetId: targetId);
    }

    switch (module) {
      case 'overview':
        return const OverviewModule();
      case 'sales':
        return const SalesModule();
      case 'purchasing':
        return const PurchasingModule();
      case 'inventory':
        return const InventoryModule();
      case 'manufacturing':
        return const ManufacturingModule();
      case 'hr':
        return const HrModule();
      case 'accounting':
        return const AccountingModule();
      case 'reports':
        return const ReportsModule();
      case 'settings':
        return const SettingsModule();
      default:
        return const OverviewModule();
    }
  }
}
