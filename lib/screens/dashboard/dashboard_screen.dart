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

          // Ukuran Font
          PopupMenuButton<double>(
            tooltip: 'Ukuran Font',
            icon: Icon(Icons.format_size, size: 20, color: _textSecondary),
            splashRadius: 20,
            initialValue: provider.fontScale,
            onSelected: provider.setFontScale,
            itemBuilder: (_) => [
              PopupMenuItem<double>(
                enabled: false,
                height: 32,
                child: Text('Ukuran Font', style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600, color: _textSecondary)),
              ),
              for (final opt in AppProvider.fontScaleOptions)
                PopupMenuItem<double>(
                  value: opt.$1,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: (provider.fontScale - opt.$1).abs() < 0.01
                            ? Icon(Icons.check, size: 16, color: isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7))
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(opt.$2, style: GoogleFonts.ibmPlexSans(fontSize: 13 * opt.$1)),
                      const SizedBox(width: 8),
                      Text('${(opt.$1 * 100).round()}%', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: _textSecondary)),
                    ],
                  ),
                ),
            ],
          ),

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
    final Color _canvasColor = isDark ? const Color(0xFF11171D) : const Color(0xFFF6F8FA);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final tabs = provider.openTabs;
    final scale = provider.fontScale > 1 ? provider.fontScale : 1.0;

    final children = <Widget>[];
    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final pinned = provider.isTabPinned(tab['id']!);
      // Garis pemisah antara grup tab yang di-pin dan tab biasa
      if (i > 0 && !pinned && provider.isTabPinned(tabs[i - 1]['id']!)) {
        children.add(Container(
          width: 1,
          margin: const EdgeInsets.only(left: 2, right: 6, top: 10, bottom: 6),
          color: _borderColor,
        ));
      }
      children.add(_TabChip(
        key: ValueKey('tab_${tab['id']}'),
        tab: tab,
        isActive: provider.activeModule == tab['id'],
        isPinned: pinned,
        isDark: isDark,
      ));
    }

    return Container(
      height: 40 * scale,
      decoration: BoxDecoration(
        color: _canvasColor,
        border: Border(
          bottom: BorderSide(color: _borderColor),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: children,
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

/// Satu tab di tab bar atas. Mendukung pin/unpin (tombol saat hover/aktif,
/// atau klik kanan untuk menu konteks) dan tombol tutup.
class _TabChip extends StatefulWidget {
  final Map<String, String> tab;
  final bool isActive;
  final bool isPinned;
  final bool isDark;

  const _TabChip({
    super.key,
    required this.tab,
    required this.isActive,
    required this.isPinned,
    required this.isDark,
  });

  @override
  State<_TabChip> createState() => _TabChipState();
}

class _TabChipState extends State<_TabChip> {
  bool _hover = false;

  Future<void> _showContextMenu(Offset globalPos) async {
    final provider = context.read<AppProvider>();
    final id = widget.tab['id']!;
    final closable = widget.tab['closable'] == 'true' && !widget.isPinned;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(globalPos & const Size(1, 1), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          value: 'pin',
          height: 36,
          child: Row(children: [
            Icon(widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined, size: 16),
            const SizedBox(width: 10),
            Text(widget.isPinned ? 'Lepas Pin Tab' : 'Pin Tab', style: GoogleFonts.ibmPlexSans(fontSize: 13)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'close',
          height: 36,
          enabled: closable,
          child: Text('Tutup', style: GoogleFonts.ibmPlexSans(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'others',
          height: 36,
          child: Text('Tutup Tab Lain', style: GoogleFonts.ibmPlexSans(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'right',
          height: 36,
          child: Text('Tutup Tab di Kanan', style: GoogleFonts.ibmPlexSans(fontSize: 13)),
        ),
      ],
    );
    switch (result) {
      case 'pin':
        provider.togglePinTab(id);
        break;
      case 'close':
        provider.closeTab(id);
        break;
      case 'others':
        provider.closeOtherTabs(id);
        break;
      case 'right':
        provider.closeTabsToRight(id);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isActive = widget.isActive;
    final isPinned = widget.isPinned;
    final provider = context.read<AppProvider>();
    final id = widget.tab['id']!;
    final isClosable = widget.tab['closable'] == 'true' && !isPinned;

    final Color baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color hoverColor = isDark ? const Color(0xFF1F2A33) : const Color(0xFFEDF1F4);
    final fg = isActive ? textPrimary : textSecondary;

    // Tombol pin terlihat saat tab di-pin, aktif, atau sedang di-hover
    final showPinBtn = isPinned || isActive || _hover;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => provider.switchModule(id),
        onSecondaryTapDown: (d) => _showContextMenu(d.globalPosition),
        onLongPressStart: (d) => _showContextMenu(d.globalPosition),
        // Klik tengah (mouse wheel) untuk tutup, seperti browser
        onTertiaryTapUp: isClosable ? (_) => provider.closeTab(id) : null,
        child: Container(
          margin: const EdgeInsets.only(right: 4, top: 4),
          padding: EdgeInsets.only(left: isPinned ? 10 : 14, right: 8),
          decoration: BoxDecoration(
            color: isActive ? baseColor : (_hover ? hoverColor : Colors.transparent),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            border: Border(
              top: BorderSide(color: isActive ? (isPinned ? primaryColor : borderColor) : Colors.transparent, width: isActive && isPinned ? 2 : 1),
              left: BorderSide(color: isActive ? borderColor : Colors.transparent),
              right: BorderSide(color: isActive ? borderColor : Colors.transparent),
              bottom: BorderSide(color: isActive ? baseColor : Colors.transparent, width: 2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPinned) ...[
                // Klik ikon pin untuk melepas pin
                _miniButton(
                  icon: Icons.push_pin,
                  color: primaryColor,
                  tooltip: 'Lepas pin',
                  onTap: () => provider.togglePinTab(id),
                ),
                const SizedBox(width: 2),
              ],
              Text(
                widget.tab['name']!,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
              ),
              if (!isPinned) ...[
                const SizedBox(width: 6),
                // Tombol pin (muncul saat hover / tab aktif)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: showPinBtn ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !showPinBtn,
                    child: _miniButton(
                      icon: Icons.push_pin_outlined,
                      color: fg,
                      tooltip: 'Pin tab',
                      onTap: () => provider.togglePinTab(id),
                    ),
                  ),
                ),
                if (isClosable)
                  _miniButton(
                    icon: Icons.close,
                    color: fg,
                    tooltip: 'Tutup tab',
                    onTap: () => provider.closeTab(id),
                  ),
              ] else
                const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
