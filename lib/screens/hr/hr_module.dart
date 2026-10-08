import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/kpi_card.dart';
import '../../widgets/common/status_badge.dart';

class HrModule extends StatefulWidget {
  const HrModule({super.key});

  @override
  State<HrModule> createState() => _HrModuleState();
}

class _HrModuleState extends State<HrModule> {
  String _activeTab = 'employees'; // 'employees' | 'payroll'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final totalSalary = provider.payrollRecords.fold(0.0, (s, p) => s + p.netSalary);
    final permanentCount = provider.employees.where((e) => e.status == 'Tetap').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SDM & Penggajian (HR & Payroll)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Master data karyawan, kalkulasi gaji, komponen BPJS & PPh21, dan cetak slip gaji karyawan',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEmployeeDialog(context, provider),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: const Text('Tambah Karyawan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 800;
              final card1 = KpiCard(
                title: 'Total Karyawan Aktif',
                value: '${provider.employees.length} Orang',
                trend: '$permanentCount Tetap',
                trendLabel: '${provider.employees.length - permanentCount} Kontrak',
                trendUp: true,
                icon: Icons.people_outline,
                iconColor: AppColors.primary,
              );
              final card2 = KpiCard(
                title: 'Total Beban Payroll (Sep 2026)',
                value: Formatters.compactCurrency(totalSalary),
                trend: '5 Slip',
                trendLabel: 'Termasuk BPJS & Pajak',
                trendUp: true,
                icon: Icons.payments_outlined,
                iconColor: AppColors.success,
              );
              final card3 = KpiCard(
                title: 'Kepatuhan Pajak & BPJS',
                value: '100% Valid',
                trend: 'PPh21 Terhitung',
                trendLabel: 'Sesuai UU Ketenagakerjaan',
                trendUp: true,
                icon: Icons.verified_user_outlined,
                iconColor: const Color(0xFF0284C7),
              );

              if (isSmall) {
                return Column(
                  children: [card1, const SizedBox(height: 12), card2, const SizedBox(height: 12), card3],
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

          // Tab Switcher
          Row(
            children: [
              _buildTabButton('employees', 'Master Karyawan', Icons.badge_outlined),
              const SizedBox(width: 8),
              _buildTabButton('payroll', 'Penggajian & Slip Gaji (Payroll)', Icons.receipt_long_outlined),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Content
          if (_activeTab == 'employees') _buildEmployeeTable(context, provider),
          if (_activeTab == 'payroll') _buildPayrollTable(context, provider),
        ],
      ),
    );
  }

