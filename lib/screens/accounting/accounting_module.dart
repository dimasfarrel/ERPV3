import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/kpi_card.dart';

class AccountingModule extends StatefulWidget {
  const AccountingModule({super.key});
  @override State<AccountingModule> createState() => _AccountingModuleState();
}

class _AccountingModuleState extends State<AccountingModule> {
  String _activeTab = 'jurnal';
  final _tabs = ['Jurnal Umum', 'Neraca Saldo', 'Laba Rugi', 'Laporan Pajak'];
  final _tabIds = ['jurnal', 'neraca', 'laba-rugi', 'pajak'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Keuangan & Pajak', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
          OutlinedButton.icon(icon: const Icon(Icons.upload_rounded, size: 16), label: const Text('Export Laporan'), onPressed: () {}),
        ]),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 800;
            final card1 = KpiCard(title: 'Kas & Setara Kas', value: 'Rp 0', trend: '0', trendLabel: '-', trendUp: true, icon: Icons.account_balance_wallet_outlined, iconColor: AppColors.primary);
            final card2 = KpiCard(title: 'Total Pendapatan', value: 'Rp 0', trend: '0', trendLabel: '-', trendUp: true, icon: Icons.trending_up_outlined, iconColor: AppColors.success);
            final card3 = KpiCard(title: 'Total Beban', value: 'Rp 0', trend: '0', trendLabel: '-', trendUp: false, icon: Icons.money_off_outlined, iconColor: AppColors.warning);

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
        SingleChildScrollView(
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
                child: Text(_tabs[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textMuted)),
              ),
            );
          })),
        ),
        const SizedBox(height: 16),
        ErpCard(
          padding: EdgeInsets.zero,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Jurnal Transaksi Umum', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                OutlinedButton(onPressed: () {}, child: const Text('+ Entri Jurnal')),
              ]),
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
                  DataColumn(label: Text('No. Jurnal')),
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Keterangan')),
                  DataColumn(label: Text('Akun')),
                  DataColumn(label: Text('Debet'), numeric: true),
                  DataColumn(label: Text('Kredit'), numeric: true),
                  DataColumn(label: Text('Status')),
                ],
                rows: provider.journalEntries.map((entry) => DataRow(cells: [
                  DataCell(Text(entry.id, style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(Formatters.dateShort(entry.date))),
                  DataCell(SizedBox(width: 220, child: Text(entry.description, overflow: TextOverflow.ellipsis))),
                  DataCell(Text(entry.account, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(Formatters.currency(entry.debit), style: const TextStyle(fontWeight: FontWeight.w700))),
                  DataCell(Text(Formatters.currency(entry.credit), style: TextStyle(color: AppColors.textMuted))),
                  DataCell(StatusBadge(label: entry.status, type: entry.status == 'Posted' ? 'success' : 'warning')),
                ])).toList(),
              ),
            ),
          ]),
        ),
      ]),
    );
  }


}
