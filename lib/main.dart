import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_persistence.dart';
import 'data/providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/selection_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  final appProvider = AppProvider();
  await ThemePersistence.restoreAndWatch(appProvider);
  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
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
      title: 'iSoft ERP - System Core',
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
      child: _buildView(provider, context),
    );
  }

  Widget _buildView(AppProvider provider, BuildContext context) {
    switch (provider.currentView) {
      case AppView.login:
        return const LoginScreen();
      case AppView.business:
        return SelectionScreen(
          key: const ValueKey('business'),
          stepNumber: 1,
          stepTitle: 'Entitas Perusahaan',
          title: 'Pilih Unit Bisnis',
          subtitle: 'Pilih unit usaha atau entitas legal untuk mengisolasi laporan keuangan, COA, dan perpajakan',
          items: provider.businessEntities,
          onSelect: (item) => provider.selectBusiness(item, context: context),
          onBack: () => provider.navigateTo(AppView.login),
        );
      case AppView.costCenter:
        return SelectionScreen(
          key: const ValueKey('costcenter'),
          stepNumber: 2,
          stepTitle: 'Divisi / Cost Center',
          title: 'Pilih Pusat Biaya (Cost Center)',
          subtitle: 'Pilih alokasi departemen operasional untuk pencatatan anggaran beban dan pusat pertanggungjawaban',
          items: provider.costCenters,
          onSelect: (item) => provider.selectCostCenter(item, context: context),
          onBack: () => provider.navigateTo(AppView.business),
        );
      case AppView.gudang:
        return SelectionScreen(
          key: const ValueKey('gudang'),
          stepNumber: 3,
          stepTitle: 'Lokasi Gudang Fisik',
          title: 'Pilih Gudang Aktif',
          subtitle: 'Pilih gudang fisik tempat terjadinya mutasi stok, penerimaan barang PO, dan distribusi barang jadi',
          items: provider.warehouses,
          onSelect: (item) => provider.selectWarehouse(item),
          onBack: () => provider.navigateTo(AppView.costCenter),
        );
      case AppView.dashboard:
        return const DashboardScreen();
    }
  }
}
