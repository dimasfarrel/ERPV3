import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/status_badge.dart';

class InventoryModule extends StatefulWidget {
  const InventoryModule({super.key});

  @override
  State<InventoryModule> createState() => _InventoryModuleState();
}

class _InventoryModuleState extends State<InventoryModule> {
  String _activeTab = 'catalog'; // 'catalog', 'transfer', 'safety_alert'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final totalSkus = provider.inventoryItems.length;
    final totalUnits = provider.inventoryItems.fold(0, (s, i) => s + i.stockAvailable);
    final totalValuation = provider.inventoryItems.fold(0.0, (s, i) => s + (i.stockAvailable * i.unitPrice));
    final lowStockCount = provider.inventoryItems.where((i) => i.stockAvailable < i.stockMin).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Gudang & Inventori Stok',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitoring stok real-time, surat jalan mutasi antar gudang, dan peringatan batas minimum (safety stock)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTransferDialog(context, provider),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Mutasi Antar Gudang'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 800;
              final card1 = KpiCard(
                title: 'Total Valuasi Aset Stok',
                value: Formatters.compactCurrency(totalValuation),
                trend: '$totalUnits Unit',
                trendLabel: '$totalSkus Master SKU',
                trendUp: true,
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.success,
              );
              final card2 = KpiCard(
                title: 'Surat Jalan Mutasi Aktif',
                value: '${provider.stockTransfers.length} Mutasi',
                trend: 'Multi-Gudang',
                trendLabel: 'Plant A & Cabang',
                trendUp: true,
                icon: Icons.local_shipping_outlined,
                iconColor: AppColors.primary,
              );
              final card3 = KpiCard(
                title: 'Peringatan Safety Stock',
                value: '$lowStockCount SKU Kritis',
                trend: 'Perlu PO Restock',
                trendLabel: 'Segera Terbitkan PO',
                trendUp: false,
                icon: Icons.warning_amber_outlined,
                iconColor: AppColors.warning,
              );

