import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/app_models.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';
import 'purchasing_form_screen.dart';

class PurchasingModule extends StatefulWidget {
  const PurchasingModule({super.key});
  @override State<PurchasingModule> createState() => _PurchasingModuleState();
}

class _PurchasingModuleState extends State<PurchasingModule> {
  String _activeTab = 'faktur';
  bool _showForm = false;
  final _tabs = ['Faktur', 'Tukar Faktur', 'Pengiriman', 'Pesanan', 'Penawaran', 'Permintaan', 'Persetujuan', 'Ditolak'];
  final _tabIds = ['faktur', 'tukar-faktur', 'pengiriman', 'pesanan', 'penawaran', 'permintaan', 'persetujuan', 'ditolak'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pembelian', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
          const SizedBox(height: 20),
          _buildMetricCards(provider),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () {}, child: const Text('Impor')),
            const SizedBox(width: 12),
            _buildDropdownButton(provider),
          ]),
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 16),
          _buildPoTable(provider),
        ],
      ),
    );
  }

  Widget _buildMetricCards(AppProvider provider) {
    double unpaid = 0;
    double paid = 0;
    for (var po in provider.purchaseOrders) {
      if (po.status == 'Menunggu Otorisasi') unpaid += po.amount;
      if (po.status == 'Selesai Diterima') paid += po.amount;
    }

    return Row(
      children: [
        Expanded(child: _metricCard('Faktur belum dibayar', 
          provider.purchaseOrders.where((i) => i.status == 'Menunggu Otorisasi').length, 
          Formatters.currency(unpaid), 'Total', const Color(0xFFF59E0B))),
        const SizedBox(width: 16),
        Expanded(child: _metricCard('Faktur telat dibayar', 0, 'Rp 0', 'Total', AppColors.danger)),
        const SizedBox(width: 16),
        Expanded(child: _metricCard('Pelunasan 30 hari terakhir', 
          provider.purchaseOrders.where((i) => i.status == 'Selesai Diterima').length, 
          Formatters.currency(paid), 'Total', AppColors.success)),
      ],
    );
  }

  Widget _buildDropdownButton(AppProvider provider) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => provider.openNewForm('purchasing', customTitle: 'Faktur Pembelian'),
          child: Text('Faktur pembelian', style: GoogleFonts.inter(fontSize: 13)),
        ),
        MenuItemButton(
          onPressed: () => provider.openNewForm('purchasing', customTitle: 'Tukar Faktur'),
          child: Text('Tukar faktur', style: GoogleFonts.inter(fontSize: 13)),
        ),
        MenuItemButton(
          onPressed: () => provider.openNewForm('purchasing', customTitle: 'Purchase Order (PO)'),
          child: Text('Purchase Order (PO)', style: GoogleFonts.inter(fontSize: 13)),
        ),
      ],
      builder: (context, controller, child) {
        return ElevatedButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('Buat pembelian baru', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.white),
          ]),
        );
      },
    );
  }

  Widget _metricCard(String title, int count, String amount, String sub, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 3, color: color),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.secondary))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                      child: Text('$count', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  Text(amount, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                  const SizedBox(height: 4),
                  Text(sub, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = _activeTab == _tabIds[i];
          return GestureDetector(
            onTap: () => setState(() => _activeTab = _tabIds[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight),
              ),
              child: Text(_tabs[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textMuted)),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPoTable(AppProvider provider) {
    if (provider.purchaseOrders.isEmpty) {
      return ErpCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: Column(children: [
              Icon(Icons.folder_open_rounded, size: 60, color: AppColors.primary.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text('Belum ada faktur pembelian', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary)),
              const SizedBox(height: 8),
              Text('Buat faktur baru melalui tombol "Buat pembelian baru"', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
            ]),
          ),
        ),
      );
    }

    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('DAFTAR PURCHASE ORDER', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.secondary, letterSpacing: 0.5)),
          ),
          const Divider(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              headingTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              dataTextStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary),
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('No PO')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Vendor')),
                DataColumn(label: Text('Gudang')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: provider.purchaseOrders.map((po) => DataRow(cells: [
                DataCell(Text(po.id, style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                DataCell(Text(Formatters.dateShort(po.date))),
                DataCell(Text(po.vendor, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(po.warehouse, style: const TextStyle(fontSize: 12))),
                DataCell(Text(Formatters.currency(po.amount), style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(StatusBadge(label: po.status, type: po.statusBadge)),
                DataCell(Row(children: [
                  IconButton(icon: const Icon(Icons.visibility_outlined, size: 16), onPressed: () {}, color: AppColors.textMuted),
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}, color: AppColors.textMuted),
                ])),
              ])).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePoDialog(BuildContext context) {
    final vendorCtrl = TextEditingController();
    final warehouseCtrl = TextEditingController(text: 'Gudang Utama Malang');
    final amountCtrl = TextEditingController();
    String status = 'Menunggu Otorisasi';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Purchase Order Baru', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
            ]),
            const Divider(height: 24),
            Text('Vendor', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: vendorCtrl, decoration: const InputDecoration(hintText: 'Nama vendor')),
            const SizedBox(height: 14),
            Text('Gudang', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: warehouseCtrl),
            const SizedBox(height: 14),
            Text('Total (Rp)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            Text('Status', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: status,
              decoration: const InputDecoration(),
              onChanged: (v) => setState(() => status = v!),
              items: const [
                DropdownMenuItem(value: 'Menunggu Otorisasi', child: Text('Menunggu Otorisasi')),
                DropdownMenuItem(value: 'Selesai Diterima', child: Text('Selesai Diterima')),
                DropdownMenuItem(value: 'Ditolak', child: Text('Ditolak')),
              ],
            ),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (vendorCtrl.text.isNotEmpty) {
                    final now = DateTime.now();
                    final po = PurchaseOrder(
                      id: 'PO-${now.year}-${(now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}',
                      date: now, vendor: vendorCtrl.text, warehouse: warehouseCtrl.text,
                      amount: double.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                      status: status,
                    );
                    context.read<AppProvider>().addPurchaseOrder(po);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Simpan PO'),
              ),
            ]),
          ]),
        ),
      )),
    );
  }
}
