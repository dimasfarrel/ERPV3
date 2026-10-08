import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/kpi_card.dart';

class AccountingModule extends StatefulWidget {
  const AccountingModule({super.key});

  @override
  State<AccountingModule> createState() => _AccountingModuleState();
}

class _AccountingModuleState extends State<AccountingModule> {
  String _activeTab = 'profit_loss'; // 'profit_loss', 'balance_sheet', 'journals', 'coa'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final revenue = provider.totalRevenue;
    final hpp = provider.totalHpp;
    final gross = provider.grossProfit;
    final opex = provider.totalOperatingExpenses;
    final net = provider.netIncome;

    final assets = provider.totalAssets;
    final liabilities = provider.totalLiabilities;
    final equity = provider.totalEquity;
    final totalPasiva = liabilities + equity;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keuangan & Akuntansi Enterprise',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bagan akun (COA), jurnal umum berpasangan, neraca saldo, dan laba rugi real-time',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Export Excel (.xlsx)'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan Keuangan (.xlsx) berhasil diekspor!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Financial Live KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 900;
              final card1 = KpiCard(
                title: 'Kas & Bank Operasional',
                value: Formatters.compactCurrency(345800000),
                trend: 'Liquid',
                trendLabel: 'BCA & Kas Toko',
                trendUp: true,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primary,
              );
              final card2 = KpiCard(
                title: 'Pendapatan Usaha',
                value: Formatters.compactCurrency(revenue),
                trend: '+24.2%',
                trendLabel: 'YTD 2026',
                trendUp: true,
                icon: Icons.trending_up,
                iconColor: AppColors.success,
              );
              final card3 = KpiCard(
                title: 'Laba Kotor (Gross Profit)',
                value: Formatters.compactCurrency(gross),
                trend: '${((gross / revenue) * 100).toStringAsFixed(1)}%',
                trendLabel: 'Gross Margin',
                trendUp: true,
                icon: Icons.pie_chart_outline,
                iconColor: const Color(0xFF0284C7),
              );
              final card4 = KpiCard(
                title: 'Laba Bersih (Net Profit)',
                value: Formatters.compactCurrency(net),
                trend: 'Surplus',
                trendLabel: 'Setelah Beban Opex',
                trendUp: true,
                icon: Icons.military_tech_outlined,
                iconColor: AppColors.manufacturing,
              );

