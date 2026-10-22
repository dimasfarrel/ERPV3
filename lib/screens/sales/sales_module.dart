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

class SalesModule extends StatefulWidget {
  const SalesModule({super.key});

  @override
  State<SalesModule> createState() => _SalesModuleState();
}

class _SalesModuleState extends State<SalesModule> {
  String _activeTab = 'faktur'; // 'faktur', 'ar_aging', 'penawaran'
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final _tabs = [
    {'id': 'faktur', 'name': 'Faktur Penjualan', 'icon': Icons.receipt_outlined},
    {'id': 'ar_aging', 'name': 'Aging Piutang (AR Aging)', 'icon': Icons.hourglass_top_outlined},
    {'id': 'tukar-faktur', 'name': 'Tukar Faktur', 'icon': Icons.compare_arrows_outlined},
    {'id': 'pengiriman', 'name': 'Pengiriman', 'icon': Icons.local_shipping_outlined},
    {'id': 'penawaran', 'name': 'Penawaran', 'icon': Icons.local_offer_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    // Pencarian global; filter detail (status, tanggal, nominal, dll) ada di header tiap kolom tabel
    final invoices = provider.salesInvoices.where((inv) {
      final matchSearch = _searchQuery.isEmpty ||
          inv.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.customer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSearch;
    }).toList();

    final unpaid = provider.salesInvoices.where((i) => i.status == 'Belum Bayar').fold(0.0, (s, i) => s + i.amount);
    final due = provider.salesInvoices.where((i) => i.status == 'Jatuh Tempo').fold(0.0, (s, i) => s + i.amount);
    final paid = provider.salesInvoices.where((i) => i.status == 'Lunas').fold(0.0, (s, i) => s + i.amount);
    final totalPiutang = provider.arAging.fold(0.0, (s, a) => s + a.remainingAmount);

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
                    'Penjualan & Piutang Dagang (O2C)',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Order to cash, faktur penjualan PPN 11%, monitoring aging piutang pelanggan, dan pencatatan pembayaran',
                    style: GoogleFonts.ibmPlexSans(fontSize: 14, color: _textSecondary),
                  ),
                ],
              ),
              _buildDropdownButton(provider, isDark),
            ],
          ),
          const SizedBox(height: 24),

          // Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 800;
              final card1 = _metricCard(
                'Belum Dibayar',
                provider.salesInvoices.where((i) => i.status == 'Belum Bayar').length,
                Formatters.currency(unpaid),
                'Aktif',
                isDark ? const Color(0xFFF0BD63) : const Color(0xFF9A6200),
                Icons.schedule_outlined,
                isDark,
              );
              final card2 = _metricCard(
                'Jatuh Tempo',
                provider.salesInvoices.where((i) => i.status == 'Jatuh Tempo').length,
                Formatters.currency(due),
                'Lewat Batas',
                isDark ? const Color(0xFFE55353) : const Color(0xFFB3363B),
                Icons.warning_amber_outlined,
                isDark,
              );
              final card3 = _metricCard(
                'Total Piutang Berjalan',
                provider.arAging.length,
                Formatters.currency(totalPiutang),
                'Pelanggan',
                isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7),
                Icons.account_balance_wallet_outlined,
                isDark,
              );
              final card4 = _metricCard(
                'Sudah Lunas',
                provider.salesInvoices.where((i) => i.status == 'Lunas').length,
                Formatters.currency(paid),
                'Masuk',
                isDark ? const Color(0xFF28A745) : const Color(0xFF087A65),
                Icons.check_circle_outline,
                isDark,
              );

              if (isSmallScreen) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: card1), const SizedBox(width: 16), Expanded(child: card2)]),
                    const SizedBox(height: 16),
                    Row(children: [Expanded(child: card3), const SizedBox(width: 16), Expanded(child: card4)]),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 16),
                  Expanded(child: card2),
                  const SizedBox(width: 16),
                  Expanded(child: card3),
                  const SizedBox(width: 16),
                  Expanded(child: card4),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Tabs
          _buildTabs(isDark),
          const SizedBox(height: 20),

          // Content
          if (_activeTab == 'ar_aging')
            _buildArAgingView(provider, isDark)
          else if (_activeTab != 'faktur')
            _buildComingSoon(_tabs.firstWhere((t) => t['id'] == _activeTab)['name'] as String, isDark)
          else ...[
            _buildToolbar(isDark),
            const SizedBox(height: 16),
            _buildInvoiceTable(invoices, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownButton(AppProvider provider, bool isDark) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    return ElevatedButton.icon(
      onPressed: () => provider.openNewForm('sales'),
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Buat Faktur Penjualan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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

  Widget _buildComingSoon(String label, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return ErpCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.construction_rounded, size: 44, color: _primaryColor),
            const SizedBox(height: 16),
            Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary)),
            const SizedBox(height: 8),
            Text('Modul ini belum tersedia dan akan segera hadir.', style: GoogleFonts.ibmPlexSans(fontSize: 14, color: _textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _bgCard = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _tabs.map((tab) {
          final isActive = _activeTab == tab['id'];
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? _primaryColor : _bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isActive ? _primaryColor : _borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab['icon'] as IconData, size: 16, color: isActive ? Colors.white : _textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    tab['name'] as String,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? Colors.white : _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildToolbar(bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari no transaksi, pelanggan...',
              hintStyle: GoogleFonts.ibmPlexSans(color: isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D)),
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _borderColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceTable(List<SalesInvoice> invoices, bool isDark) {
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
                Flexible(child: Text('DAFTAR FAKTUR PENJUALAN KONSOLIDASI', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary))),
                Text('${invoices.length} Faktur', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),
          ErpDataGrid<SalesInvoice>(
            storageKey: 'sales_invoices',
            rows: invoices,
            emptyText: 'Belum ada data faktur penjualan.',
            minTableWidth: 1000,
            columns: [
              ErpGridColumn(
                label: 'No. Faktur',
                flex: 1.4,
                filter: ErpFilterKind.text,
                value: (inv) => inv.id,
                cell: (_, inv) => Text(inv.id, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor)),
              ),
              ErpGridColumn(
                label: 'Tanggal',
                flex: 1.0,
                filter: ErpFilterKind.date,
                value: (inv) => inv.date,
                cell: (_, inv) => Text(Formatters.dateShort(inv.date)),
              ),
              ErpGridColumn(
                label: 'Pelanggan B2B',
                flex: 1.8,
                filter: ErpFilterKind.text,
                value: (inv) => inv.customer,
                cell: (_, inv) => Text(inv.customer, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              ErpGridColumn(
                label: 'Gudang Pengeluaran',
                flex: 1.4,
                filter: ErpFilterKind.select,
                value: (inv) => inv.warehouse,
                cell: (_, inv) => Text(inv.warehouse, style: const TextStyle(fontSize: 12)),
              ),
              ErpGridColumn(
                label: 'Nilai Tagihan',
                flex: 1.3,
                filter: ErpFilterKind.number,
                alignRight: true,
                value: (inv) => inv.amount,
                cell: (_, inv) => Text(Formatters.currency(inv.amount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600)),
              ),
              ErpGridColumn(
                label: 'Status',
                flex: 1.1,
                filter: ErpFilterKind.select,
                value: (inv) => inv.status,
                cell: (_, inv) => StatusBadge(label: inv.status, type: inv.statusBadge),
              ),
              ErpGridColumn(
                label: 'Aksi',
                flex: 1.9,
                sortable: false,
                cell: (context, inv) => _invoiceActions(context, inv),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _invoiceActions(BuildContext context, SalesInvoice inv) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: const Icon(Icons.visibility_outlined, size: 16),
          onPressed: () => context.read<AppProvider>().openNewForm('sales', customTitle: 'Detail Faktur ${inv.id}', targetId: inv.id),
          tooltip: 'Lihat Detail',
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 16),
          onPressed: () => context.read<AppProvider>().openNewForm('sales', customTitle: 'Edit Faktur ${inv.id}', targetId: inv.id),
          tooltip: 'Edit',
        ),
        if (inv.status != 'Lunas' && inv.status != 'Draft') ...[
          IconButton(
            icon: const Icon(Icons.payment_rounded, size: 16, color: Color(0xFF28A745)),
            onPressed: () async {
              final result = await TransactionPaymentDialog.show(
                context,
                transactionId: inv.id,
                totalAmount: inv.amount,
                partnerName: inv.customer,
                isPurchase: false,
              );
              if (result != null && context.mounted) {
                final updatedInv = inv.copyWith(
                  status: 'Lunas',
                  paymentMethod: result.paymentMethod,
                  paidAmount: result.paidAmount,
                  paymentDate: DateTime.now(),
                );
                final provider = context.read<AppProvider>();
                provider.addSalesInvoice(updatedInv);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Pembayaran faktur ${inv.id} berhasil dicatat (Lunas).'),
                  backgroundColor: const Color(0xFF28A745),
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            tooltip: 'Bayar / Pelunasan',
          ),
        ],
        IconButton(
          icon: const Icon(Icons.print_outlined, size: 16),
          onPressed: () {
            InvoicePrintDialog.showFromSales(context, invoice: inv);
          },
          tooltip: 'Cetak Nota',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
          onPressed: () {
            context.read<AppProvider>().deleteSalesInvoice(inv.id);
          },
          tooltip: 'Hapus',
        ),
      ]),
    );
  }

  Widget _buildArAgingView(AppProvider provider, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);

    final Color _successColor = isDark ? const Color(0xFF28A745) : const Color(0xFF087A65);
    final Color _warningColor = isDark ? const Color(0xFFF0BD63) : const Color(0xFF9A6200);
    final Color _dangerColor = isDark ? const Color(0xFFE55353) : const Color(0xFFB3363B);

    Color toneOf(AccountsReceivable ar) =>
        ar.status == 'Lancar' ? _successColor : ar.status == 'Perhatian' ? _warningColor : _dangerColor;

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
                      Text('MONITORING AGING PIUTANG PELANGGAN (ACCOUNTS RECEIVABLE)', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                      const SizedBox(height: 4),
                      Text('Analisis umur piutang dagang berdasarkan tanggal jatuh tempo faktur', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('3 Klasifikasi Umur', style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: _primaryColor)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),
          ErpDataGrid<AccountsReceivable>(
            storageKey: 'sales_ar_aging',
            rows: provider.arAging,
            emptyText: 'Belum ada data piutang dagang (AR).',
            minTableWidth: 1100,
            columns: [
              ErpGridColumn(
                label: 'No. Sales Order',
                flex: 1.3,
                filter: ErpFilterKind.text,
                value: (ar) => ar.soNumber,
                cell: (_, ar) => Text(ar.soNumber, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor)),
              ),
              ErpGridColumn(
                label: 'Nama Pelanggan',
                flex: 1.7,
                filter: ErpFilterKind.text,
                value: (ar) => ar.customer,
                cell: (_, ar) => Text(ar.customer, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              ErpGridColumn(
                label: 'Tgl Jatuh Tempo',
                flex: 1.1,
                filter: ErpFilterKind.date,
                value: (ar) => ar.dueDate,
                cell: (_, ar) => Text(Formatters.dateShort(ar.dueDate)),
              ),
              ErpGridColumn(
                label: 'Total Tagihan',
                flex: 1.3,
                filter: ErpFilterKind.number,
                alignRight: true,
                value: (ar) => ar.totalAmount,
                cell: (_, ar) => Text(Formatters.currency(ar.totalAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500)),
              ),
              ErpGridColumn(
                label: 'Sisa Piutang',
                flex: 1.3,
                filter: ErpFilterKind.number,
                alignRight: true,
                value: (ar) => ar.remainingAmount,
                cell: (_, ar) => Text(Formatters.currency(ar.remainingAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _dangerColor)),
              ),
              ErpGridColumn(
                label: 'Kelompok Umur (Bucket)',
                flex: 1.4,
                filter: ErpFilterKind.select,
                value: (ar) => ar.agingBucket,
                cell: (_, ar) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: toneOf(ar).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ar.agingBucket,
                    style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: toneOf(ar)),
                  ),
                ),
              ),
              ErpGridColumn(
                label: 'Kolektibilitas',
                flex: 1.1,
                filter: ErpFilterKind.select,
                value: (ar) => ar.status,
                cell: (_, ar) => StatusBadge(
                  label: ar.status,
                  type: ar.status == 'Lancar' ? 'success' : ar.status == 'Perhatian' ? 'warning' : 'danger',
                ),
              ),
              ErpGridColumn(
                label: 'Aksi Pelunasan',
                flex: 1.1,
                sortable: false,
                cell: (_, ar) => ar.status == 'Lunas'
                    ? Text('✓ Lunas', style: GoogleFonts.ibmPlexSans(color: _successColor, fontWeight: FontWeight.w600))
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            ar.remainingAmount = 0;
                            ar.status = 'Lunas';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                        child: const Text('Lunasi'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
