import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/app_models.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/status_badge.dart';

class SettingsModule extends StatefulWidget {
  const SettingsModule({super.key});
  @override State<SettingsModule> createState() => _SettingsModuleState();
}

class _SettingsModuleState extends State<SettingsModule> {
  String _activeTab = 'produk';
  final _tabs = ['Produk / SKU', 'Pelanggan', 'Vendor / Pemasok', 'Gudang', 'Pengguna', 'Unit Bisnis', 'Tema & Tampilan'];
  final _tabIds = ['produk', 'pelanggan', 'vendor', 'gudang', 'pengguna', 'bisnis', 'tema'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pengaturan Sistem', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
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
        const SizedBox(height: 20),
        _buildTabContent(),
      ]),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'produk': return _ProductsTab();
      case 'pelanggan': return _CustomersTab();
      case 'vendor': return _VendorsTab();
      case 'gudang': return _WarehouseTab();
      case 'tema': return const _ThemeTab();
      default: return _ComingSoonTab(label: _tabs[_tabIds.indexOf(_activeTab)]);
    }
  }
}

class _ProductsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Manajemen Produk & SKU', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            ElevatedButton(onPressed: () => _showAddProduct(context), child: const Text('+ Tambah Produk')),
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
              DataColumn(label: Text('Kode SKU')),
              DataColumn(label: Text('Nama Produk')),
              DataColumn(label: Text('Kategori')),
              DataColumn(label: Text('Satuan')),
              DataColumn(label: Text('Harga Jual'), numeric: true),
              DataColumn(label: Text('Stok'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Aksi')),
            ],
            rows: provider.products.map((p) => DataRow(cells: [
              DataCell(Text(p.sku, style: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
              DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(p.category)),
              DataCell(Text(p.unit)),
              DataCell(Text(Formatters.currency(p.salePrice), style: const TextStyle(fontWeight: FontWeight.w700))),
              DataCell(Text('${p.stock}')),
              DataCell(StatusBadge(label: p.isActive ? 'Aktif' : 'Nonaktif', type: p.isActive ? 'success' : 'muted')),
              DataCell(Row(children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}, color: AppColors.textMuted),
                IconButton(icon: const Icon(Icons.delete_outline, size: 16), onPressed: () => provider.deleteProduct(p.sku), color: AppColors.danger),
              ])),
            ])).toList(),
          ),
        ),
      ]),
    );
  }

  void _showAddProduct(BuildContext context) {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'Pcs');
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();

    showDialog(context: context, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Tambah Produk Baru', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
          ]),
          const Divider(height: 24),
          _field('Nama Produk', nameCtrl, 'Nama produk'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field('Kategori', catCtrl, 'Kategori')),
            const SizedBox(width: 12),
            Expanded(child: _field('Satuan', unitCtrl, 'Unit')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field('Harga Jual', priceCtrl, '0', keyboard: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _field('Stok Awal', stockCtrl, '0', keyboard: TextInputType.number)),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  final now = DateTime.now();
                  context.read<AppProvider>().addProduct(ProductSku(
                    sku: 'SKU-NEW-${now.millisecondsSinceEpoch % 1000}',
                    name: nameCtrl.text, category: catCtrl.text, unit: unitCtrl.text,
                    salePrice: double.tryParse(priceCtrl.text) ?? 0,
                    stock: int.tryParse(stockCtrl.text) ?? 0,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Simpan'),
            ),
          ]),
        ]),
      ),
    ));
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {TextInputType keyboard = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, keyboardType: keyboard, decoration: InputDecoration(hintText: hint), style: GoogleFonts.inter(fontSize: 14)),
    ]);
  }
}

class _CustomersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Manajemen Pelanggan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            ElevatedButton(onPressed: () {}, child: const Text('+ Tambah Pelanggan')),
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
              DataColumn(label: Text('Kode')),
              DataColumn(label: Text('Nama Perusahaan')),
              DataColumn(label: Text('Kontak')),
              DataColumn(label: Text('Kota')),
              DataColumn(label: Text('Tipe')),
              DataColumn(label: Text('Limit Kredit'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Aksi')),
            ],
            rows: provider.customers.map((c) => DataRow(cells: [
              DataCell(Text(c.code, style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
              DataCell(Text(c.companyName, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(c.contact, style: const TextStyle(fontSize: 12))),
              DataCell(Text(c.city)),
              DataCell(Text(c.type)),
              DataCell(Text(Formatters.compactCurrency(c.creditLimit))),
              DataCell(StatusBadge(label: c.isActive ? 'Aktif' : 'Nonaktif', type: c.isActive ? 'success' : 'muted')),
              DataCell(Row(children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}, color: AppColors.textMuted),
                IconButton(icon: const Icon(Icons.delete_outline, size: 16), onPressed: () => provider.deleteCustomer(c.code), color: AppColors.danger),
              ])),
            ])).toList(),
          ),
        ),
      ]),
    );
  }
}