              if (isSmall) {
                return Column(
                  children: [card1, const SizedBox(height: 12), card2, const SizedBox(height: 12), card3],
                );
              }
              return Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 16),
                  Expanded(child: card2),
                  const SizedBox(width: 16),
                  Expanded(child: card3),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Tabs
          Row(
            children: [
              _buildTab('catalog', 'Katalog SKU & Stok Gudang', Icons.inventory_outlined),
              const SizedBox(width: 8),
              _buildTab('transfer', 'Surat Jalan Mutasi Antar Gudang', Icons.swap_horiz_outlined),
              const SizedBox(width: 8),
              _buildTab('safety_alert', 'Peringatan Safety Stock Menipis', Icons.notification_important_outlined),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          if (_activeTab == 'catalog') _buildCatalogView(provider),
          if (_activeTab == 'transfer') _buildTransferView(provider),
          if (_activeTab == 'safety_alert') _buildSafetyAlertView(provider),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    final active = _activeTab == id;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogView(AppProvider provider) {
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Katalog SKU & Ketersediaan Stok Fisik', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Gudang Aktif: ${provider.selectedWarehouse?.name ?? "Gudang Utama"}', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Divider(height: 1),
          provider.inventoryItems.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Katalog SKU kosong. Belum ada master data barang.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('Kode SKU')),
                DataColumn(label: Text('Nama Produk / Komponen')),
                DataColumn(label: Text('Kategori')),
                DataColumn(label: Text('Stok Fisik')),
                DataColumn(label: Text('Batas Minimum')),
                DataColumn(label: Text('Harga Pokok (HPP)')),
                DataColumn(label: Text('Harga Jual')),
                DataColumn(label: Text('Status Stok')),
              ],
              rows: provider.inventoryItems.map((item) {
                return DataRow(cells: [
                  DataCell(Text(item.sku, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(item.category)),
                  DataCell(Text('${item.stockAvailable} ${item.unit}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700))),
                  DataCell(Text('${item.stockMin} ${item.unit}')),
                  DataCell(Text(Formatters.currency(item.costPrice))),
                  DataCell(Text(Formatters.currency(item.unitPrice), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600))),
                  DataCell(StatusBadge(label: item.stockStatus, type: item.stockBadge)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferView(AppProvider provider) {
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text('Surat Jalan Mutasi Perpindahan Barang Antar Gudang', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          provider.stockTransfers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Belum ada riwayat surat jalan mutasi.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('No. Surat Jalan')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Gudang Asal')),
                DataColumn(label: Text('Gudang Tujuan')),
                DataColumn(label: Text('Barang Dimutasi')),
                DataColumn(label: Text('Jumlah')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Keterangan')),
              ],
              rows: provider.stockTransfers.map((t) {
                return DataRow(cells: [
                  DataCell(Text(t.transferNo, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(Formatters.dateShort(t.date))),
                  DataCell(Text(t.sourceWarehouse)),
                  DataCell(Text(t.destWarehouse, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(t.sku, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  DataCell(Text('${t.quantity} ${t.unit}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700))),
                  DataCell(StatusBadge(label: t.status, type: t.status == 'Selesai' ? 'success' : 'info')),
                  DataCell(Text(t.notes)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyAlertView(AppProvider provider) {
    final alerts = provider.inventoryItems.where((i) => i.stockAvailable < i.stockMin).toList();

    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daftar Produk Menipis di Bawah Safety Stock Level', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.dangerSurface, borderRadius: BorderRadius.circular(6)),
                  child: Text('${alerts.length} SKU Butuh Reorder Segera', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          alerts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Stok aman. Tidak ada peringatan safety stock.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('Kode SKU')),
                DataColumn(label: Text('Nama Komponen')),
                DataColumn(label: Text('Sisa Stok Fisik')),
                DataColumn(label: Text('Batas Minimum')),
                DataColumn(label: Text('Kebutuhan PO')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Aksi Pembelian')),
              ],
              rows: alerts.map((a) {
                final def = a.stockMin - a.stockAvailable;
                return DataRow(cells: [
                  DataCell(Text(a.sku, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger))),
                  DataCell(Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text('${a.stockAvailable} ${a.unit}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800, color: AppColors.danger))),
                  DataCell(Text('${a.stockMin} ${a.unit}')),
                  DataCell(Text('+$def ${a.unit}', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(StatusBadge(label: a.stockStatus, type: 'danger')),
                  DataCell(
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.openNewForm('purchasing', customTitle: 'PO Bahan: ${a.sku}');
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 14),
                      label: const Text('Buat PO'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransferDialog(BuildContext context, AppProvider provider) {
    if (provider.inventoryItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Katalog SKU kosong! Tambahkan produk master terlebih dahulu.')));
      return;
    }
    String source = 'Gudang Bahan Baku & Komponen';
    String dest = 'Gudang Display Toko / Lite POS';
    String selectedSku = provider.inventoryItems.first.sku;
    final qtyCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text('Buat Surat Jalan Mutasi Antar Gudang', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: source,
                  items: const [
                    DropdownMenuItem(value: 'Gudang Bahan Baku & Komponen', child: Text('Gudang Bahan Baku & Komponen')),
                    DropdownMenuItem(value: 'Gudang Barang Jadi (Finished Goods)', child: Text('Gudang Barang Jadi (Finished Goods)')),
                  ],
                  onChanged: (v) => setDlgState(() => source = v!),
                  decoration: const InputDecoration(labelText: 'Gudang Asal Pengirim'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: dest,
                  items: const [
                    DropdownMenuItem(value: 'Gudang Display Toko / Lite POS', child: Text('Gudang Display Toko / Lite POS')),
                    DropdownMenuItem(value: 'Gudang Transit Plant B', child: Text('Gudang Transit Plant B')),
                  ],
                  onChanged: (v) => setDlgState(() => dest = v!),
                  decoration: const InputDecoration(labelText: 'Gudang Tujuan Penerima'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedSku,
                  items: provider.inventoryItems.map((i) => DropdownMenuItem(value: i.sku, child: Text('${i.sku} - ${i.name}'))).toList(),
                  onChanged: (v) => setDlgState(() => selectedSku = v!),
                  decoration: const InputDecoration(labelText: 'Pilih Barang'),
                ),
                const SizedBox(height: 10),
                TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Unit Dimutasi')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text) ?? 10;
                final prod = provider.inventoryItems.firstWhere((i) => i.sku == selectedSku);
                final newTransfer = StockTransfer(
                  id: 'tr-${DateTime.now().millisecondsSinceEpoch}',
                  transferNo: 'TR-2026-00${provider.stockTransfers.length + 14}',
                  date: DateTime.now(),
                  sourceWarehouse: source,
                  destWarehouse: dest,
                  sku: prod.sku,
                  productName: prod.name,
                  quantity: qty,
                  unit: prod.unit,
                  status: 'Dalam Perjalanan',
                  notes: 'Mutasi transfer armada logistik internal',
                );
                provider.createStockTransfer(newTransfer);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Surat jalan mutasi ${newTransfer.transferNo} berhasil diterbitkan!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Terbitkan Mutasi'),
            ),
          ],
        ),
      ),
    );
  }
}
