import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/status_badge.dart';

class LiteErpScreen extends StatefulWidget {
  const LiteErpScreen({super.key});

  @override
  State<LiteErpScreen> createState() => _LiteErpScreenState();
}

class _LiteErpScreenState extends State<LiteErpScreen> {
  int _activeNavIndex = 1; // 0: Home, 1: POS, 2: Stok, 3: Kas Laci, 4: Bon/Tempo
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _customerName = '';
  String _customerPhone = '';
  String _paymentMethod = 'Tunai'; // 'Tunai', 'QRIS', 'Transfer', 'Tempo'
  double _cashGiven = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: provider.isDarkMode ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildLiteTopBar(context, provider, isMobile),
            Expanded(
              child: _buildCurrentTab(context, provider, isMobile),
            ),
            _buildBottomNav(context, provider),
          ],
        ),
      ),
    );
  }

  // ==================== LITE TOPBAR ====================
  Widget _buildLiteTopBar(BuildContext context, AppProvider provider, bool isMobile) {
    final isDark = provider.isDarkMode;
    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _dangerColor = isDark ? const Color(0xFFFF8F91) : const Color(0xFFB3363B);
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _baseColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, color: _textPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'NEXUS LITE',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Store / Warehouse Context
          if (!isMobile)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront_outlined, size: 16, color: _textSecondary),
                const SizedBox(width: 8),
                Text(
                  provider.selectedWarehouse?.name ?? 'Cabang Ritel',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          const Spacer(),
          // Mode Switcher: UPGRADE PRO
          TextButton.icon(
            onPressed: () => provider.toggleEdition(),
            icon: Icon(Icons.explore_outlined, size: 16, color: _textPrimary),
            label: Text(
              isMobile ? 'PRO' : 'Buka Back-Office (Pro)',
              style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(width: 8),
          // Dark/Light Theme toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode_outlined,
              size: 20,
              color: _textSecondary,
            ),
            onPressed: () => provider.setThemeMode(!isDark),
            tooltip: 'Ganti Tema',
            splashRadius: 20,
          ),
          // Logout button
          IconButton(
            icon: Icon(Icons.logout, size: 20, color: _dangerColor),
            onPressed: () => provider.logout(),
            tooltip: 'Keluar',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM / TAB NAV ====================
  Widget _buildBottomNav(BuildContext context, AppProvider provider) {
    final isDark = provider.isDarkMode;
    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _actionPrimary = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    final navItems = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Beranda'},
      {'icon': Icons.point_of_sale_outlined, 'activeIcon': Icons.point_of_sale, 'label': 'Kasir POS'},
      {'icon': Icons.inventory_2_outlined, 'activeIcon': Icons.inventory_2, 'label': 'Stok Toko'},
      {'icon': Icons.account_balance_wallet_outlined, 'activeIcon': Icons.account_balance_wallet, 'label': 'Kas Laci'},
      {'icon': Icons.receipt_long_outlined, 'activeIcon': Icons.receipt_long, 'label': 'Tempo'},
    ];

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: _baseColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = _activeNavIndex == index;
          final item = navItems[index];

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeNavIndex = index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? (item['activeIcon'] as IconData) : (item['icon'] as IconData),
                    color: isSelected ? _actionPrimary : _textSecondary,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? _actionPrimary : _textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==================== TAB CONTENT ROUTER ====================
  Widget _buildCurrentTab(BuildContext context, AppProvider provider, bool isMobile) {
    switch (_activeNavIndex) {
      case 0:
        return _buildHomeTab(context, provider);
      case 1:
        return _buildPosTab(context, provider, isMobile);
      case 2:
        return _buildInventoryTab(context, provider);
      case 3:
        return _buildCashbookTab(context, provider);
      case 4:
        return _buildDebtsTab(context, provider);
      default:
        return _buildPosTab(context, provider, isMobile);
    }
  }

  // ==================== TAB 0: HOME / RINGKASAN TOKO ====================
  Widget _buildHomeTab(BuildContext context, AppProvider provider) {
    final todayInvoices = provider.salesInvoices;
    final totalOmset = todayInvoices.fold(0.0, (s, i) => s + i.amount);
    final lowStock = provider.inventoryItems.where((i) => i.stockAvailable < i.stockMin).length;

    final isDark = provider.isDarkMode;
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _actionPrimary = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _actionOnPrimary = isDark ? const Color(0xFF101820) : const Color(0xFFFFFFFF);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean Hero Section (Beranda Lite)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.end,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat pagi, ${provider.username.split(' ').first}',
                    style: GoogleFonts.ibmPlexSans(fontSize: 24, fontWeight: FontWeight.w600, color: _textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lowStock > 0 ? '$lowStock barang perlu restock segera' : 'Semua stok operasional aman',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, color: _textSecondary),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      provider.selectedWarehouse?.name ?? 'Cabang Ritel',
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _activeNavIndex = 1),
                    icon: const Icon(Icons.point_of_sale, size: 16),
                    label: const Text('Buka Kasir POS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _actionPrimary,
                      foregroundColor: _actionOnPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: _borderColor, height: 1),
          const SizedBox(height: 24),

          // 4 Metric Cards
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width < 700 ? 1 : (MediaQuery.of(context).size.width < 1100 ? 2 : 4),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8,
            children: [
              _metricTile('Total Omset Penjualan', Formatters.compactCurrency(totalOmset), isDark),
              _metricTile('Total Transaksi', '${todayInvoices.length} Nota', isDark),
              _metricTile('Uang di Laci Kasir', Formatters.compactCurrency(provider.liteCashBalance), isDark),
              _metricTile('Stok Perlu Restock', '$lowStock SKU', isDark),
            ],
          ),
          const SizedBox(height: 32),

          // Shortcut Actions
          Text('Tugas Prioritas Kasir', style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              return Flex(
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                children: [
                  Expanded(
                    flex: isSmall ? 0 : 1,
                    child: _actionCard(
                      'Catat Kas Masuk / Keluar',
                      'Modal awal kasir, uang kembalian, atau beli operasional',
                      Icons.price_change_outlined,
                      isDark,
                      () => setState(() => _activeNavIndex = 3),
                    ),
                  ),
                  SizedBox(width: isSmall ? 0 : 16, height: isSmall ? 16 : 0),
                  Expanded(
                    flex: isSmall ? 0 : 1,
                    child: _actionCard(
                      'Pelunasan Bon Pelanggan',
                      '${provider.liteDebts.where((d) => d.status == 'Belum Lunas').length} transaksi tempo siap ditagih dan dilunasi',
                      Icons.menu_book_outlined,
                      isDark,
                      () => setState(() => _activeNavIndex = 4),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, bool isDark) {
    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _baseColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 24, 
              fontWeight: FontWeight.w600, 
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String title, String desc, IconData icon, bool isDark, VoidCallback onTap) {
    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _baseColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: _textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: _textSecondary),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 1: POS KASIR LAYAR SENTUH ====================
  Widget _buildPosTab(BuildContext context, AppProvider provider, bool isMobile) {
    final categories = ['Semua', 'Barang Jadi', 'Komponen Elektronik', 'Bahan Baku'];
    final filtered = provider.inventoryItems.where((p) {
      final matchCat = _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Row(
      children: [
        // Left Area: Product Catalog
        Expanded(
          flex: 6,
          child: Column(
            children: [
              // Search & Category Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: AppColors.bgCard,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari barang kasir atau scan barcode SKU...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF0EA5E9)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Scanner Barcode siap membaca kode produk!'), backgroundColor: Color(0xFF0EA5E9)),
                            );
                          },
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isCatActive = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isCatActive,
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                              backgroundColor: AppColors.bgCard,
                              selectedColor: AppColors.accentSkySurface,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: isCatActive ? FontWeight.w700 : FontWeight.w500,
                                color: isCatActive ? const Color(0xFF0369A1) : AppColors.secondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Products Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : 3,
                    childAspectRatio: 1.15,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, idx) {
                    final item = filtered[idx];
                    final inCart = provider.liteCart.any((c) => c.product.sku == item.sku);

                    return InkWell(
                      onTap: () {
                        if (item.stockAvailable > 0) {
                          provider.addToLiteCart(item);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Stok habis! Silakan lakukan restock gudang.'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: inCart ? (provider.isDarkMode ? const Color(0xFF0C4A6E) : const Color(0xFFF0F9FF)) : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: inCart ? AppColors.accentSky : AppColors.borderLight,
                            width: inCart ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.sku, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentSky)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: (item.stockAvailable > 0 ? AppColors.success : AppColors.danger).withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${item.stockAvailable} ${item.unit}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: item.stockAvailable > 0 ? AppColors.success : AppColors.danger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item.name,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  Formatters.currency(item.unitPrice),
                                  style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.secondary),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: AppColors.accentSky, shape: BoxShape.circle),
                                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Right Area: Shopping Cart & Checkout
        Container(
          width: isMobile ? 320 : 380,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            border: Border(left: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            children: [
              // Cart Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Keranjang Kasir (${provider.liteCart.length})',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (provider.liteCart.isNotEmpty)
                      GestureDetector(
                        onTap: () => provider.clearLiteCart(),
                        child: Text('Kosongkan', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),

              // Cart Items List
              Expanded(
                child: provider.liteCart.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_shopping_cart, size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('Keranjang masih kosong', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            Text('Sentuh produk di sebelah kiri untuk menambah', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: provider.liteCart.length,
                        separatorBuilder: (_, __) => const Divider(height: 12),
                        itemBuilder: (ctx, idx) {
                          final item = provider.liteCart[idx];
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1),
                                    Text(Formatters.currency(item.product.unitPrice), style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                              // Qty modifier
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                                    onPressed: () => provider.removeFromLiteCart(item.product),
                                    color: Colors.grey,
                                  ),
                                  Text('${item.quantity}', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 18),
                                    onPressed: () => provider.addToLiteCart(item.product),
                                    color: AppColors.accentSky,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  Formatters.currency(item.subtotal),
                                  style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),

              // Checkout Box
              if (provider.liteCart.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgApp,
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Column(
                    children: [
                      // Subtotal row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Belanja:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(
                            Formatters.currency(provider.liteCartSubtotal),
                            style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accentSky),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Payment Method Selector
                      Row(
                        children: [
                          _payChip('Tunai', Icons.attach_money),
                          const SizedBox(width: 4),
                          _payChip('QRIS', Icons.qr_code_2),
                          const SizedBox(width: 4),
                          _payChip('Transfer', Icons.credit_card),
                          const SizedBox(width: 4),
                          _payChip('Tempo', Icons.timer_outlined),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () => _openCheckoutDialog(context, provider),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('PROSES BAYAR (SELESAI)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentSky,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _payChip(String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentSky : AppColors.bgCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? AppColors.accentSky : AppColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textMuted),
              const SizedBox(height: 2),
              Text(
                method,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCheckoutDialog(BuildContext context, AppProvider provider) {
    final total = provider.liteCartSubtotal;
    _cashGiven = total; // default uang pas

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final change = _cashGiven - total;

            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.point_of_sale, color: AppColors.accentSky),
                  const SizedBox(width: 8),
                  Text('Selesaikan Pembayaran Nota', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total yang Harus Dibayar:'),
                          Text(Formatters.currency(total), style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Nama Pelanggan (Opsional)', hintText: 'Contoh: Pak Joko / Umum'),
                      onChanged: (v) => _customerName = v,
                    ),
                    if (_paymentMethod == 'Tempo') ...[
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(labelText: 'No. Handphone / WA Pelanggan', hintText: '0812-xxxx-xxxx'),
                        onChanged: (v) => _customerPhone = v,
                      ),
                    ],
                    if (_paymentMethod == 'Tunai') ...[
                      const SizedBox(height: 14),
                      Text('Uang Diterima dari Pelanggan:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          _cashQuickChip('Uang Pas', total, setModalState),
                          _cashQuickChip('50.000', 50000, setModalState),
                          _cashQuickChip('100.000', 100000, setModalState),
                          _cashQuickChip('200.000', 200000, setModalState),
                          _cashQuickChip('500.000', 500000, setModalState),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: change >= 0 ? AppColors.successSurface : AppColors.dangerSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(change >= 0 ? 'Uang Kembalian:' : 'Kurang Bayar:', style: TextStyle(fontWeight: FontWeight.w600, color: change >= 0 ? AppColors.success : AppColors.danger)),
                            Text(
                              Formatters.currency(change.abs()),
                              style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w800, color: change >= 0 ? AppColors.success : AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.processLiteCheckout(
                      customerName: _customerName,
                      customerPhone: _customerPhone,
                      paymentMethod: _paymentMethod,
                      cashGiven: _cashGiven,
                    );
                    Navigator.pop(ctx);
                    _showReceiptDialog(context, total, _paymentMethod);
                  },
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('Bayar & Cetak Struk'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSky),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _cashQuickChip(String label, double val, StateSetter setModalState) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        setModalState(() => _cashGiven = val);
      },
    );
  }

  void _showReceiptDialog(BuildContext context, double total, String method) {
    final now = DateTime.now();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
              const SizedBox(height: 8),
              Text('TRANSAKSI BERHASIL', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800)),
              Text('Struk Kasir Thermal Siap Dicetak', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey)),
              const Divider(height: 24),
              Text('NEXUS LITE POS TOKO', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700)),
              Text('Jl. Ritel Malang No. 45 • Cabang 01', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(Formatters.date(now), style: GoogleFonts.jetBrainsMono(fontSize: 10)),
              const Divider(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Metode Bayar:'),
                Text(method, style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total Nota:'),
                Text(Formatters.currency(total), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800, color: AppColors.success)),
              ]),
              const Divider(height: 20),
              const Text('*** TERIMA KASIH ATAS KUNJUNGAN ANDA ***', style: TextStyle(fontSize: 9, letterSpacing: 0.5)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentSky),
            child: const Text('Selesai & Tutup'),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: STOK TOKO CEPAT ====================
  Widget _buildInventoryTab(BuildContext context, AppProvider provider) {
    final isDark = provider.isDarkMode;
    final Color _baseColor = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _subtleColor = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _actionPrimary = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _actionOnPrimary = isDark ? const Color(0xFF101820) : const Color(0xFFFFFFFF);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Katalog Stok Fisik Toko', style: GoogleFonts.ibmPlexSans(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary)),
                  const SizedBox(height: 4),
                  Text('Pantau ketersediaan barang di toko tanpa form akuntansi rumit', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showQuickAddProductDialog(context, provider),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah Barang Cepat'), // fixed double plus
                style: ElevatedButton.styleFrom(
                  backgroundColor: _actionPrimary,
                  foregroundColor: _actionOnPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity, // fixed "gk full"
            decoration: BoxDecoration(color: _baseColor, borderRadius: BorderRadius.circular(6), border: Border.all(color: _borderColor)),
            child: provider.inventoryItems.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('Data stok masih kosong atau belum dimuat dari server.', style: GoogleFonts.ibmPlexSans(color: _textSecondary)),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48), // Ensure it expands
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(_subtleColor),
                        headingTextStyle: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary),
                        dataTextStyle: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
                        columns: const [
                          DataColumn(label: Text('Kode SKU')),
                          DataColumn(label: Text('Nama Produk Toko')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Harga Jual')),
                          DataColumn(label: Text('Sisa Stok')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: provider.inventoryItems.map((p) => DataRow(cells: [
                          DataCell(Text(p.sku, style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _actionPrimary))),
                          DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(p.category)),
                          DataCell(Text(Formatters.currency(p.unitPrice), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500))),
                          DataCell(Text('${p.stockAvailable} ${p.unit}', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500))),
                          DataCell(StatusBadge(label: p.stockStatus, type: p.stockBadge)),
                        ])).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showQuickAddProductDialog(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Produk Cepat ke Toko', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk')),
            const SizedBox(height: 10),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Jual (Rp)')),
            const SizedBox(height: 10),
            TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok Awal')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              final newItem = InventoryItem(
                sku: 'TK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                name: nameCtrl.text,
                category: 'Barang Jadi',
                stockAvailable: int.tryParse(stockCtrl.text) ?? 10,
                stockMin: 5,
                unitPrice: double.tryParse(priceCtrl.text) ?? 50000,
                unit: 'Unit',
                warehouse: 'Gudang Display Toko',
              );
              provider.addInventoryItem(newItem);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: BUKU KAS LACI KASIR ====================
  Widget _buildCashbookTab(BuildContext context, AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buku Kas Kecil Laci Toko', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Catat kas masuk (modal/setoran) dan kas keluar operasional harian kasir', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCashDialog(context, provider),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Catat Kas Masuk/Keluar'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Cash balance banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Saldo Kas di Laci Toko Saat Ini:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.currency(provider.liteCashBalance),
                      style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w800, color: provider.isDarkMode ? AppColors.accentSky : const Color(0xFF0369A1)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: provider.isDarkMode ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.savings_outlined, color: provider.isDarkMode ? AppColors.accentSky : const Color(0xFF0284C7), size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
            child: provider.liteCashTransactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada catatan kas laci.', style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 40),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
                        columns: const [
                          DataColumn(label: Text('Tipe Kas')),
                          DataColumn(label: Text('Kategori')),
                          DataColumn(label: Text('Keterangan Catatan')),
                          DataColumn(label: Text('Nominal')),
                          DataColumn(label: Text('Tanggal')),
                        ],
                        rows: provider.liteCashTransactions.map((c) {
                          final isIn = c.type == 'in';
                          return DataRow(cells: [
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isIn ? AppColors.success : AppColors.danger).withAlpha(25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isIn ? 'KAS MASUK' : 'KAS KELUAR',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isIn ? AppColors.success : AppColors.danger),
                                ),
                              ),
                            ),
                            DataCell(Text(c.category, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(c.note)),
                            DataCell(
                              Text(
                                '${isIn ? '+' : '-'}${Formatters.currency(c.amount)}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.w700,
                                  color: isIn ? AppColors.success : AppColors.danger,
                                ),
                              ),
                            ),
                            DataCell(Text(Formatters.dateShort(c.date))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddCashDialog(BuildContext context, AppProvider provider) {
    String type = 'out';
    final catCtrl = TextEditingController(text: 'Operasional');
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('Catat Kas Masuk / Keluar', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Kas Masuk (+)'),
                      selected: type == 'in',
                      onSelected: (_) => setDlgState(() => type = 'in'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Kas Keluar (-)'),
                      selected: type == 'out',
                      onSelected: (_) => setDlgState(() => type = 'out'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Kategori (contoh: Makan Staf, Beli Lakban)')),
              const SizedBox(height: 10),
              TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal Kas (Rp)')),
              const SizedBox(height: 10),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Keterangan Tambahan')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtCtrl.text);
                if (amt != null && amt > 0) {
                  provider.addLiteCashTransaction(type, catCtrl.text, amt, noteCtrl.text);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 4: CATATAN BON / TEMPO ====================
  Widget _buildDebtsTab(BuildContext context, AppProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catatan Piutang & Bon Tempo Toko', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Daftar pelanggan yang berhutang/tempo di toko dan tombol pelunasan instan', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
            child: provider.liteDebts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada catatan bon tempo pelanggan.', style: GoogleFonts.plusJakartaSans(color: AppColors.textMuted)),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 40),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
                        columns: const [
                          DataColumn(label: Text('No. Nota')),
                          DataColumn(label: Text('Pelanggan Bon Toko')),
                          DataColumn(label: Text('No. Kontak HP')),
                          DataColumn(label: Text('Nominal Bon')),
                          DataColumn(label: Text('Jatuh Tempo')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Aksi Pelunasan')),
                        ],
                        rows: provider.liteDebts.map((d) {
                          final isPaid = d.status == 'Lunas';
                          return DataRow(cells: [
                            DataCell(Text(d.orderNo, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700))),
                            DataCell(Text(d.customerName, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(d.phone, style: GoogleFonts.jetBrainsMono(fontSize: 11))),
                            DataCell(Text(Formatters.currency(d.amount), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, color: isPaid ? AppColors.success : AppColors.danger))),
                            DataCell(Text(Formatters.dateShort(d.dueDate))),
                            DataCell(StatusBadge(label: d.status, type: isPaid ? 'success' : 'warning')),
                            DataCell(
                              isPaid
                                  ? const Text('✓ Lunas Terbayar', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600))
                                  : ElevatedButton.icon(
                                      onPressed: () {
                                        provider.settleLiteDebt(d.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Bon ${d.customerName} sebesar ${Formatters.currency(d.amount)} berhasil dilunasi dan masuk ke laci kas!'), backgroundColor: AppColors.success),
                                        );
                                      },
                                      icon: const Icon(Icons.check, size: 14),
                                      label: const Text('Lunasi Bon'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                    ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
