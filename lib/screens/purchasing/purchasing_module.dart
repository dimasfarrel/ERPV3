import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';

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
                Text('DAFTAR PESANAN PEMBELIAN (PURCHASE ORDER)', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                Text('${pos.length} Dokumen', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),
          LayoutBuilder(
            builder: (context, constraints) => pos.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada riwayat dokumen PO.', style: TextStyle(color: Colors.grey)),
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
                DataColumn(label: Text('No. PO')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Pemasok / Vendor')),
                DataColumn(label: Text('Gudang Tujuan')),
                DataColumn(label: Text('Total Nilai PO')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: pos.map((po) => DataRow(cells: [
                DataCell(Text(po.id, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor))),
                DataCell(Text(Formatters.dateShort(po.date))),
                DataCell(Text(po.vendor, style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(po.warehouse, style: const TextStyle(fontSize: 12))),
                DataCell(Text(Formatters.currency(po.amount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600))),
                DataCell(StatusBadge(label: po.status, type: po.statusBadge)),
                DataCell(Row(children: [
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
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    onPressed: () {
                      context.read<AppProvider>().deletePurchaseOrder(po.id);
                    },
                    tooltip: 'Hapus',
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_outlined, size: 16),
                    onPressed: () {},
                    tooltip: 'Cetak PO',
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

  Widget _buildApAgingTable(AppProvider provider, bool isDark) {
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
                    Text('MONITORING AGING HUTANG (ACCOUNTS PAYABLE)', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: _textPrimary)),
                    const SizedBox(height: 4),
                    Text('Analisis umur hutang usaha berdasarkan tanggal jatuh tempo invoice vendor', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary)),
                  ],
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
          LayoutBuilder(
            builder: (context, constraints) => provider.apAging.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text('Belum ada data hutang usaha (AP).', style: TextStyle(color: Colors.grey)),
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
                DataColumn(label: Text('No. Ref Invoice')),
                DataColumn(label: Text('Nama Vendor')),
                DataColumn(label: Text('Tgl Jatuh Tempo')),
                DataColumn(label: Text('Total Tagihan')),
                DataColumn(label: Text('Sisa Hutang')),
                DataColumn(label: Text('Kelompok Umur (Bucket)')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Aksi Pelunasan')),
              ],
              rows: provider.apAging.map((ap) {
                final isAman = ap.status == 'Aman';
                final isWarning = ap.status == 'Segera';

                return DataRow(cells: [
                  DataCell(Text(ap.id, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor))),
                  DataCell(Text(ap.supplier, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(Formatters.dateShort(ap.dueDate))),
                  DataCell(Text(Formatters.currency(ap.totalAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500))),
                  DataCell(Text(Formatters.currency(ap.remainingAmount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _dangerColor))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isAman ? _successColor : isWarning ? _warningColor : _dangerColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ap.agingBucket,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isAman ? _successColor : isWarning ? _warningColor : _dangerColor,
                        ),
                      ),
                    ),
                  ),
                  DataCell(StatusBadge(label: ap.status, type: isAman ? 'success' : isWarning ? 'warning' : 'danger')),
                  DataCell(
                    ap.status == 'Lunas'
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
