import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import 'sidebar_widget.dart';
import '../dashboard/overview_module.dart';
import '../sales/sales_module.dart';
import '../sales/sales_form_screen.dart';
import '../purchasing/purchasing_module.dart';
import '../purchasing/purchasing_form_screen.dart';
import '../inventory/inventory_module.dart';
import '../accounting/accounting_module.dart';
import '../reports/reports_module.dart';
import '../settings/settings_module.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
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
                  _buildTopbar(context, provider, isMobile),
                  _buildTabBar(context, provider),
                  Expanded(
                    child: Container(
                      color: AppColors.bgApp,
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

  Widget _buildTopbar(BuildContext context, AppProvider provider, bool isMobile) {
    final biz = provider.selectedBusiness?.name ?? 'PT Malang Manufaktur';
    final cc = provider.selectedCostCenter?.code ?? 'CC-PROD';
    final wh = provider.selectedWarehouse?.name ?? 'Gudang Utama Malang';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              if (isMobile) {
                Scaffold.of(context).openDrawer();
              } else {
                provider.toggleSidebar();
              }
            },
            color: AppColors.secondary,
            tooltip: 'Toggle Sidebar',
          ),
          const SizedBox(width: 8),
          // Context Tags
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _contextTag(Icons.home_outlined, biz, () => provider.navigateTo(AppView.business)),
                const SizedBox(width: 8),
                _contextTag(Icons.business_center_outlined, cc, () => provider.navigateTo(AppView.costCenter)),
                const SizedBox(width: 8),
                _contextTag(Icons.inventory_2_outlined, wh, () => provider.navigateTo(AppView.gudang)),
              ]),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 16),
            SizedBox(
              width: 280,
              child: TextField(
                onChanged: provider.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Cari SKU, faktur, pelanggan...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => provider.openNewForm('sales'),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+ Buat Transaksi'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contextTag(IconData icon, String label, VoidCallback onGanti) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onGanti,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text('Ganti', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppProvider provider) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: provider.openTabs.map((tab) {
          final isActive = provider.activeModule == tab['id'];
          final isClosable = tab['closable'] == 'true';
          return GestureDetector(
            onTap: () => provider.switchModule(tab['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isActive ? AppColors.primary : Colors.transparent, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tab['name']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.textMuted)),
                  if (isClosable) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => provider.closeTab(tab['id']!),
                      child: Icon(Icons.close, size: 14, color: isActive ? AppColors.primary : AppColors.textMuted),
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
      return SalesFormScreen(onBack: () => provider.closeTab(module));
    }
    if (module.startsWith('purchasing_form_')) {
      return PurchasingFormScreen(onBack: () => provider.closeTab(module));
    }

    switch (module) {
      case 'overview': return const OverviewModule();
      case 'sales': return const SalesModule();
      case 'purchasing': return const PurchasingModule();
      case 'inventory': return const InventoryModule();
      case 'accounting': return const AccountingModule();
      case 'reports': return const ReportsModule();
      case 'settings': return const SettingsModule();
      default: return const OverviewModule();
    }
  }
}
