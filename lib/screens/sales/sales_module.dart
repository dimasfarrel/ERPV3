import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';

class SalesModule extends StatefulWidget {
  const SalesModule({super.key});

  @override
  State<SalesModule> createState() => _SalesModuleState();
}

class _SalesModuleState extends State<SalesModule> {
  String _activeTab = 'faktur'; // 'faktur', 'ar_aging', 'penawaran'
  String _filterStatus = 'all';
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

    final invoices = provider.salesInvoices.where((inv) {
      final matchStatus = _filterStatus == 'all' || inv.status == _filterStatus;
      final matchSearch = _searchQuery.isEmpty ||
          inv.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.customer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchStatus && matchSearch;
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _borderColor),
          ),
          child: DropdownButton<String>(
            value: _filterStatus,
            underline: const SizedBox.shrink(),
            style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            onChanged: (v) => setState(() => _filterStatus = v!),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Semua Status Faktur')),
              DropdownMenuItem(value: 'Lunas', child: Text('Status: Lunas')),
              DropdownMenuItem(value: 'Belum Bayar', child: Text('Status: Belum Bayar')),
              DropdownMenuItem(value: 'Jatuh Tempo', child: Text('Status: Jatuh Tempo')),
            ],
          ),
        ),
        const SizedBox(width: 16),
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
    final Color _headerColor = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);

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
                Text('DAFTAR FAKTUR PENJUALAN KONSOLIDASI', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                Text('${invoices.length} Faktur', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),
          LayoutBuilder(
            builder: (context, constraints) => invoices.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada data faktur penjualan.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
              headingRowColor: WidgetStateProperty.all(_headerColor),
              dividerThickness: 1,
              headingTextStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _textPrimary, fontSize: 13),
              dataTextStyle: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
              columns: const [
                DataColumn(label: Text('No. Faktur')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Pelanggan B2B')),
                DataColumn(label: Text('Gudang Pengeluaran')),
                DataColumn(label: Text('Nilai Tagihan')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: invoices.map((inv) => DataRow(cells: [
                DataCell(Text(inv.id, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor))),
                DataCell(Text(Formatters.dateShort(inv.date))),
                DataCell(Text(inv.customer, style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(inv.warehouse, style: const TextStyle(fontSize: 12))),
                DataCell(Text(Formatters.currency(inv.amount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600))),
                DataCell(StatusBadge(label: inv.status, type: inv.statusBadge)),
                DataCell(Row(children: [
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
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    onPressed: () {
                      context.read<AppProvider>().deleteSalesInvoice(inv.id);
                    },
                    tooltip: 'Hapus',
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_outlined, size: 16),
                    onPressed: () {},
                    tooltip: 'Cetak Nota',
                  ),
                ])),
              ])).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArAgingView(AppProvider provider, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _headerColor = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);
    
    final Color _successColor = isDark ? const Color(0xFF28A745) : const Color(0xFF087A65);
    final Color _warningColor = isDark ? const Color(0xFFF0BD63) : const Color(0xFF9A6200);
    final Color _dangerColor = isDark ? const Color(0xFFE55353) : const Color(0xFFB3363B);

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MONITORING AGING PIUTANG PELANGGAN (ACCOUNTS RECEIVABLE)', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                    const SizedBox(height: 4),
                    Text('Analisis umur piutang dagang berdasarkan tanggal jatuh tempo faktur', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
                  ],
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
          LayoutBuilder(
            builder: (context, constraints) => provider.arAging.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada data piutang dagang (AR).', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
              headingRowColor: WidgetStateProperty.all(_headerColor),
              dividerThickness: 1,
              headingTextStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _textPrimary, fontSize: 13),
              dataTextStyle: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
              columns: const [
                DataColumn(label: Text('No. Sales Order')),
                DataColumn(label: Text('Nama Pelanggan')),
                DataColumn(label: Text('Tgl Jatuh Tempo')),
                DataColumn(label: Text('Total Tagihan')),
                DataColumn(label: Text('Sisa Piutang')),
                DataColumn(label: Text('Kelompok Umur (Bucket)')),
                DataColumn(label: Text('Kolektibilitas')),
                DataColumn(label: Text('Aksi Pelunasan')),
              ],
              rows: provider.arAging.map((ar) {
                final isLancar = ar.status == 'Lancar';
                final isPerhatian = ar.status == 'Perhatian';

                return DataRow(cells: [
                  DataCell(Text(ar.soNumber, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor))),
                  DataCell(Text(ar.customer, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(Formatters.dateShort(ar.dueDate))),
                  DataCell(Text(Formatters.currency(ar.totalAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500))),
                  DataCell(Text(Formatters.currency(ar.remainingAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _dangerColor))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isLancar ? _successColor : isPerhatian ? _warningColor : _dangerColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ar.agingBucket,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isLancar ? _successColor : isPerhatian ? _warningColor : _dangerColor,
                        ),
                      ),
                    ),
                  ),
                  DataCell(StatusBadge(label: ar.status, type: isLancar ? 'success' : isPerhatian ? 'warning' : 'danger')),
                  DataCell(
                    ar.status == 'Lunas'
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
