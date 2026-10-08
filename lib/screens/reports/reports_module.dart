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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12, runSpacing: 12,
          children: [
            Text('Laporan Eksekutif', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              OutlinedButton.icon(icon: const Icon(Icons.print, size: 16), label: const Text('Cetak Laporan'), onPressed: () => _soon(context)),
              const SizedBox(width: 12),
              ElevatedButton.icon(icon: const Icon(Icons.download, size: 16), label: const Text('Unduh PDF'), onPressed: () => _soon(context)),
            ]),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width < 900 ? 2 : 4, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: MediaQuery.of(context).size.width < 900 ? 1.5 : 1.8,
          children: [
            KpiCard(title: 'Margin Bersih', value: '0%', trend: '0%', trendLabel: '-', trendUp: true, icon: Icons.analytics_outlined, iconColor: AppColors.primary),
            KpiCard(title: 'Perputaran Stok', value: '0x', trend: '0x', trendLabel: '-', trendUp: true, icon: Icons.sync_alt_outlined, iconColor: AppColors.success),
            KpiCard(title: 'DSO (Days Sales Outstanding)', value: '0 Hari', trend: '0 Hari', trendLabel: '-', trendUp: false, icon: Icons.calendar_month_outlined, iconColor: AppColors.warning),
            KpiCard(title: 'Total Revenue YTD', value: 'Rp 0', trend: '0%', trendLabel: '-', trendUp: true, icon: Icons.diamond_outlined, iconColor: Color(0xFF8B5CF6)),
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
    final sales = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    final expenses = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
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
                if (idx < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(months[idx], style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                  );
                }
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
    final customers = <(String, String, double, Color)>[];
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
    final rows = <(String, String, String, String, String, String, String)>[];
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text('Ringkasan Keuangan Bulanan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Center(child: Text('Belum ada data untuk ditampilkan.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted))),
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
              DataCell(Text(r.$3, style: TextStyle(color: AppColors.danger))),
              DataCell(Text(r.$4, style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700))),
              DataCell(Text(r.$5, style: TextStyle(color: AppColors.warning))),
              DataCell(Text(r.$6, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(8)),
                child: Text(r.$7, style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
              )),
            ])).toList(),
          ),
        ),
      ]),
    );
  }
}

/// Feedback untuk aksi yang belum tersedia, supaya tombol tidak terasa "mati".
void _soon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Fitur cetak/unduh belum tersedia.'), duration: Duration(seconds: 2)),
  );
}
