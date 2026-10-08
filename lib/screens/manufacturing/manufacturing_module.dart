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

class ManufacturingModule extends StatefulWidget {
  const ManufacturingModule({super.key});

  @override
  State<ManufacturingModule> createState() => _ManufacturingModuleState();
}

class _ManufacturingModuleState extends State<ManufacturingModule> {
  String _activeTab = 'wo'; // 'wo', 'bom', 'disassembly'

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final activeWo = provider.workOrders.where((w) => w.status != 'Selesai').length;
    final totalValue = provider.workOrders.fold(0.0, (sum, w) => sum + w.totalManufacturedValue);

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
                    'Manufaktur & Formula BOM',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Formula perakitan bahan baku, surat perintah kerja (SPK) otomatis, dan pembongkaran produk',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddWoDialog(context, provider),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('+ Rilis SPK Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.manufacturing,
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
                title: 'SPK Perakitan Aktif',
                value: '$activeWo Perintah',
                trend: '${provider.workOrders.length} Total',
                trendLabel: 'Line Produksi Berjalan',
                trendUp: true,
                icon: Icons.precision_manufacturing_outlined,
                iconColor: AppColors.manufacturing,
              );
              final card2 = KpiCard(
                title: 'Total Valuasi Produksi',
                value: Formatters.compactCurrency(totalValue),
                trend: '+18.5%',
                trendLabel: 'Bulan Berjalan',
                trendUp: true,
                icon: Icons.account_tree_outlined,
                iconColor: AppColors.primary,
              );
              final card3 = KpiCard(
                title: 'Formula BOM Terdaftar',
                value: '${provider.boms.length} Formula',
                trend: 'Standar HPP',
                trendLabel: 'Siap Produksi',
                trendUp: true,
                icon: Icons.fact_check_outlined,
                iconColor: AppColors.success,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTabButton('wo', 'SPK Perakitan (Work Orders)', Icons.build_circle_outlined),
                const SizedBox(width: 8),
                _buildTabButton('bom', 'Formula BOM (Bill of Materials)', Icons.schema_outlined),
                const SizedBox(width: 8),
                _buildTabButton('disassembly', 'SPK Pembongkaran (Disassembly)', Icons.recycling_outlined),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Content
          if (_activeTab == 'wo') _buildWoTable(context, provider),
          if (_activeTab == 'bom') _buildBomCards(context, provider),
          if (_activeTab == 'disassembly') _buildDisassemblyTable(context, provider),
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

  Widget _buildWoTable(BuildContext context, AppProvider provider) {
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
                  'Daftar Surat Perintah Kerja (SPK) Perakitan',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${provider.workOrders.length} SPK Tercatat',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              headingTextStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted),
              dataTextStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.secondary),
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('No. SPK')),
                DataColumn(label: Text('Kode BOM')),
                DataColumn(label: Text('Barang Jadi')),
                DataColumn(label: Text('Progress Produksi')),
                DataColumn(label: Text('Target Gudang')),
                DataColumn(label: Text('Supervisor')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Aksi Alur Produksi')),
              ],
              rows: provider.workOrders.map((wo) {
                final isDone = wo.status == 'Selesai';
                final inProgress = wo.status == 'Proses Perakitan';
                final pct = (wo.progress * 100).toInt();

                return DataRow(cells: [
                  DataCell(Text(wo.woNumber, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  DataCell(Text(wo.bomCode, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.manufacturing))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(wo.finishedGoodName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(wo.finishedGoodSku, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${wo.quantityCompleted}/${wo.quantityPlanned}', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600)),
                              Text('$pct%', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: isDone ? AppColors.success : AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: wo.progress,
                            backgroundColor: AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(isDone ? AppColors.success : AppColors.primary),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(wo.targetWarehouseName, style: const TextStyle(fontSize: 12))),
                  DataCell(Text(wo.assignedSupervisor, style: const TextStyle(fontSize: 12))),
                  DataCell(
                    StatusBadge(
                      label: wo.status,
                      type: isDone ? 'success' : inProgress ? 'info' : 'warning',
                    ),
                  ),
                  DataCell(
                    isDone
                        ? const Text('✓ Produksi Selesai', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 12))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!inProgress)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    provider.startWorkOrder(wo.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('SPK ${wo.woNumber} dimulai! Stok bahan baku otomatis terpotong.'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.play_arrow, size: 14),
                                  label: const Text('Mulai'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                              if (inProgress)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    provider.completeWorkOrder(wo.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('SPK ${wo.woNumber} selesai! +${wo.quantityPlanned} Unit barang jadi masuk gudang.'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.check, size: 14),
                                  label: const Text('Selesai'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    backgroundColor: AppColors.success,
                                  ),
                                ),
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

  Widget _buildBomCards(BuildContext context, AppProvider provider) {
    return Column(
      children: provider.boms.map((bom) {
        return ErpCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.manufacturing.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.schema_outlined, color: AppColors.manufacturing, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(bom.finishedGoodName, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(bom.bomCode, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ),
                            ],
                          ),
                          Text(
                            'SKU: ${bom.finishedGoodSku} • Output: ${bom.outputQty} ${bom.outputUnit}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success.withAlpha(60)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Estimasi HPP Satuan', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
                        Text(
                          Formatters.currency(bom.totalProductionCostPerUnit),
                          style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF065F46)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text('Daftar Bahan Baku & Komponen (Bill of Materials):', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(4),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: AppColors.bgApp),
                    children: [
                      _th('Kode SKU'),
                      _th('Nama Komponen'),
                      _th('Jumlah'),
                      _th('Biaya Satuan'),
                      _th('Total Biaya'),
                    ],
                  ),
                  ...bom.components.map((c) => TableRow(
                        children: [
                          _td(c.sku, isMono: true),
                          _td(c.name),
                          _td('${c.quantity} ${c.unit}'),
                          _td(Formatters.currency(c.unitCost)),
                          _td(Formatters.currency(c.totalCost), isBold: true),
                        ],
                      )),
                ],
              ),
              const SizedBox(height: 12),
              // Cost breakdown summary row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _costPill('Bahan Baku', Formatters.currency(bom.totalMaterialCost)),
                  const SizedBox(width: 8),
                  _costPill('Tenaga Kerja', Formatters.currency(bom.directLaborCost)),
                  const SizedBox(width: 8),
                  _costPill('Overhead', Formatters.currency(bom.overheadCost)),
                  const SizedBox(width: 8),
                  _costPill('Total HPP', Formatters.currency(bom.totalProductionCost), isHighlight: true),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _costPill(String title, String val, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primary : AppColors.bgApp,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isHighlight ? AppColors.primary : AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$title: ', style: TextStyle(fontSize: 11, color: isHighlight ? Colors.white70 : AppColors.textMuted)),
          Text(val, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: isHighlight ? Colors.white : AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildDisassemblyTable(BuildContext context, AppProvider provider) {
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text(
              'Riwayat SPK Pembongkaran (Salvage & De-kustomisasi)',
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.bgApp),
              columns: const [
                DataColumn(label: Text('No. DO')),
                DataColumn(label: Text('Produk Dibongkar')),
                DataColumn(label: Text('Jumlah')),
                DataColumn(label: Text('Alasan Pembongkaran')),
                DataColumn(label: Text('Nilai Salvage Pulih')),
                DataColumn(label: Text('Inspektur')),
                DataColumn(label: Text('Status')),
              ],
              rows: provider.disassemblyOrders.map((d) => DataRow(cells: [
                    DataCell(Text(d.doNumber, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    DataCell(Text(d.sourceName, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text('${d.quantity} ${d.unit}')),
                    DataCell(Text(d.reason)),
                    DataCell(Text(Formatters.currency(d.totalRecoveryValue), style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700, color: AppColors.success))),
                    DataCell(Text(d.inspector)),
                    DataCell(StatusBadge(label: d.status, type: 'success')),
                  ])).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
    );
  }

  Widget _td(String val, {bool isMono = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        val,
        style: isMono
            ? GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)
            : GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400),
      ),
    );
  }

  void _showAddWoDialog(BuildContext context, AppProvider provider) {
    String selectedBomId = provider.boms.first.id;
    int qty = 20;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            final bom = provider.boms.firstWhere((b) => b.id == selectedBomId);

            return AlertDialog(
              title: Text('Rilis Surat Perintah Kerja (SPK) Baru', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pilih Formula BOM:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedBomId,
                      items: provider.boms.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.bomCode} - ${b.finishedGoodName}'))).toList(),
                      onChanged: (val) {
                        if (val != null) setDlgState(() => selectedBomId = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Target Jumlah Rakit:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: qty.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(suffixText: 'Unit'),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed > 0) setDlgState(() => qty = parsed);
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgApp,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimasi Nilai Hasil Manufaktur:', style: TextStyle(fontSize: 11)),
                              Text(
                                Formatters.currency(bom.totalProductionCostPerUnit * qty),
                                style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    final newWo = WorkOrderAssembly(
                      id: 'wo-${DateTime.now().millisecondsSinceEpoch}',
                      woNumber: 'SPK-2026-${provider.workOrders.length + 42}',
                      bomId: bom.id,
                      bomCode: bom.bomCode,
                      finishedGoodSku: bom.finishedGoodSku,
                      finishedGoodName: bom.finishedGoodName,
                      quantityPlanned: qty,
                      quantityCompleted: 0,
                      status: 'Terjadwal',
                      startDate: DateTime.now(),
                      targetWarehouseName: 'Gudang Barang Jadi (Finished Goods)',
                      estimatedLaborCost: bom.directLaborCost * qty,
                      totalManufacturedValue: bom.totalProductionCostPerUnit * qty,
                      assignedSupervisor: 'Ahmad Fauzi (Plant Lead)',
                    );
                    provider.addWorkOrder(newWo);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('SPK ${newWo.woNumber} berhasil dirilis!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Rilis SPK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
