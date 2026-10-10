import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/models/sql_models.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/resizable_panel.dart';
import '../../widgets/common/resizable_table.dart';

class PurchasingFormScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String? targetId;
  const PurchasingFormScreen({super.key, required this.onBack, this.targetId});

  @override
  State<PurchasingFormScreen> createState() => _PurchasingFormScreenState();
}

class _PurchasingFormScreenState extends State<PurchasingFormScreen> {
  String _activeTab = 'utama';
  String _selectedVendor = '';
  String _selectedWarehouse = '';
  final _indukCtrl = TextEditingController(text: 'Jl. Industri Raya No. 12');
  final _staffCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController(text: '30 HARI');
  final _tempoValCtrl = TextEditingController(text: '30');
  final _dateCtrl = TextEditingController(text: '2026-09-22');
  final _shipDateCtrl = TextEditingController(text: '2026-09-24');
  final _dueDateCtrl = TextEditingController(text: '2026-10-22');
  final _keteranganCtrl = TextEditingController();
  final _nomorNotaCtrl = TextEditingController(text: 'PO-2026-006');
  final _notesCtrl = TextEditingController();
  bool _termasukPpn = true;
  bool _tambahBaris = true;
  bool _langsungCetak = true;
  bool _discPersen = false;
  PurchaseOrder? _existing;
  String _modelLabel = '1';
  String _kurs = 'IDR';
  String _modelProduk = 'Semua Produk';
  final _rateCtrl = TextEditingController(text: '1');
  final Map<String, TextEditingController> _lainCtrls = {};

  final List<_LineItem> _items = [_LineItem()];

  double get _subtotal => _items.fold(0, (s, i) => s + i.jumlah);
  double get _ppn => _termasukPpn ? _subtotal * 0.11 : 0;
  double get _grandTotal => _subtotal + _ppn;

  List<String> get _vendors {
    final list = context.read<AppProvider>().vendors.map((v) => v.name).toList();
    return list.isNotEmpty ? list : [''];
  }

  List<String> get _warehouses {
    final list = context.read<AppProvider>().warehouses.map((w) => w.name).toList();
    return list.isNotEmpty ? list : [''];
  }

  List<String> get _staffs {
    final list = context.read<AppProvider>().employees.map((e) => e.name).toList();
    return list.isNotEmpty ? list : [''];
  }