class _VendorsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Manajemen Vendor / Pemasok', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            ElevatedButton(onPressed: () {}, child: const Text('+ Tambah Vendor')),
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
              DataColumn(label: Text('Kode')),
              DataColumn(label: Text('Nama Vendor')),
              DataColumn(label: Text('Kontak')),
              DataColumn(label: Text('Kota')),
              DataColumn(label: Text('Kategori Suplai')),
              DataColumn(label: Text('Lead Time')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Aksi')),
            ],
            rows: provider.vendors.map((v) => DataRow(cells: [
              DataCell(Text(v.code, style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
              DataCell(Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(v.contact, style: const TextStyle(fontSize: 12))),
              DataCell(Text(v.city)),
              DataCell(Text(v.supplyCategory)),
              DataCell(Text('${v.leadTimeDays} hari')),
              DataCell(StatusBadge(label: v.isActive ? 'Aktif' : 'Nonaktif', type: v.isActive ? 'success' : 'muted')),
              DataCell(Row(children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}, color: AppColors.textMuted),
                IconButton(icon: const Icon(Icons.delete_outline, size: 16), onPressed: () => provider.deleteVendor(v.code), color: AppColors.danger),
              ])),
            ])).toList(),
          ),
        ),
      ]),
    );
  }
}

class _WarehouseTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return ErpCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Manajemen Gudang', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            ElevatedButton(onPressed: () {}, child: const Text('+ Tambah Gudang')),
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
              DataColumn(label: Text('Kode')),
              DataColumn(label: Text('Nama Gudang')),
              DataColumn(label: Text('Lokasi')),
              DataColumn(label: Text('PIC')),
              DataColumn(label: Text('Kapasitas'), numeric: true),
              DataColumn(label: Text('Utilisasi')),
              DataColumn(label: Text('Status')),
            ],
            rows: provider.warehouses.map((w) => DataRow(cells: [
              DataCell(Text(w.code, style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
              DataCell(Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(SizedBox(width: 180, child: Text(w.location, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))),
              DataCell(Text(w.pic)),
              DataCell(Text('${w.capacity} palet')),
              DataCell(Row(children: [
                SizedBox(
                  width: 80,
                  child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
                    value: w.utilization / 100,
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(w.utilization > 85 ? AppColors.danger : w.utilization > 60 ? AppColors.warning : AppColors.success),
                    minHeight: 8,
                  )),
                ),
                const SizedBox(width: 8),
                Text('${w.utilization}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
              DataCell(StatusBadge(label: w.isActive ? 'Aktif' : 'Nonaktif', type: w.isActive ? 'success' : 'muted')),
            ])).toList(),
          ),
        ),
      ]),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String label;
  const _ComingSoonTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return ErpCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(children: [
            const Icon(Icons.construction_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('$label', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            const SizedBox(height: 8),
            Text('Fitur ini akan segera tersedia.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }
}

class _ThemeTab extends StatefulWidget {
  const _ThemeTab();
  @override
  State<_ThemeTab> createState() => _ThemeTabState();
}

class _ThemeTabState extends State<_ThemeTab> {
  bool _isDark = false;
  String _activeColor = 'blue';

  @override
  Widget build(BuildContext context) {
    return ErpCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tema & Tampilan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondary)),
          const SizedBox(height: 4),
          Text('Sesuaikan tampilan aplikasi dengan preferensi visual Anda', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
          const Divider(height: 32),
          
          Text('Mode Tampilan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildModeOption(
                title: 'Terang (Light)',
                icon: Icons.light_mode_rounded,
                isActive: !_isDark,
                onTap: () => setState(() => _isDark = false),
              ),
              const SizedBox(width: 16),
              _buildModeOption(
                title: 'Gelap (Dark)',
                icon: Icons.dark_mode_rounded,
                isActive: _isDark,
                onTap: () => setState(() => _isDark = true),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          Text('Warna Aksen Utama', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildColorOption('blue', const Color(0xFF194BFB)),
              const SizedBox(width: 16),
              _buildColorOption('green', const Color(0xFF10B981)),
              const SizedBox(width: 16),
              _buildColorOption('purple', const Color(0xFF8B5CF6)),
              const SizedBox(width: 16),
              _buildColorOption('orange', const Color(0xFFF97316)),
              const SizedBox(width: 16),
              _buildColorOption('slate', const Color(0xFF475569)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _showCustomColorDialog,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight, width: 2),
                    gradient: const SweepGradient(colors: [Colors.red, Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.red]),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Kembalikan Default')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Preferensi tema berhasil disimpan (Visual Preview)'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({required String title, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight, width: isActive ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: isActive ? AppColors.primary : AppColors.textMuted),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? AppColors.primary : AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String id, Color color) {
    final isActive = _activeColor == id;
    return GestureDetector(
      onTap: () => setState(() => _activeColor = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)] : [],
        ),
        child: isActive ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
      ),
    );
  }

  void _showCustomColorDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Warna Kustom', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan kode Hex (contoh: #FF5733):', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: '#...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _activeColor = 'custom');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warna kustom dipilih!')));
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}
