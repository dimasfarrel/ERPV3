import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/erp_data_grid.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/transaction/transaction_payment_dialog.dart';
import '../../widgets/transaction/invoice_print_dialog.dart';

class PurchasingModule extends StatefulWidget {
  const PurchasingModule({super.key});

  @override
  State<PurchasingModule> createState() => _PurchasingModuleState();
}

class _PurchasingModuleState extends State<PurchasingModule> {
  String _activeTab = 'po'; // 'po', 'ap_aging'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    final pos = provider.purchaseOrders;
    final totalPo = pos.fold(0.0, (s, p) => s + p.amount);
    final totalHutang = provider.apAging.fold(0.0, (s, a) => s + a.remainingAmount);

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
                  Text(
                    'Pembelian & Hutang Vendor (P2P)',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Procure to pay, purchase order bahan baku pabrik, alokasi biaya ongkir COA, dan monitoring jatuh tempo AP',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, color: _textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => provider.openNewForm('purchasing'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Buat PO Pembelian'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 800;
              final card1 = _metricCard(
                'Total Nilai PO Diterbitkan',
                pos.length,
                Formatters.currency(totalPo),
                'Aktif',
                _primaryColor,
                Icons.assignment_outlined,
                isDark,
              );
              final card2 = _metricCard(
                'Hutang Usaha Supplier (AP)',
                provider.apAging.length,
                Formatters.currency(totalHutang),
                'Jatuh Tempo',
                isDark ? const Color(0xFFF0BD63) : const Color(0xFF9A6200),
                Icons.schedule_send_outlined,
                isDark,
              );
              final card3 = _metricCard(
                'PO Selesai Diterima',
                pos.where((p) => p.status == 'Selesai Diterima').length,
                'Lunas',
                'Masuk',
                isDark ? const Color(0xFF28A745) : const Color(0xFF087A65),
                Icons.inventory_2_outlined,
                isDark,
              );

              if (isSmall) {
                return Column(children: [card1, const SizedBox(height: 16), card2, const SizedBox(height: 16), card3]);
              }
              return Row(children: [
                Expanded(child: card1),
                const SizedBox(width: 16),
                Expanded(child: card2),
                const SizedBox(width: 16),
                Expanded(child: card3),
              ]);
            },
          ),
          const SizedBox(height: 24),

          // Tabs
          Row(
            children: [
              _buildTab('po', 'Purchase Order (PO)', Icons.shopping_bag_outlined, isDark),
              const SizedBox(width: 8),
              _buildTab('ap_aging', 'Aging Hutang Vendor (AP Aging)', Icons.hourglass_bottom_outlined, isDark),
            ],
          ),
          const SizedBox(height: 20),

          if (_activeTab == 'po') _buildPoTable(pos, isDark),
          if (_activeTab == 'ap_aging') _buildApAgingTable(provider, isDark),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label, IconData icon, bool isDark) {
    final active = _activeTab == id;
    
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _bgCard = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return GestureDetector(
      onTap: () => setState(() => _activeTab = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? _primaryColor : _bgCard,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? _primaryColor : _borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : _textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? Colors.white : _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, int count, String amount, String sub, Color color, IconData icon, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return ErpCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF25303A) : const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6)),
                ),
                child: Text(
                  '$count $sub',
                  style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600, color: _textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: GoogleFonts.ibmPlexSans(fontSize: 22, fontWeight: FontWeight.w700, color: _textPrimary, letterSpacing: -0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildPoTable(List<PurchaseOrder> pos, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);

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
                Flexible(child: Text('DAFTAR PESANAN PEMBELIAN (PURCHASE ORDER)', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary))),
                Text('${pos.length} Dokumen', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),
          ErpDataGrid<PurchaseOrder>(
            storageKey: 'purchasing_po',
            rows: pos,
            emptyText: 'Belum ada riwayat dokumen PO.',
            minTableWidth: 1000,
            columns: [
              ErpGridColumn(
                label: 'No. PO',
                flex: 1.4,
                filter: ErpFilterKind.text,
                value: (po) => po.id,
                cell: (_, po) => Text(po.id, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor)),
              ),
              ErpGridColumn(
                label: 'Tanggal',
                flex: 1.0,
                filter: ErpFilterKind.date,
                value: (po) => po.date,
                cell: (_, po) => Text(Formatters.dateShort(po.date)),
              ),
              ErpGridColumn(
                label: 'Pemasok / Vendor',
                flex: 1.8,
                filter: ErpFilterKind.text,
                value: (po) => po.vendor,
                cell: (_, po) => Text(po.vendor, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              ErpGridColumn(
                label: 'Gudang Tujuan',
                flex: 1.4,
                filter: ErpFilterKind.select,
                value: (po) => po.warehouse,
                cell: (_, po) => Text(po.warehouse, style: const TextStyle(fontSize: 12)),
              ),
              ErpGridColumn(
                label: 'Total Nilai PO',
                flex: 1.3,
                filter: ErpFilterKind.number,
                alignRight: true,
                value: (po) => po.amount,
                cell: (_, po) => Text(Formatters.currency(po.amount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600)),
              ),
              ErpGridColumn(
                label: 'Status',
                flex: 1.2,
                filter: ErpFilterKind.select,
                value: (po) => po.status,
                cell: (_, po) => StatusBadge(label: po.status, type: po.statusBadge),
              ),
              ErpGridColumn(
                label: 'Aksi',
                flex: 1.9,
                sortable: false,
                cell: (context, po) => _poActions(context, po),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _poActions(BuildContext context, PurchaseOrder po) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 16),
          onPressed: () => context.read<AppProvider>().openNewForm('purchasing', customTitle: 'Detail PO ${po.id}', targetId: po.id),
          tooltip: 'Lihat Detail',
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 16),
          onPressed: () => context.read<AppProvider>().openNewForm('purchasing', customTitle: 'Edit PO ${po.id}', targetId: po.id),
          tooltip: 'Edit',
        ),
        if (po.status != 'Lunas' && po.status != 'Draft') ...[
          IconButton(
            icon: const Icon(Icons.payment_rounded, size: 16, color: Color(0xFF28A745)),
            onPressed: () async {
              final result = await TransactionPaymentDialog.show(
                context,
                transactionId: po.id,
                totalAmount: po.amount,
                partnerName: po.vendor,
                isPurchase: true,
              );
              if (result != null && context.mounted) {
                final updatedPo = po.copyWith(
                  status: 'Lunas',
                  paymentMethod: result.paymentMethod,
                  paidAmount: result.paidAmount,
                  paymentDate: DateTime.now(),
                );
                final provider = context.read<AppProvider>();
                provider.addPurchaseOrder(updatedPo);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Pelunasan PO ${po.id} berhasil dicatat (Lunas).'),
                  backgroundColor: const Color(0xFF28A745),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            tooltip: 'Bayar / Pelunasan PO',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.print_outlined, size: 16),
          onPressed: () {
            InvoicePrintDialog.showFromPurchase(context, po: po);
          },
          tooltip: 'Cetak PO',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
          onPressed: () {
            context.read<AppProvider>().deletePurchaseOrder(po.id);
          },
          tooltip: 'Hapus',
        ),
      ]),
    );
  }

  Widget _buildApAgingTable(AppProvider provider, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);

    final Color _successColor = isDark ? const Color(0xFF28A745) : const Color(0xFF087A65);
    final Color _warningColor = isDark ? const Color(0xFFF0BD63) : const Color(0xFF9A6200);
    final Color _dangerColor = isDark ? const Color(0xFFE55353) : const Color(0xFFB3363B);

    Color toneOf(AccountsPayable ap) =>
        ap.status == 'Aman' ? _successColor : ap.status == 'Segera' ? _warningColor : _dangerColor;

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
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MONITORING AGING HUTANG (ACCOUNTS PAYABLE)', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                      const SizedBox(height: 4),
                      Text('Analisis umur hutang usaha berdasarkan tanggal jatuh tempo invoice vendor', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('Klasifikasi Umur', style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: _primaryColor)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),
          ErpDataGrid<AccountsPayable>(
            storageKey: 'purchasing_ap_aging',
            rows: provider.apAging,
            emptyText: 'Belum ada data hutang usaha (AP).',
            minTableWidth: 1100,
            columns: [
              ErpGridColumn(
                label: 'No. Ref Invoice',
                flex: 1.3,
                filter: ErpFilterKind.text,
                value: (ap) => ap.id,
                cell: (_, ap) => Text(ap.id, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor)),
              ),
              ErpGridColumn(
                label: 'Nama Vendor',
                flex: 1.7,
                filter: ErpFilterKind.text,
                value: (ap) => ap.supplier,
                cell: (_, ap) => Text(ap.supplier, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              ErpGridColumn(
                label: 'Tgl Jatuh Tempo',
                flex: 1.1,
                filter: ErpFilterKind.date,
                value: (ap) => ap.dueDate,
                cell: (_, ap) => Text(Formatters.dateShort(ap.dueDate)),
              ),
              ErpGridColumn(
                label: 'Total Tagihan',
                flex: 1.3,
                filter: ErpFilterKind.number,
                alignRight: true,
                value: (ap) => ap.totalAmount,
                cell: (_, ap) => Text(Formatters.currency(ap.totalAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500)),
              ),
              ErpGridColumn(
                label: 'Sisa Hutang',
                flex: 1.3,
                filter: ErpFilterKind.number,
                alignRight: true,
                value: (ap) => ap.remainingAmount,
                cell: (_, ap) => Text(Formatters.currency(ap.remainingAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _dangerColor)),
              ),
              ErpGridColumn(
                label: 'Kelompok Umur (Bucket)',
                flex: 1.4,
                filter: ErpFilterKind.select,
                value: (ap) => ap.agingBucket,
                cell: (_, ap) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: toneOf(ap).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ap.agingBucket,
                    style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: toneOf(ap)),
                  ),
                ),
              ),
              ErpGridColumn(
                label: 'Status',
                flex: 1.1,
                filter: ErpFilterKind.select,
                value: (ap) => ap.status,
                cell: (_, ap) => StatusBadge(
                  label: ap.status,
                  type: ap.status == 'Aman' ? 'success' : ap.status == 'Segera' ? 'warning' : 'danger',
                ),
              ),
              ErpGridColumn(
                label: 'Aksi Pelunasan',
                flex: 1.1,
                sortable: false,
                cell: (_, ap) => ap.status == 'Lunas'
                    ? Text('✓ Terbayar', style: GoogleFonts.ibmPlexSans(color: _successColor, fontWeight: FontWeight.w600))
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            ap.remainingAmount = 0;
                            ap.status = 'Lunas';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        child: const Text('Bayar'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
