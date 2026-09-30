import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(context),
          const SizedBox(height: 20),
          _buildKpiGrid(context),
          const SizedBox(height: 20),
          _buildChartsRow(context, provider),
          const SizedBox(height: 20),
          _buildRecentTransactions(context, provider),
        ],
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard Operasional & Finansial', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
              Text('Ringkasan performa real-time rantai pasok dan aktivitas bisnis',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.read<AppProvider>().switchModule('sales'),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+ Penjualan Baru'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
            OutlinedButton(
              onPressed: () => context.read<AppProvider>().switchModule('purchasing'),
              child: const Text('+ Pembelian Baru'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return GridView.count(
      crossAxisCount: isMobile ? 1 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        KpiCard(title: 'Total Penjualan (Bulan Ini)', value: 'Rp 842,5 Jt', trend: '14.2%', trendLabel: 'vs bulan sebelumnya', trendUp: true, icon: Icons.monetization_on_outlined, iconColor: AppColors.primary),
        KpiCard(title: 'Total Nilai Valuasi Stok', value: 'Rp 1,48 M', trend: '3.8%', trendLabel: '12.450 unit item', trendUp: true, icon: Icons.inventory_2_outlined, iconColor: AppColors.success),
        KpiCard(title: 'Purchase Order Pending', value: '8 Pesanan', trend: '2 Butuh Otorisasi', trendLabel: 'Total Rp 310 Juta', trendUp: false, icon: Icons.pending_actions_outlined, iconColor: AppColors.warning),
        KpiCard(title: 'Peringatan Minimum Stok', value: '4 SKU Kritis', trend: 'Segera Restock', trendLabel: 'Gudang Kepanjen', trendUp: false, icon: Icons.warning_amber_outlined, iconColor: Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildChartsRow(BuildContext context, AppProvider provider) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    
    if (isMobile) {
      return Column(
        children: [
          _buildBarChart(),
          const SizedBox(height: 16),
          _buildWarehouseCapacity(provider),
        ],
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildBarChart()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildWarehouseCapacity(provider)),
      ],
    );
  }

  Widget _buildBarChart() {
    final salesData = [55.0, 70.0, 60.0, 90.0, 85.0, 95.0];
    final expenseData = [35.0, 40.0, 30.0, 50.0, 45.0, 40.0];
    final labels = ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5', 'Mg 6'];

    return ErpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Arus Kas & Performa Penjualan (H2 2026)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
              Text('Periode Mingguan', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: 110,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borderLight, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                    final idx = val.toInt();
                    if (idx < labels.length) return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(labels[idx], style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                    );
                    return const SizedBox.shrink();
                  })),
                ),
                barGroups: List.generate(6, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(toY: salesData[i], color: AppColors.primary, width: 14, borderRadius: BorderRadius.circular(4)),
                    BarChartRodData(toY: expenseData[i], color: const Color(0xFFCBD5E1), width: 14, borderRadius: BorderRadius.circular(4)),
                  ],
                  barsSpace: 4,
                )),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chartLegend(AppColors.primary, 'Penjualan Bersih'),
              const SizedBox(width: 16),
              _chartLegend(const Color(0xFFCBD5E1), 'Biaya Operasional'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildWarehouseCapacity(AppProvider provider) {
    final warehouses = [
      ('Gudang Kepanjen', 84, AppColors.primary),
      ('Transit Singosari', 58, AppColors.success),
      ('Batu (Bahan Baku)', 42, AppColors.info),
      ('Retail Lowokwaru', 91, AppColors.danger),
    ];

    return ErpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Utilisasi Kapasitas Gudang', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
              Text('Status Terkini', style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          ...warehouses.map((wh) => _buildWarehouseRow(wh.$1, wh.$2, wh.$3)),
        ],
      ),
    );
  }

  Widget _buildWarehouseRow(String name, int percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary)),
              Text('$percent%', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, AppProvider provider) {
    return ErpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daftar Aktivitas & Transaksi Terbaru', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              headingTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              dataTextStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('No. Dokumen')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Mitra / Rekanan')),
                DataColumn(label: Text('Kategori')),
                DataColumn(label: Text('Nominal')),
                DataColumn(label: Text('Status')),
              ],
              rows: provider.recentTransactions.map((tx) => DataRow(cells: [
                DataCell(Text(tx.id, style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                DataCell(Text(Formatters.date(tx.date))),
                DataCell(Text(tx.partner, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                DataCell(Text(tx.type)),
                DataCell(Text(tx.amount, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(StatusBadge(label: tx.status, type: tx.statusBadge)),
              ])).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