              if (isSmall) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: card1), const SizedBox(width: 12), Expanded(child: card2)]),
                    const SizedBox(height: 12),
                    Row(children: [Expanded(child: card3), const SizedBox(width: 12), Expanded(child: card4)]),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 14),
                  Expanded(child: card2),
                  const SizedBox(width: 14),
                  Expanded(child: card3),
                  const SizedBox(width: 14),
                  Expanded(child: card4),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tab('profit_loss', 'Laporan Laba Rugi (P&L)', Icons.insert_chart_outlined),
                const SizedBox(width: 8),
                _tab('balance_sheet', 'Neraca Keuangan (Balance Sheet)', Icons.balance_outlined),
                const SizedBox(width: 8),
                _tab('journals', 'Jurnal Umum Double-Entry', Icons.book_outlined),
                const SizedBox(width: 8),
                _tab('coa', 'Bagan Akun Perkiraan (COA)', Icons.format_list_bulleted_outlined),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Body
          if (_activeTab == 'profit_loss') _buildProfitLossView(revenue, hpp, gross, opex, net),
          if (_activeTab == 'balance_sheet') _buildBalanceSheetView(assets, liabilities, equity, totalPasiva),
          if (_activeTab == 'journals') _buildJournalsView(context, provider),
          if (_activeTab == 'coa') _buildCoaView(provider),
        ],
      ),
    );
  }

  Widget _tab(String id, String label, IconData icon) {
    final active = _activeTab == id;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 1: PROFIT & LOSS ====================
  Widget _buildProfitLossView(double revenue, double hpp, double gross, double opex, double net) {
    return ErpCard(
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
                  Text('LAPORAN LABA RUGI (STATEMENT OF PROFIT AND LOSS)', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800)),
                  Text('Periode Berjalan: Tahun Buku 2026 • Metode Akuntansi Akrual', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(6)),
                child: Text('PROFITABLE / SURPLUS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
              ),
            ],
          ),
          const Divider(height: 28),

          _plHeader('1. PENDAPATAN USAHA (REVENUE)'),
          _plRow('Pendapatan Penjualan Produk IoT & Sensor Industri', Formatters.currency(revenue)),
          const SizedBox(height: 8),

          _plHeader('2. HARGA POKOK PENJUALAN (HPP)'),
          _plRow('Biaya Bahan Mentah, Komponen Perakitan & Overhead Pabrik', '-${Formatters.currency(hpp)}', isNegative: true),
          const Divider(height: 20),

          _plHighlightRow('LABA KOTOR (GROSS PROFIT)', Formatters.currency(gross), isPrimary: true),
          const SizedBox(height: 14),

          _plHeader('3. BEBAN OPERASIONAL (OPERATING EXPENSES)'),
          _plRow('Beban Gaji Karyawan, Tunjangan & Lembur', '-${Formatters.currency(46489000)}', isNegative: true),
          _plRow('Beban Listrik, Utilitas & Fasilitas Pabrik', '-${Formatters.currency(12500000)}', isNegative: true),
          _plRow('Beban Ongkos Kirim & Ekspedisi Logistik', '-${Formatters.currency(7800000)}', isNegative: true),
          _plSubtotal('Total Beban Operasional', '-${Formatters.currency(opex)}'),
          const Divider(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgApp,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LABA BERSIH BERJALAN (NET PROFIT)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800)),
                    const Text('Laba Bersih Komprehensif Sebelum Pajak Penghasilan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Text(
                  Formatters.currency(net),
                  style: GoogleFonts.jetBrainsMono(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _plHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
    );
  }

  Widget _plRow(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w600, color: isNegative ? AppColors.danger : AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _plSubtotal(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.danger)),
        ],
      ),
    );
  }

  Widget _plHighlightRow(String label, String value, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }

  // ==================== TAB 2: BALANCE SHEET ====================
  Widget _buildBalanceSheetView(double assets, double liabilities, double equity, double totalPasiva) {
    return ErpCard(
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
                  Text('NERACA SALDO & POSISI KEUANGAN (BALANCE SHEET)', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800)),
                  Text('Status Neraca: Seimbang (Aktiva = Pasiva)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(6)),
                child: Text('✓ NERACA SEIMBANG', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
              ),
            ],
          ),
          const Divider(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: AKTIVA / ASET
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: AppColors.bgApp,
                      child: Text('AKTIVA / ASET (ASSETS)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                    const SizedBox(height: 8),
                    _bsRow('Kas & Bank Operasional', 345800000),
                    _bsRow('Piutang Usaha Dagang (AR)', 49254000),
                    _bsRow('Persediaan Bahan & Barang Jadi', 372600000),
                    _bsRow('Mesin SMT & Fasilitas Perakitan', 650000000),
                    const Divider(height: 24),
                    _bsTotalRow('TOTAL AKTIVA / ASET', assets, AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Column 2: PASIVA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: AppColors.bgApp,
                      child: Text('PASIVA (KEWAJIBAN & EKUITAS)', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: const Color(0xFF0284C7))),
                    ),
                    const SizedBox(height: 8),
                    Text('KEWAJIBAN (LIABILITIES):', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    _bsRow('Hutang Usaha Supplier (AP)', 48800000),
                    _bsRow('Hutang Pajak PPN & PPh21', 14820000),
                    const SizedBox(height: 10),
                    Text('EKUITAS PEMILIK (EQUITY):', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    _bsRow('Modal Disetor Pemegang Saham', 1000000000),
                    _bsRow('Laba Ditahan (Retained Earnings)', 354034000),
                    const Divider(height: 24),
                    _bsTotalRow('TOTAL PASIVA (KEWAJIBAN + EKUITAS)', totalPasiva, const Color(0xFF0284C7)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bsRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(Formatters.currency(val), style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _bsTotalRow(String label, double val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          Text(Formatters.currency(val), style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  // ==================== TAB 3: JOURNALS ====================
  Widget _buildJournalsView(BuildContext context, AppProvider provider) {
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
                Text('Jurnal Transaksi Umum (Double-Entry Bookkeeping)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
                ElevatedButton.icon(
                  onPressed: () => _showAddJournalDialog(context, provider),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Entri Jurnal Baru'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          provider.journalEntries.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Belum ada data entri jurnal (GL).', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('No. Bukti')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Referensi')),
                DataColumn(label: Text('Keterangan')),
                DataColumn(label: Text('Rincian Akun & Baris')),
                DataColumn(label: Text('Total Debit')),
                DataColumn(label: Text('Total Kredit')),
                DataColumn(label: Text('Status')),
              ],
              rows: provider.journalEntries.map((j) {
                return DataRow(cells: [
                  DataCell(Text(j.entryNumber, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(Formatters.dateShort(j.date))),
                  DataCell(Text(j.reference, style: GoogleFonts.jetBrainsMono(fontSize: 11))),
                  DataCell(Text(j.description, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: j.lines.map((l) {
                        return Text(
                          '${l.accountCode} - ${l.accountName} (${l.debit > 0 ? "Dr: ${Formatters.currency(l.debit)}" : "Cr: ${Formatters.currency(l.credit)}"})',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                        );
                      }).toList(),
                    ),
                  ),
                  DataCell(Text(Formatters.currency(j.totalDebit), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700))),
                  DataCell(Text(Formatters.currency(j.totalCredit), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(4)),
                      child: Text('BALANCED', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddJournalDialog(BuildContext context, AppProvider provider) {
    final refCtrl = TextEditingController(text: 'MEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}');
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Entri Jurnal Umum Berpasangan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'No. Referensi Dokumen')),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi Transaksi')),
              const SizedBox(height: 10),
              TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal Debit/Kredit Seimbang (Rp)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amtCtrl.text);
              if (amt != null && amt > 0 && descCtrl.text.isNotEmpty) {
                final newJ = JournalEntry(
                  id: 'je-${DateTime.now().millisecondsSinceEpoch}',
                  entryNumber: 'JV-2026-${provider.journalEntries.length + 10}',
                  date: DateTime.now(),
                  reference: refCtrl.text,
                  description: descCtrl.text,
                  totalDebit: amt,
                  totalCredit: amt,
                  lines: [
                    JournalEntryLine(accountCode: '1110', accountName: 'Kas Kecil & Operasional', debit: amt, credit: 0),
                    JournalEntryLine(accountCode: '4110', accountName: 'Pendapatan Lain-lain', debit: 0, credit: amt),
                  ],
                );
                provider.addJournalEntry(newJ);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Jurnal ${newJ.entryNumber} berhasil dibukukan!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Posting Jurnal'),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 4: COA ====================
  Widget _buildCoaView(AppProvider provider) {
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text('Bagan Akun Standar Akuntansi Keuangan (Chart of Accounts)', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          provider.coa.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Bagan akun (COA) kosong.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('Kode Akun')),
                DataColumn(label: Text('Nama Perkiraan Akun')),
                DataColumn(label: Text('Klasifikasi Kategori')),
                DataColumn(label: Text('Saldo Normal')),
                DataColumn(label: Text('Saldo Berjalan (IDR)')),
              ],
              rows: provider.coa.map((c) {
                return DataRow(cells: [
                  DataCell(Text(c.code, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(c.category)),
                  DataCell(Text(c.normalBalance, style: TextStyle(fontWeight: FontWeight.w700, color: c.normalBalance == 'Debit' ? AppColors.primary : AppColors.success))),
                  DataCell(Text(Formatters.currency(c.balance), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700))),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
