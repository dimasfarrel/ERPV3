import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/selection_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const ErpMalangApp(),
    ),
  );
}

class ErpMalangApp extends StatelessWidget {
  const ErpMalangApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'ERP Malang - Enterprise Suite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: _buildView(provider),
    );
  }

  Widget _buildView(AppProvider provider) {
    switch (provider.currentView) {
      case AppView.login:
        return const LoginScreen();
      case AppView.business:
        return SelectionScreen(
          key: const ValueKey('business'),
          title: 'Select Business',
          subtitle: 'Pilih unit usaha atau entitas bisnis yang ingin Anda kelola pada sesi ini',
          items: provider.businessEntities,
          onSelect: (item) => provider.selectBusiness(item),
          onBack: () => provider.navigateTo(AppView.login),
        );
      case AppView.costCenter:
        return SelectionScreen(
          key: const ValueKey('costcenter'),
          title: 'Cost Center',
          subtitle: 'Pilih alokasi departemen & pusat biaya untuk pencatatan anggaran dan transaksi',
          items: provider.costCenters,
          onSelect: (item) => provider.selectCostCenter(item),
          onBack: () => provider.navigateTo(AppView.business),
        );
      case AppView.gudang:
        return SelectionScreen(
          key: const ValueKey('gudang'),
          title: 'Gudang',
          subtitle: 'Pilih gudang aktif untuk manajemen inventori, pergerakan barang, dan stok fisik',
          items: provider.warehouses,
          onSelect: (item) => provider.selectWarehouse(item),
          onBack: () => provider.navigateTo(AppView.costCenter),
        );
      case AppView.dashboard:
        return const DashboardScreen();
    }
  }
}