  Widget _buildTabButton(String id, String label, IconData icon) {
    final isActive = _activeTab == id;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeTable(BuildContext context, AppProvider provider) {
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
                Text(
                  'Daftar Master Karyawan Perusahaan',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${provider.employees.length} Karyawan Terdaftar',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          provider.employees.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Belum ada data karyawan.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('NIP')),
                DataColumn(label: Text('Nama Karyawan')),
                DataColumn(label: Text('Departemen')),
                DataColumn(label: Text('Jabatan')),
                DataColumn(label: Text('Gaji Pokok')),
                DataColumn(label: Text('Tunjangan')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Kontak & Rekening')),
              ],
              rows: provider.employees.map((emp) {
                return DataRow(cells: [
                  DataCell(Text(emp.nip, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(emp.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(emp.department)),
                  DataCell(Text(emp.position)),
                  DataCell(Text(Formatters.currency(emp.baseSalary), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600))),
                  DataCell(Text(Formatters.currency(emp.allowance), style: GoogleFonts.jetBrainsMono())),
                  DataCell(StatusBadge(label: emp.status, type: emp.status == 'Tetap' ? 'success' : 'warning')),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emp.phone, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                        Text(emp.bankAccount, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.textMuted)),
                      ],
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

  Widget _buildPayrollTable(BuildContext context, AppProvider provider) {
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
                Text(
                  'Catatan Rekapitulasi Gaji & Payroll (Periode September 2026)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Siap Cetak Slip',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          provider.payrollRecords.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Belum ada data riwayat penggajian (payroll).', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('Periode')),
                DataColumn(label: Text('Nama Karyawan')),
                DataColumn(label: Text('Gaji Pokok')),
                DataColumn(label: Text('Tunjangan + Lembur')),
                DataColumn(label: Text('Potongan BPJS & Pajak')),
                DataColumn(label: Text('Take-Home Pay')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: provider.payrollRecords.map((p) {
                return DataRow(cells: [
                  DataCell(Text(p.period, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.employeeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(p.department, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  DataCell(Text(Formatters.currency(p.baseSalary), style: GoogleFonts.jetBrainsMono())),
                  DataCell(Text(Formatters.currency(p.allowance + p.overtime), style: GoogleFonts.jetBrainsMono())),
                  DataCell(
                    Text(
                      '-${Formatters.currency(p.totalDeductions)}',
                      style: GoogleFonts.jetBrainsMono(color: AppColors.danger, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DataCell(
                    Text(
                      Formatters.currency(p.netSalary),
                      style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w800, color: AppColors.success),
                    ),
                  ),
                  DataCell(StatusBadge(label: p.status, type: 'success')),
                  DataCell(
                    OutlinedButton.icon(
                      onPressed: () => _showSlipGajiDialog(context, p),
                      icon: const Icon(Icons.print_outlined, size: 14),
                      label: const Text('Cetak Slip'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
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

  void _showSlipGajiDialog(BuildContext context, PayrollRecord p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SLIP GAJI KARYAWAN', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      Text('PT Sinar Surya Manufaktur', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.successSurface, borderRadius: BorderRadius.circular(6)),
                    child: Text('LUNAS / DIBAYAR', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Employee info
              Table(
                children: [
                  TableRow(children: [
                    _slipMeta('Nama Karyawan', p.employeeName),
                    _slipMeta('Periode Gaji', p.period),
                  ]),
                  TableRow(children: [
                    _slipMeta('Departemen', p.department),
                    _slipMeta('Tanggal Bayar', Formatters.date(p.paymentDate)),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              // Earnings
              Text('PENGHASILAN (EARNINGS):', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              _slipRow('Gaji Pokok', Formatters.currency(p.baseSalary)),
              _slipRow('Tunjangan Tetap & Fungsional', Formatters.currency(p.allowance)),
              _slipRow('Lembur / Overtime', Formatters.currency(p.overtime)),
              const SizedBox(height: 12),
              // Deductions
              Text('POTONGAN (DEDUCTIONS):', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger)),
              const SizedBox(height: 6),
              _slipRow('BPJS Ketenagakerjaan (JHT & JP)', '-${Formatters.currency(p.bpjsKetenagakerjaan)}', isDeduction: true),
              _slipRow('BPJS Kesehatan (1%)', '-${Formatters.currency(p.bpjsKesehatan)}', isDeduction: true),
              _slipRow('PPh Pasal 21 Terutang', '-${Formatters.currency(p.pph21)}', isDeduction: true),
              const Divider(height: 20),
              // Net pay
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.bgApp, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('GAJI BERSIH DITERIMA (TAKE-HOME PAY):', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                    Text(
                      Formatters.currency(p.netSalary),
                      style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dokumen Slip Gaji berhasil dikirim ke printer thermal/PDF!'), backgroundColor: Color(0xFF10B981)),
              );
            },
            icon: const Icon(Icons.print, size: 16),
            label: const Text('Cetak Dokumen'),
          ),
        ],
      ),
    );
  }

  Widget _slipMeta(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _slipRow(String label, String val, {bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            val,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDeduction ? AppColors.danger : AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context, AppProvider provider) {
    final nipCtrl = TextEditingController(text: 'EMP-2026-00${provider.employees.length + 1}');
    final nameCtrl = TextEditingController();
    final posCtrl = TextEditingController();
    final salCtrl = TextEditingController(text: '7000000');
    final allwCtrl = TextEditingController(text: '1500000');
    String dept = 'Manufaktur & Produksi';
    String status = 'Tetap';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tambah Data Karyawan Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nipCtrl, decoration: const InputDecoration(labelText: 'NIP Karyawan')),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Karyawan')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: dept,
                  items: const [
                    DropdownMenuItem(value: 'Manufaktur & Produksi', child: Text('Manufaktur & Produksi')),
                    DropdownMenuItem(value: 'Keuangan & Akuntansi', child: Text('Keuangan & Akuntansi')),
                    DropdownMenuItem(value: 'Gudang & Logistik', child: Text('Gudang & Logistik')),
                    DropdownMenuItem(value: 'Pemasaran & Penjualan', child: Text('Pemasaran & Penjualan')),
                    DropdownMenuItem(value: 'SDM & Umum', child: Text('SDM & Umum')),
                  ],
                  onChanged: (v) => dept = v ?? dept,
                  decoration: const InputDecoration(labelText: 'Departemen'),
                ),
                const SizedBox(height: 12),
                TextField(controller: posCtrl, decoration: const InputDecoration(labelText: 'Posisi / Jabatan')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: salCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gaji Pokok (Rp)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: allwCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tunjangan (Rp)'))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              final newEmp = Employee(
                id: 'emp-${DateTime.now().millisecondsSinceEpoch}',
                nip: nipCtrl.text,
                name: nameCtrl.text,
                department: dept,
                position: posCtrl.text.isNotEmpty ? posCtrl.text : 'Staf Operasional',
                baseSalary: double.tryParse(salCtrl.text) ?? 7000000,
                allowance: double.tryParse(allwCtrl.text) ?? 1500000,
                status: status,
                joinDate: DateTime.now(),
                email: '${nameCtrl.text.toLowerCase().replaceAll(' ', '.')}@sinarsurya.co.id',
                phone: '0812-3344-5566',
                bankAccount: 'BCA 123-456-7890',
              );
              provider.addEmployee(newEmp);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan Karyawan'),
          ),
        ],
      ),
    );
  }
}