  @override
  void dispose() {
    for (final c in [_indukCtrl, _staffCtrl, _tempoCtrl, _tempoValCtrl, _dateCtrl, _shipDateCtrl, _dueDateCtrl, _keteranganCtrl, _nomorNotaCtrl, _notesCtrl, _rateCtrl, ..._lainCtrls.values]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmtDate(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  TextEditingController _lainCtrl(String key, [String initial = '']) =>
      _lainCtrls.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateCtrl.text = _fmtDate(now);
    _shipDateCtrl.text = _fmtDate(now.add(const Duration(days: 2)));
    _dueDateCtrl.text = _fmtDate(now.add(const Duration(days: 30)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      if (widget.targetId != null) {
        final existing = provider.purchaseOrders.where((p) => p.id == widget.targetId).firstOrNull;
        if (existing != null) {
          setState(() {
            _existing = existing;
            _dateCtrl.text = _fmtDate(existing.date);
            _nomorNotaCtrl.text = existing.id;
            _selectedVendor = existing.vendor;
            _selectedWarehouse = existing.warehouse;
            _termasukPpn = false;
            _items.clear();
            _items.add(_LineItem()
              ..produkCtrl.text = 'Produk Pembelian'
              ..hargaCtrl.text = existing.amount.toStringAsFixed(0)
              ..pajak = '-');
            _items[0].updateJumlah();
          });
        }
      } else {
        if (provider.vendors.isNotEmpty) {
          setState(() => _selectedVendor = provider.vendors.first.name);
        }
        if (provider.warehouses.isNotEmpty) {
          setState(() => _selectedWarehouse = provider.warehouses.first.name);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color _canvasColor = isDark ? const Color(0xFF11171D) : const Color(0xFFF6F8FA);

    return Column(
      children: [
        _buildPageHeader(isDark),
        _buildTabNav(isDark),
        Expanded(
          child: Container(
            color: _canvasColor,
            child: _activeTab == 'utama' ? _buildUtamaTab(isDark)
              : _activeTab == 'lain' ? _buildLainTab(isDark)
              : _buildHistoryTab(isDark),
          ),
        ),
        _buildFooterBar(isDark),
      ],
    );
  }

  Widget _buildPageHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF2563EB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: widget.onBack,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Pembelian', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Faktur Pembelian Baru', style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), 
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.3))
                        ),
                        child: Text(_existing != null ? _existing!.status.toUpperCase() : 'DRAFT', style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () => context.read<AppProvider>().openNewForm('purchasing'),
            icon: const Icon(Icons.add, size: 14, color: Colors.white),
            label: Text('Tab Form Baru', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNav(bool isDark) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _bgCard = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final tabs = [('utama', 'Informasi Utama'), ('lain', 'Informasi Tambahan'), ('history', 'Riwayat Dokumen')];

    return Container(
      color: _bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: tabs.map((t) {
          final isActive = _activeTab == t.$1;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = t.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isActive ? _primaryColor : Colors.transparent, width: 2)),
              ),
              child: Text(t.$2, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? _primaryColor : _textSecondary)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUtamaTab(bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;
            
            final col1 = ErpCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.business_outlined, size: 18, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text('Informasi Vendor', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildF3Search('Nama Supplier', initial: _selectedVendor, options: _vendors, onChanged: (v) => _selectedVendor = v, isDark: isDark),
                  const SizedBox(height: 16),
                  _buildF3Search('Perusahaan Induk', initial: _indukCtrl.text, options: _vendors, onChanged: (v) => _indukCtrl.text = v, isDark: isDark),
                  const SizedBox(height: 16),
                  _buildF3Search('Staff Pembelian', initial: _staffCtrl.text, options: _staffs, onChanged: (v) => _staffCtrl.text = v, isDark: isDark),
                  const SizedBox(height: 16),
                  _overlayField('Termin Pembayaran', child: Row(children: [
                    Expanded(child: TextField(controller: _tempoCtrl, decoration: _inputDeco('30 HARI...', isDark), style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary))),
                    const SizedBox(width: 8),
                    SizedBox(width: 70, child: TextField(controller: _tempoValCtrl, textAlign: TextAlign.center, decoration: _inputDeco('30', isDark), style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary))),
                  ]), isDark: isDark),
                ],
              ),
            );

            final col2 = ErpCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 18, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text('Informasi Dokumen PO', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _overlayField('Nomor PO', child: TextField(controller: _nomorNotaCtrl, decoration: _inputDeco('PO-XXXX-XXX', isDark), style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary)), isDark: isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildF3Search('Gudang Tujuan', initial: _selectedWarehouse, options: _warehouses, onChanged: (v) => _selectedWarehouse = v, isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _overlayField('Tgl. Input', child: _dateInput(_dateCtrl, isDark), isDark: isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _overlayField('Tgl. Kirim', child: _dateInput(_shipDateCtrl, isDark), isDark: isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _overlayField('Tgl. Jatem', child: _dateInput(_dueDateCtrl, isDark), isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _overlayField('Keterangan', child: TextField(controller: _keteranganCtrl, maxLines: 2, decoration: _inputDeco('Keterangan dokumen...', isDark), style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary)), isDark: isDark),
                ],
              ),
            );

            if (isMobile) {
              return Column(children: [col1, const SizedBox(height: 24), col2]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: col1),
                const SizedBox(width: 24),
                Expanded(child: col2),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        
        // Product Table
        ErpCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Text('Daftar Produk yang Dipesan', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
              ),
              Divider(height: 1, color: _borderColor),
              ResizableTable(
                headers: const ['Produk', 'Deskripsi', 'Qty', 'Unit', 'Harga Satuan', 'Diskon', 'Pajak', 'Jumlah', ''],
                initialFlexes: const [2.5, 2.0, 1.0, 1.0, 1.8, 1.0, 1.5, 1.8, 0.5],
                minTableWidth: 1000,
                rowCount: _items.length,
                        cellBuilder: (context, r, c) {
                          final item = _items[r];
                          switch (c) {
                            case 0: return _tdInput(item.produkCtrl, 'Pilih produk...', isDark, onChanged: (_) => setState(() {}));
                            case 1: return _tdInput(item.deskCtrl, 'Deskripsi...', isDark);
                            case 2: return _tdInput(item.qtyCtrl, '0', isDark, isNumber: true, onChanged: (_) => setState(() { item.updateJumlah(); }));
                            case 3: return _tdInput(item.unitCtrl, 'Pcs', isDark);
                            case 4: return _tdInput(item.hargaCtrl, '0', isDark, isNumber: true, onChanged: (_) => setState(() { item.updateJumlah(); }));
                            case 5: return _tdInput(item.discCtrl, '0', isDark, isNumber: true, onChanged: (_) => setState(() { item.updateJumlah(); }));
                            case 6: return Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: DropdownButtonFormField<String>(
                                        value: item.pajak,
                                        dropdownColor: isDark ? const Color(0xFF25303A) : const Color(0xFFFFFFFF),
                                        isDense: true,
                                        style: GoogleFonts.ibmPlexSans(fontSize: 12, color: _textPrimary),
                                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8)),
                                        onChanged: (v) => setState(() { item.pajak = v!; item.updateJumlah(); }),
                                        items: const [
                                          DropdownMenuItem(value: 'PPN', child: Text('PPN')),
                                          DropdownMenuItem(value: '-', child: Text('-')),
                                        ],
                                      ),
                                    );
                            case 7: return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                                      child: Text(Formatters.currency(item.jumlah), style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary), overflow: TextOverflow.ellipsis),
                                    );
                            case 8: return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: IconButton(
                                        icon: Icon(Icons.close, size: 16, color: isDark ? const Color(0xFFE55353) : const Color(0xFFB3363B)),
                                        onPressed: _items.length > 1 ? () => setState(() => _items.removeAt(r)) : null,
                                      ),
                                    );
                            default: return const SizedBox();
                          }
                        },
                      ),
              InkWell(
                onTap: () => setState(() => _items.add(_LineItem())),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text('Tambah Baris Produk', style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _primaryColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Calc + Notes
        ErpCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              
              final notes = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Catatan Tambahan', style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
                  decoration: _inputDeco('Catatan atau memo pesanan...', isDark),
                ),
              ]);
              
              final calc = SizedBox(
                width: isMobile ? double.infinity : 320,
                child: Column(children: [
                  _calcRow('Subtotal:', Formatters.currency(_subtotal), false, isDark),
                  const SizedBox(height: 12),
                  _calcRow('PPN (11%):', Formatters.currency(_ppn), false, isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: _borderColor),
                  ),
                  _calcRow('Total PO:', Formatters.currency(_grandTotal), true, isDark, color: _primaryColor),
                ]),
              );
              
              if (isMobile) {
                return Column(children: [notes, const SizedBox(height: 24), calc]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: notes), const SizedBox(width: 48), calc],
              );
            },
          ),
        ),
      ]),
    );
  }

  // Removed TableRow _buildItemRow since it's replaced by cellBuilder

  Widget _buildLainTab(bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          
          final mainInfo = Column(
            children: [
              ErpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 18, color: _primaryColor),
                        const SizedBox(width: 8),
                        Text('Pengiriman & Logistik', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 24, runSpacing: 16,
                      children: [
                        _lainField('Expedisi [F3]', isDark: isDark),
                        _lainField('Nomor Resi', isDark: isDark),
                        _lainField('Telp [F3] (1)', isDark: isDark),
                        _lainField('Telp [F3] (2)', isDark: isDark),
                        _lainField('Kontak [F3] (1)', isDark: isDark),
                        _lainField('Kontak [F3] (2)', isDark: isDark),
                        _lainField('Alamat [F3]', full: true, isDark: isDark),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ErpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 18, color: _primaryColor),
                        const SizedBox(width: 8),
                        Text('Keuangan & Giro', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 24, runSpacing: 16,
                      children: [
                        _lainFieldWidget('Disc Group ⚡', TextField(
                          decoration: _inputDeco('0.00', isDark),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.ibmPlexSans(color: isDark ? const Color(0xFFE55353) : const Color(0xFFB3363B), fontWeight: FontWeight.w600, fontSize: 13),
                        ), isDark: isDark),
                        _lainField('Nomor Giro', isDark: isDark),
                        _lainFieldWidget('Tgl. Giro Jatem', _dateInput(_lainCtrl('Tgl. Giro Jatem'), isDark), isDark: isDark),
                        _lainFieldWidget('Tgl. Giro Cair', _dateInput(_lainCtrl('Tgl. Giro Cair'), isDark), isDark: isDark),
                        _lainField('Rekening [F3]', full: true, isDark: isDark),
                      ],
                    ),
                  ],
                ),
              ),
            ]
          );

          final sideInfo = Column(
            children: [
              ErpCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune_outlined, size: 18, color: _primaryColor),
                        const SizedBox(width: 8),
                        Text('Data Internal', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _lainField('Sumber [F3]', full: true, isDark: isDark),
                    const SizedBox(height: 16),
                    _lainFieldWidget('Model Label', DropdownButtonFormField<String>(
                      value: _modelLabel, isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF25303A) : const Color(0xFFFFFFFF),
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, color: isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D)),
                      decoration: _dropDeco('', isDark),
                      onChanged: (v) => setState(() => _modelLabel = v ?? _modelLabel),
                      items: ['1', '2', '3'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                    ), isDark: isDark),
                    const SizedBox(height: 16),
                    _lainField('C.CTR [F3]', initial: 'MAIN STORE', full: true, isDark: isDark),
                    const SizedBox(height: 16),
                    _lainField('Warehouse [F3]', initial: 'G001', full: true, isDark: isDark),
                    const SizedBox(height: 16),
                    _lainFieldWidget('Kurs [F3]', Row(children: [
                      SizedBox(width: 100, child: DropdownButtonFormField<String>(
                        value: _kurs, isDense: true,
                        dropdownColor: isDark ? const Color(0xFF25303A) : const Color(0xFFFFFFFF),
                        style: GoogleFonts.ibmPlexSans(fontSize: 13, color: isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D)),
                        decoration: _dropDeco('', isDark),
                        onChanged: (v) => setState(() => _kurs = v ?? _kurs),
                        items: ['IDR', 'USD', 'EUR', 'SGD'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(decoration: _inputDeco('Rate...', isDark), style: GoogleFonts.ibmPlexSans(fontSize: 13, color: isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D)), controller: _rateCtrl, keyboardType: TextInputType.number)),
                    ]), isDark: isDark),
                    const SizedBox(height: 16),
                    _lainField('Max Baris', initial: '100', full: true, isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ErpCard(
                child: _buildLainCheckboxes(isDark),
              ),
            ]
          );

          if (isMobile) {
            return Column(children: [mainInfo, const SizedBox(height: 24), sideInfo]);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: mainInfo),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: sideInfo),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLainCheckboxes(bool isDark) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Icon(Icons.settings_outlined, size: 18, color: _primaryColor),
          const SizedBox(width: 8),
          Text('Pengaturan Lanjut', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
        ],
      ),
      const SizedBox(height: 20),
      Text('Model Produk', style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _radio('Jasa', isDark), _radio('Komersial', isDark), _radio('Semua Produk', isDark),
        ],
      ),
      const SizedBox(height: 20),
      Text('Opsi Cetak & Kalkulasi', style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary)),
      const SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _checkbox('Harga sudah termasuk PPN', _termasukPpn, (v) => setState(() => _termasukPpn = v!), isDark),
          _checkbox('Otomatis tambah baris baru', _tambahBaris, (v) => setState(() => _tambahBaris = v!), isDark),
          _checkbox('Cetak resi otomatis setelah simpan', _langsungCetak, (v) => setState(() => _langsungCetak = v!), isDark),
          _checkbox('Terapkan diskon dalam mode Persen (%)', _discPersen, (v) => setState(() => _discPersen = v!), isDark),
        ],
      ),
    ]);
  }

  Widget _buildHistoryTab(bool isDark) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.history_rounded, size: 64, color: isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6)),
        const SizedBox(height: 16),
        Text('Belum ada riwayat untuk dokumen ini.', style: GoogleFonts.ibmPlexSans(fontSize: 14, color: isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D))),
      ]),
    );
  }

  Widget _buildFooterBar(bool isDark) {
    final Color _bgCard = isDark ? const Color(0xFF1A222A) : const Color(0xFFFFFFFF);
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border(top: BorderSide(color: _borderColor)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: widget.onBack,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
            child: Text('Batal', style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D))),
          ),
          Row(children: [
            OutlinedButton(
              onPressed: _simpanDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: BorderSide(color: _primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              child: const Text('Simpan Draft'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _simpanDanTerbitkan,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              child: const Text('Simpan & Terbitkan'),
            ),
          ]),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFE55353), behavior: SnackBarBehavior.floating));
  }

  void _commit({required String status, required String message}) {
    final inv = PurchaseOrder(
      id: _nomorNotaCtrl.text.trim(),
      date: DateTime.tryParse(_dateCtrl.text) ?? _existing?.date ?? DateTime.now(),
      vendor: _selectedVendor,
      warehouse: _selectedWarehouse,
      amount: _grandTotal,
      status: status,
    );

    // Create Trans object mapping from the form
    final trans = Trans(
      transNomornota: inv.id,
      transEntrydate: (inv.date.millisecondsSinceEpoch / 1000).round(),
      transText: inv.vendor,
      masterwarehouseId: inv.warehouse,
      transNilaikurs: inv.amount,
      transType: 2, // 2 for purchases
    );

    // Create Transline objects from items
    final lines = _items.map((item) => Transline(
      translineKeterangan: item.produkCtrl.text,
      translineQty: double.tryParse(item.qtyCtrl.text) ?? 0.0,
      translinePrice: double.tryParse(item.hargaCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      translineTotaldiscvalue: double.tryParse(item.discCtrl.text) ?? 0.0,
      translineNetvalue: item.jumlah,
    )).toList();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF28A745),
      behavior: SnackBarBehavior.floating,
    ));
    
    // Save to local and backend
    context.read<AppProvider>().addPurchaseOrder(inv);
    context.read<AppProvider>().savePurchaseTransaction(trans, lines: lines);
    
    context.read<AppProvider>().switchModule('purchasing');
    widget.onBack();
  }

  void _simpanDraft() {
    if (_existing != null && _existing!.status != 'Draft') {
      _showError('Faktur ini sudah terbit (${_existing!.status}). Gunakan "Simpan & Terbitkan" untuk menyimpan perubahan.');
      return;
    }
    if (_selectedVendor.trim().isEmpty) return _showError('Vendor wajib diisi.');
    if (_nomorNotaCtrl.text.trim().isEmpty) return _showError('Nomor nota wajib diisi.');
    _commit(status: 'Draft', message: 'Draft ${_nomorNotaCtrl.text.trim()} tersimpan.');
  }

  void _simpanDanTerbitkan() {
    final hasItem = _items.any((i) => i.produkCtrl.text.trim().isNotEmpty && i.jumlah > 0);
    if (_selectedVendor.trim().isEmpty) return _showError('Vendor wajib diisi.');
    if (_nomorNotaCtrl.text.trim().isEmpty) return _showError('Nomor nota wajib diisi.');
    if (!hasItem) return _showError('Isi minimal satu baris produk dengan qty dan harga lebih dari 0.');
    final keep = _existing != null && _existing!.status != 'Draft';
    _commit(
      status: keep ? _existing!.status : 'Selesai Diterima', // Default untuk PO baru yang diterbitkan = Masuk/Selesai
      message: 'Faktur ${_nomorNotaCtrl.text.trim()} berhasil ${keep ? 'diperbarui' : 'diterbitkan'}.',
    );
  }

  // ---- Helpers ----

  Widget _overlayField(String label, {required Widget child, required bool isDark}) {
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: _textSecondary)),
      const SizedBox(height: 6),
      child,
    ]);
  }

  Widget _dateInput(TextEditingController ctrl, bool isDark) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    return TextField(
      controller: ctrl,
      readOnly: true,
      style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
      decoration: _inputDeco('YYYY-MM-DD', isDark).copyWith(suffixIcon: Icon(Icons.calendar_today_outlined, size: 16, color: _primaryColor)),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) setState(() => ctrl.text = _fmtDate(picked));
      },
    );
  }

  Widget _lainField(String label, {String? initial, bool full = false, required bool isDark}) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    Widget childWidget;
    if (label.contains('[F3]')) {
      final options = ['Data A', 'Data B', 'Data C', 'Hasil Pencarian...'];
      childWidget = Autocomplete<String>(
        initialValue: TextEditingValue(text: initial ?? ''),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) return options;
          return options.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        },
        fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
          return TextField(
            controller: controller, focusNode: focusNode, onEditingComplete: onEditingComplete,
            decoration: _inputDeco('Ketik & cari...', isDark).copyWith(suffixIcon: Icon(Icons.search, size: 16, color: _primaryColor)),
            style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
          );
        },
      );
    } else {
      childWidget = TextField(controller: _lainCtrl(label, initial ?? ''), style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary), decoration: _inputDeco('Input...', isDark));
    }
    return SizedBox(
      width: full ? double.infinity : 240,
      child: _overlayField(label, child: childWidget, isDark: isDark),
    );
  }

  Widget _buildF3Search(String label, {String? initial, List<String>? options, ValueChanged<String>? onChanged, required bool isDark}) {
    final opts = options ?? ['Data A', 'Data B', 'Data C', 'Hasil Pencarian...'];
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    return _overlayField(label, isDark: isDark, child: Autocomplete<String>(
      initialValue: TextEditingValue(text: initial ?? ''),
      onSelected: (v) => onChanged?.call(v),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return opts;
        return opts.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextField(
          controller: controller, focusNode: focusNode, onEditingComplete: onEditingComplete,
          onChanged: (v) => onChanged?.call(v),
          decoration: _inputDeco('Ketik & cari...', isDark).copyWith(suffixIcon: Icon(Icons.search, size: 16, color: _primaryColor)),
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
        );
      },
    ));
  }

  Widget _lainFieldWidget(String label, Widget child, {required bool isDark}) {
    return SizedBox(
      width: 240,
      child: _overlayField(label, child: child, isDark: isDark),
    );
  }

  Widget _radio(String label, bool isDark) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(value: label, groupValue: _modelProduk, onChanged: (v) => setState(() => _modelProduk = v ?? _modelProduk), activeColor: _primaryColor),
      Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary)),
    ]);
  }

  Widget _checkbox(String label, bool value, Function(bool?) onChanged, bool isDark) {
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(value: value, onChanged: onChanged, activeColor: _primaryColor, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary)),
    ]);
  }

  Widget _calcRow(String label, String value, bool bold, bool isDark, {Color? color}) {
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.ibmPlexSans(fontSize: bold ? 14 : 13, color: bold ? _textPrimary : _textSecondary, fontWeight: bold ? FontWeight.w600 : FontWeight.w500)),
      Text(value, style: GoogleFonts.ibmPlexSans(fontSize: bold ? 18 : 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: color ?? _textPrimary)),
    ]);
  }

  // Removed _thCell

  Widget _tdInput(TextEditingController ctrl, String hint, bool isDark, {bool isNumber = false, Function(String)? onChanged}) {
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        style: GoogleFonts.ibmPlexSans(fontSize: 12, color: _textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.ibmPlexSans(fontSize: 12, color: isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, bool isDark) {
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.ibmPlexSans(fontSize: 13, color: isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _primaryColor, width: 1.5)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  InputDecoration _dropDeco(String hint, bool isDark) {
    return _inputDeco(hint, isDark);
  }
}

class _LineItem {
  final produkCtrl = TextEditingController();
  final deskCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final unitCtrl = TextEditingController(text: 'Pcs');
  final hargaCtrl = TextEditingController(text: '0');
  final discCtrl = TextEditingController(text: '0');
  String pajak = 'PPN';
  double jumlah = 0;

  void updateJumlah() {
    final qty = double.tryParse(qtyCtrl.text) ?? 0;
    final harga = double.tryParse(hargaCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final disc = double.tryParse(discCtrl.text) ?? 0;
    jumlah = qty * harga * (1 - disc / 100);
  }
}
