import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';
import 'sales_form_screen.dart';

class SalesModule extends StatefulWidget {
  const SalesModule({super.key});

  @override
  State<SalesModule> createState() => _SalesModuleState();
}

class _SalesModuleState extends State<SalesModule> {
  String _activeTab = 'faktur';
  String _filterStatus = 'all';
  String _searchQuery = '';
  bool _showForm = false; // toggle full-page form
  final _searchCtrl = TextEditingController();

  final _tabs = ['Faktur', 'Tukar Faktur', 'Pengiriman', 'Penawaran', 'Permintaan', 'Ditolak'];
  final _tabIds = ['faktur', 'tukar-faktur', 'pengiriman', 'penawaran', 'permintaan', 'ditolak'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final invoices = provider.salesInvoices.where((inv) {
      final matchStatus = _filterStatus == 'all' || inv.status == _filterStatus;
      final matchSearch = _searchQuery.isEmpty
          || inv.id.toLowerCase().contains(_searchQuery.toLowerCase())
          || inv.customer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    final unpaid = provider.salesInvoices.where((i) => i.status == 'Belum Bayar').fold(0.0, (s, i) => s + i.amount);
    final due    = provider.salesInvoices.where((i) => i.status == 'Jatuh Tempo').fold(0.0, (s, i) => s + i.amount);
    final paid   = provider.salesInvoices.where((i) => i.status == 'Lunas').fold(0.0, (s, i) => s + i.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Penjualan', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
        const SizedBox(height: 20),
        // Metric cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 800;
            final card1 = _metricCard('Belum Dibayar',
              provider.salesInvoices.where((i) => i.status == 'Belum Bayar').length,
              Formatters.currency(unpaid), '${provider.salesInvoices.where((i) => i.status == 'Belum Bayar').length} Faktur Jatuh Tempo Bulan Ini',
              AppColors.warning);
            final card2 = _metricCard('Jatuh Tempo',
              provider.salesInvoices.where((i) => i.status == 'Jatuh Tempo').length,
              Formatters.currency(due), '${provider.salesInvoices.where((i) => i.status == 'Jatuh Tempo').length} Faktur Melewati Batas Tempo',
              AppColors.danger);
            final card3 = _metricCard('Sudah Lunas',
              provider.salesInvoices.where((i) => i.status == 'Lunas').length,
              Formatters.currency(paid), '${provider.salesInvoices.where((i) => i.status == 'Lunas').length} Faktur Selesai Terbayar',
              AppColors.success);

            if (isSmallScreen) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  card1,
                  const SizedBox(height: 16),
                  card2,
                  const SizedBox(height: 16),
                  card3,
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
              ],
            );
          },
        ),
        const SizedBox(height: 20),
        // Action row with DROPDOWN button
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(onPressed: () {}, child: const Text('Impor')),
          const SizedBox(width: 12),
          _buildDropdownButton(provider),
        ]),
        const SizedBox(height: 16),
        _buildTabs(),
        const SizedBox(height: 16),
        _buildToolbar(),
        const SizedBox(height: 12),
        _buildInvoiceTable(invoices),
      ]),
    );
  }

  Widget _buildDropdownButton(AppProvider provider) {
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => provider.openNewForm('sales'),
          child: Text('Faktur penjualan', style: GoogleFonts.inter(fontSize: 13)),
        ),
        MenuItemButton(
          onPressed: () => provider.openNewForm('sales', customTitle: 'Tukar Faktur'),
          child: Text('Tukar faktur', style: GoogleFonts.inter(fontSize: 13)),
        ),
        MenuItemButton(
          onPressed: () => provider.openNewForm('sales', customTitle: 'Pemesanan Penjualan'),
          child: Text('Pemesanan penjualan', style: GoogleFonts.inter(fontSize: 13)),
        ),
        MenuItemButton(
          onPressed: () => provider.openNewForm('sales', customTitle: 'Penawaran Penjualan'),
          child: Text('Penawaran penjualan', style: GoogleFonts.inter(fontSize: 13)),
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
            Text('Buat penjualan baru', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
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
      child: Row(children: List.generate(_tabs.length, (i) {
        final isActive = _activeTab == _tabIds[i];
        return GestureDetector(
          onTap: () => setState(() => _activeTab = _tabIds[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight),
            ),
            child: Text(_tabs[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textMuted)),
          ),
        );
      })),
    );
  }

  Widget _buildToolbar() {
    return Row(children: [
      DropdownButton<String>(
        value: _filterStatus,
        underline: const SizedBox.shrink(),
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary),
        onChanged: (v) => setState(() => _filterStatus = v!),
        items: const [
          DropdownMenuItem(value: 'all', child: Text('Semua Status')),
          DropdownMenuItem(value: 'Lunas', child: Text('Lunas')),
          DropdownMenuItem(value: 'Belum Bayar', child: Text('Belum Bayar')),
          DropdownMenuItem(value: 'Jatuh Tempo', child: Text('Jatuh Tempo')),
        ],
      ),
      const SizedBox(width: 12),
      Expanded(
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: const InputDecoration(
            hintText: 'Cari faktur, pelanggan...',
            prefixIcon: Icon(Icons.search, size: 18),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
        ),
      ),
    ]);
  }

  Widget _buildInvoiceTable(invoices) {
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('DAFTAR FAKTUR PENJUALAN', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800,
              color: AppColors.secondary, letterSpacing: 0.5)),
            Text('${invoices.length} Faktur Terdata', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
          ]),
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
              DataColumn(label: Text('No Transaksi')),
              DataColumn(label: Text('Tanggal')),
              DataColumn(label: Text('Pelanggan')),
              DataColumn(label: Text('Gudang')),
              DataColumn(label: Text('Total Tagihan')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Aksi')),
            ],
            rows: invoices.map<DataRow>((inv) => DataRow(cells: [
              DataCell(Text(inv.id, style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
              DataCell(Text(Formatters.dateShort(inv.date))),
              DataCell(Text(inv.customer, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(inv.warehouse, style: const TextStyle(fontSize: 12))),
              DataCell(Text(Formatters.currency(inv.amount), style: const TextStyle(fontWeight: FontWeight.w700))),
              DataCell(StatusBadge(label: inv.status, type: inv.statusBadge)),
              DataCell(Row(children: [
                IconButton(icon: const Icon(Icons.visibility_outlined, size: 16), onPressed: () {}, color: AppColors.textMuted),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16),
                  onPressed: () => setState(() => _showForm = true), color: AppColors.textMuted),
              ])),
            ])).toList(),
          ),
        ),
      ]),
    );
  }
}
