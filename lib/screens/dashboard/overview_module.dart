import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';

class OverviewModule extends StatelessWidget {
  const OverviewModule({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(context, isDark),
          const SizedBox(height: 24),
          _buildKpiGrid(context, provider, isDark),
          const SizedBox(height: 24),
          _buildChartsRow(context, provider, isDark),
          const SizedBox(height: 24),
          _buildRecentTransactions(context, provider, isDark),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Operasional & Finansial',
                style: GoogleFonts.ibmPlexSans(fontSize: 24, fontWeight: FontWeight.w700, color: _textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Ringkasan eksekutif real-time rantai pasok, pabrikasi, dan performa bisnis',
                style: GoogleFonts.ibmPlexSans(fontSize: 14, color: _textSecondary),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.read<AppProvider>().switchModule('sales'),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+ Penjualan Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            OutlinedButton(
              onPressed: () => context.read<AppProvider>().switchModule('manufacturing'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                side: BorderSide(color: isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              child: Text('Lihat SPK Manufaktur', style: TextStyle(color: _textPrimary)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, AppProvider provider, bool isDark) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 700 ? 1 : (width < 1100 ? 2 : 4);

    final totalSales = provider.salesInvoices.fold(0.0, (s, i) => s + i.amount);
    final totalValuation = provider.inventoryItems.fold(0.0, (s, i) => s + (i.stockAvailable * i.unitPrice));
    final pendingPo = provider.purchaseOrders.where((p) => p.status == 'Menunggu Otorisasi').length;
    final lowStockCount = provider.inventoryItems.where((i) => i.stockAvailable < i.stockMin).length;

    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _successColor = isDark ? const Color(0xFF28A745) : const Color(0xFF087A65);
    final Color _warningColor = isDark ? const Color(0xFFF0BD63) : const Color(0xFF9A6200);
    final Color _dangerColor = isDark ? const Color(0xFFE55353) : const Color(0xFFB3363B);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: crossAxisCount == 4 ? 1.6 : (crossAxisCount == 2 ? 1.8 : 2.5),
      children: [
        KpiCard(
          title: 'Total Penjualan (Bulan Ini)',
          value: Formatters.compactCurrency(totalSales),
          trend: '+21.4%',
          trendLabel: '${provider.salesInvoices.length} Faktur',
          trendUp: true,
          icon: Icons.monetization_on_outlined,
          iconColor: _primaryColor,
        ),
        KpiCard(
          title: 'Total Nilai Valuasi Stok',
          value: Formatters.compactCurrency(totalValuation),
          trend: '+12.5%',
          trendLabel: '${provider.inventoryItems.length} Master SKU',
          trendUp: true,
          icon: Icons.inventory_2_outlined,
          iconColor: _successColor,
        ),
        KpiCard(
          title: 'Purchase Order Pending',
          value: '$pendingPo Pesanan',
          trend: 'Otorisasi',
          trendLabel: 'Perlu Persetujuan',
          trendUp: false,
          icon: Icons.pending_actions_outlined,
          iconColor: _warningColor,
        ),
        KpiCard(
          title: 'Peringatan Safety Stock',
          value: '$lowStockCount SKU Kritis',
          trend: 'Restock',
          trendLabel: 'Bawah Batas Minimum',
          trendUp: false,
          icon: Icons.warning_amber_outlined,
          iconColor: _dangerColor,
        ),
      ],
    );
  }

  Widget _buildChartsRow(BuildContext context, AppProvider provider, bool isDark) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (isMobile) {
      return Column(
        children: [
          _buildBarChart(isDark),
          const SizedBox(height: 16),
          _buildWarehouseCapacity(provider, isDark),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildBarChart(isDark)),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildWarehouseCapacity(provider, isDark)),
      ],
    );
  }

  Widget _buildBarChart(bool isDark) {
    final salesData = [45.0, 68.0, 52.0, 85.0, 92.0, 78.0];
    final expenseData = [25.0, 35.0, 28.0, 42.0, 45.0, 38.0];
    final labels = ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5', 'Mg 6'];
    
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _secondaryBarColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);

    return ErpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Arus Kas & Performa Penjualan (H2 2026)',
                  style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('Periode Mingguan', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: _textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 110,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(color: _borderColor, strokeWidth: 1, dashArray: [4, 4]),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(labels[idx], style: GoogleFonts.ibmPlexSans(fontSize: 11, color: _textSecondary)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(
                  6,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(toY: salesData[i], color: _primaryColor, width: 14, borderRadius: BorderRadius.circular(2)),
                      BarChartRodData(toY: expenseData[i], color: _secondaryBarColor, width: 14, borderRadius: BorderRadius.circular(2)),
                    ],
                    barsSpace: 4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _chartLegend(_primaryColor, 'Penjualan Bersih (IDR Jt)', _textSecondary),
              const SizedBox(width: 16),
              _chartLegend(_secondaryBarColor, 'Beban Operasional & HPP', _textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label, Color textColor) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textColor)),
      ],
    );
  }

  Widget _buildWarehouseCapacity(AppProvider provider, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _warningColor = isDark ? const Color(0xFFF0BD63) : const Color(0xFF9A6200);
    final Color _bgTrack = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);

    return ErpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Kapasitas Multi-Gudang',
                  style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('${provider.warehouses.length} Fasilitas', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: _textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          ...provider.warehouses.map((wh) {
            final isFull = wh.utilization >= 80;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          wh.name,
                          style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${wh.utilization}% Terisi', style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: isFull ? _warningColor : _textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: wh.utilization / 100,
                      minHeight: 6,
                      backgroundColor: _bgTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(isFull ? _warningColor : _primaryColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, AppProvider provider, bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
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
                Expanded(
                  child: Text(
                    'Aktivitas Transaksi Penjualan & Manufaktur Terbaru',
                    style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => provider.switchModule('sales'),
                  child: Text('Lihat Semua Faktur →', style: GoogleFonts.ibmPlexSans(color: _primaryColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: _borderColor),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(_headerColor),
              dividerThickness: 1,
              headingTextStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: _textPrimary, fontSize: 13),
              dataTextStyle: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
              columns: const [
                DataColumn(label: Text('No. Dokumen')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Pelanggan / Entitas')),
                DataColumn(label: Text('Gudang Pengeluaran')),
                DataColumn(label: Text('Total Transaksi')),
                DataColumn(label: Text('Status')),
              ],
              rows: provider.salesInvoices.map((inv) {
                return DataRow(cells: [
                  DataCell(Text(inv.id, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor))),
                  DataCell(Text(Formatters.dateShort(inv.date))),
                  DataCell(Text(inv.customer, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(inv.warehouse, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(Formatters.currency(inv.amount), style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600))),
                  DataCell(StatusBadge(label: inv.status, type: inv.statusBadge)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
