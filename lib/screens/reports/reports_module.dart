import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/kpi_card.dart';

class ReportsModule extends StatelessWidget {
  const ReportsModule({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Laporan Eksekutif', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
          Row(children: [
            OutlinedButton.icon(icon: const Icon(Icons.print, size: 16), label: const Text('Cetak Laporan'), onPressed: () {}),
            const SizedBox(width: 12),
            ElevatedButton.icon(icon: const Icon(Icons.download, size: 16), label: const Text('Unduh PDF'), onPressed: () {}),
          ]),
        ]),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 4, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.8,
          children: const [
            KpiCard(title: 'Margin Bersih', value: '30.8%', trend: '2.1%', trendLabel: 'vs Q2 2026', trendUp: true, icon: Icons.analytics_outlined, iconColor: AppColors.primary),
            KpiCard(title: 'Perputaran Stok', value: '8.4x / Tahun', trend: '0.6x', trendLabel: 'Target 10x', trendUp: true, icon: Icons.sync_alt_outlined, iconColor: AppColors.success),
            KpiCard(title: 'DSO (Days Sales Outstanding)', value: '28 Hari', trend: '3 Hari', trendLabel: 'vs bulan lalu', trendUp: false, icon: Icons.calendar_month_outlined, iconColor: AppColors.warning),
            KpiCard(title: 'Total Revenue YTD', value: 'Rp 6.4 M', trend: '18.5%', trendLabel: 'vs target', trendUp: true, icon: Icons.diamond_outlined, iconColor: Color(0xFF8B5CF6)),
          ],
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 800;
            if (isSmallScreen) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRevenueChart(),
                  const SizedBox(height: 16),
                  _buildTopCustomers(),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Expanded(flex: 3, child: _buildRevenueChart()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildTopCustomers()),
              ]
            );
          }
        ),
        const SizedBox(height: 20),
        _buildMonthlySummary(),
      ]),
    );
  }

  Widget _buildRevenueChart() {
    final sales = [45.0, 55.0, 60.0, 70.0, 75.0, 68.0, 80.0, 88.0, 95.0];
    final expenses = [30.0, 35.0, 38.0, 42.0, 48.0, 44.0, 50.0, 55.0, 60.0];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep'];

    return ErpCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tren Pendapatan & Beban (Jan - Sep 2026)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(BarChartData(
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
                if (idx < months.length) return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(months[idx], style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                );
                return const SizedBox.shrink();
              })),
            ),
            barGroups: List.generate(9, (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: sales[i], color: AppColors.primary, width: 10, borderRadius: BorderRadius.circular(3)),
                BarChartRodData(toY: expenses[i], color: const Color(0xFFCBD5E1), width: 10, borderRadius: BorderRadius.circular(3)),
              ],
              barsSpace: 3,
            )),
          )),
        ),
      ]),
    );
  }

  Widget _buildTopCustomers() {
    final customers = [
      ('PT Surya Gemilang Kencana', 'Rp 182 Jt', 0.82, AppColors.primary),
      ('PT Bintang Mitra Sejahtera', 'Rp 145 Jt', 0.65, AppColors.primary),
      ('CV Cipta Karya Mandiri', 'Rp 98 Jt', 0.44, AppColors.success),
      ('Toko Makmur Sentosa', 'Rp 67 Jt', 0.30, AppColors.warning),
      ('UD Sumber Rezeki', 'Rp 45 Jt', 0.20, AppColors.textMuted),
    ];
    return ErpCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Top 5 Pelanggan Terbesar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
        const SizedBox(height: 16),
        ...customers.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(c.$1, style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondary), overflow: TextOverflow.ellipsis)),
              Text(c.$2, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: c.$4)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: c.$3, backgroundColor: AppColors.borderLight, valueColor: AlwaysStoppedAnimation<Color>(c.$4), minHeight: 8),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _buildMonthlySummary() {
    final rows = [
      ('Sep 2026', 'Rp 842.500.000', 'Rp 521.350.000', 'Rp 321.150.000', 'Rp 61.200.000', 'Rp 259.950.000', '30.8%'),
      ('Agu 2026', 'Rp 784.000.000', 'Rp 489.500.000', 'Rp 294.500.000', 'Rp 58.000.000', 'Rp 236.500.000', '30.2%'),
      ('Jul 2026', 'Rp 710.000.000', 'Rp 448.300.000', 'Rp 261.700.000', 'Rp 55.000.000', 'Rp 206.700.000', '29.1%'),
    ];
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text('Ringkasan Keuangan Bulanan'),
        ),
        const Divider(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
            headingTextStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
            dataTextStyle: GoogleFonts.inter(fontSize: 13),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Periode')),
              DataColumn(label: Text('Pendapatan'), numeric: true),
              DataColumn(label: Text('HPP'), numeric: true),
              DataColumn(label: Text('Laba Kotor'), numeric: true),
              DataColumn(label: Text('Beban Ops'), numeric: true),
              DataColumn(label: Text('Laba Bersih'), numeric: true),
              DataColumn(label: Text('Margin')),
            ],
            rows: rows.map((r) => DataRow(cells: [
              DataCell(Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w700))),
              DataCell(Text(r.$3, style: const TextStyle(color: AppColors.danger))),
              DataCell(Text(r.$4, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
              DataCell(Text(r.$5, style: const TextStyle(color: AppColors.warning))),
              DataCell(Text(r.$6, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(8)),
                child: Text(r.$7, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
              )),
            ])).toList(),
          ),
        ),
      ]),
    );
  }
}
