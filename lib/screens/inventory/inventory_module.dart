import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';

class InventoryModule extends StatelessWidget {
  const InventoryModule({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Manajemen Inventori & Stok Fisik', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
            Text('Monitoring stok real-time, mutasi barang antar gudang, dan level restock minimum',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          ]),
        ]),
        const SizedBox(height: 20),
        ErpCard(
          padding: EdgeInsets.zero,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Katalog SKU & Ketersediaan Stok', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                Text('Gudang Aktif: Kepanjen', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
              ]),
            ),
            const Divider(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
                headingTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                dataTextStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary),
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Kode SKU')),
                  DataColumn(label: Text('Nama Barang')),
                  DataColumn(label: Text('Kategori')),
                  DataColumn(label: Text('Stok Tersedia')),
                  DataColumn(label: Text('Stok Minimum')),
                  DataColumn(label: Text('Nilai Satuan')),
                  DataColumn(label: Text('Status Stok')),
                ],
                rows: provider.inventoryItems.map((item) => DataRow(cells: [
                  DataCell(Text(item.sku, style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(item.category)),
                  DataCell(Text('${item.stockAvailable} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.w700))),
                  DataCell(Text('${item.stockMin} ${item.unit}')),
                  DataCell(Text(Formatters.currency(item.unitPrice))),
                  DataCell(StatusBadge(label: item.stockStatus, type: item.stockBadge)),
                ])).toList(),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
