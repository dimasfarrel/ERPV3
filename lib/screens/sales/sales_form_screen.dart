import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/app_models.dart';
import '../../data/models/sql_models.dart';
import '../../data/models/master_models.dart';
import '../../widgets/common/erp_card.dart';
import '../../widgets/common/resizable_table.dart';
import '../../widgets/transaction/transaction_payment_dialog.dart';
import '../../widgets/transaction/invoice_print_dialog.dart';

class SalesFormScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String? targetId;
  const SalesFormScreen({super.key, required this.onBack, this.targetId});

  @override
  State<SalesFormScreen> createState() => _SalesFormScreenState();
}

class _SalesFormScreenState extends State<SalesFormScreen> {
  String _activeTab = 'utama';
  final _indukCtrl = TextEditingController(text: 'Jl. Raya Industri No. 5, Kepanjen');
  final _staffCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController(text: 'Termin 0 hari');
  final _tempoValCtrl = TextEditingController(text: '0');
  String? _selectedTerminId;
  final _dateCtrl = TextEditingController(text: '2026-09-22');
  final _customerCtrl = TextEditingController();
  final _warehouseCtrl = TextEditingController();

  String get _selectedCustomer => _customerCtrl.text;
  set _selectedCustomer(String v) => _customerCtrl.text = v;

  String get _selectedWarehouse => _warehouseCtrl.text;
  set _selectedWarehouse(String v) => _warehouseCtrl.text = v;

  final _shipDateCtrl = TextEditingController(text: '2026-09-24');
  final _dueDateCtrl = TextEditingController(text: '2026-10-22');
  final _keteranganCtrl = TextEditingController();
  final _nomorNotaCtrl = TextEditingController(text: 'INV-2026-006');
  final _notesCtrl = TextEditingController();
  final Map<String, FocusNode> _f3FocusNodes = {};

  FocusNode _getF3Focus(String key) => _f3FocusNodes.putIfAbsent(key, () => FocusNode());

  bool _termasukPpn = true;
  bool _tambahBaris = true;
  bool _langsungCetak = true;
  bool _discPersen = false;
  SalesInvoice? _existing;
  String _modelLabel = '1';
  String _kurs = 'IDR';
  String _modelProduk = 'Semua Produk';
  final _rateCtrl = TextEditingController(text: '1');
  final Map<String, TextEditingController> _lainCtrls = {};

  List<_LineItem> _items = [_LineItem()];

  double get _subtotal => _items.fold(0, (s, i) => s + i.jumlah);
  double get _ppn => _termasukPpn ? _subtotal * 0.11 : 0;
  double get _grandTotal => _subtotal + _ppn;

  List<String> get _customers {
    final list = context.read<AppProvider>().customers.map((c) => c.companyName).toList();
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
    for (final c in [_customerCtrl, _warehouseCtrl, _indukCtrl, _staffCtrl, _tempoCtrl, _tempoValCtrl, _dateCtrl, _shipDateCtrl, _dueDateCtrl, _keteranganCtrl, _nomorNotaCtrl, _notesCtrl, _rateCtrl, ..._lainCtrls.values]) {
      c.dispose();
    }
    for (final fn in _f3FocusNodes.values) {
      fn.dispose();
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
      provider.fetchDues();
      if (widget.targetId != null) {
        final existing = provider.salesInvoices.where((i) => i.id == widget.targetId).firstOrNull;
        if (existing != null) {
          setState(() {
            _existing = existing;
            _dateCtrl.text = _fmtDate(existing.date);
            _nomorNotaCtrl.text = existing.id;
            _customerCtrl.text = existing.customer;
            _warehouseCtrl.text = existing.warehouse;
            if (existing.staff != null && existing.staff!.isNotEmpty) {
              _staffCtrl.text = existing.staff!;
            }
            if (existing.termin != null && existing.termin!.isNotEmpty) {
              _tempoCtrl.text = existing.termin!;
              final days = int.tryParse(existing.termin!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              _tempoValCtrl.text = days.toString();
            }
            if (existing.notes != null && existing.notes!.isNotEmpty) {
              _notesCtrl.text = existing.notes!;
              _keteranganCtrl.text = existing.notes!;
            }
            if (existing.dueDate != null) {
              _dueDateCtrl.text = _fmtDate(existing.dueDate!);
            }
            if (existing.shippingDate != null) {
              _shipDateCtrl.text = _fmtDate(existing.shippingDate!);
            }
            _termasukPpn = false; 

            if (existing.items.isNotEmpty) {
              _items = existing.items.map((line) {
                final it = _LineItem();
                it.produkCtrl.text = line.productName;
                it.deskCtrl.text = line.description;
                it.qtyCtrl.text = line.qty == line.qty.toInt() ? line.qty.toInt().toString() : line.qty.toString();
                it.unitCtrl.text = line.unit;
                it.hargaCtrl.text = line.unitPrice.toStringAsFixed(0);
                it.discCtrl.text = line.discount.toString();
                it.pajak = line.tax;
                it.jumlah = line.total;
                it.itemUomId = line.itemUomId;
                return it;
              }).toList();
            } else {
              _items = [
                _LineItem()
                  ..produkCtrl.text = 'Produk Penjualan'
                  ..hargaCtrl.text = existing.amount.toStringAsFixed(0)
                  ..jumlah = existing.amount
                  ..pajak = '-'
              ];
            }
          });
        } else {
          if (provider.customers.isNotEmpty) {
            setState(() => _customerCtrl.text = provider.customers.first.companyName);
          }
          if (provider.warehouses.isNotEmpty) {
            setState(() => _warehouseCtrl.text = provider.warehouses.first.name);
          }
        }
      } else {
        if (provider.customers.isNotEmpty) {
          setState(() => _customerCtrl.text = provider.customers.first.companyName);
        }
        if (provider.warehouses.isNotEmpty) {
          setState(() => _warehouseCtrl.text = provider.warehouses.first.name);
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
                      Text('Penjualan', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
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
                      Text('Faktur Penjualan Baru', style: GoogleFonts.ibmPlexSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
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
            onPressed: () => context.read<AppProvider>().openNewForm('sales'),
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
    final provider = context.watch<AppProvider>();
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
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
                      Icon(Icons.person_outline, size: 18, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text('Informasi Pelanggan', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildF3Search('Nama Pelanggan', controller: _customerCtrl, options: _customers, onChanged: (v) => _selectedCustomer = v, isDark: isDark),
                  const SizedBox(height: 16),
                  _buildF3Search('Perusahaan Induk', controller: _indukCtrl, options: _customers, onChanged: (v) => _indukCtrl.text = v, isDark: isDark),
                  const SizedBox(height: 16),
                  _buildF3Search('Sales Staff', controller: _staffCtrl, options: _staffs, onChanged: (v) => _staffCtrl.text = v, isDark: isDark),
                  const SizedBox(height: 16),
                  _overlayField('Termin Pembayaran', child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: RawAutocomplete<String>(
                            textEditingController: _tempoCtrl,
                            focusNode: _getF3Focus('Termin'),
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              final opts = (provider.dues.isNotEmpty
                                      ? provider.dues.map((d) => d.displayName).toList()
                                      : ['Termin 0 hari', 'Termin 30 hari'])
                                  .toList();
                              if (textEditingValue.text.isEmpty) return opts;
                              return opts.where((opt) =>
                                  opt.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                            },
                            onSelected: (selection) {
                              final matched = provider.dues.where((d) => d.displayName == selection).firstOrNull;
                              final days = matched?.days ??
                                  (int.tryParse(selection.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
                              setState(() {
                                _tempoCtrl.text = matched?.displayName ?? 'Termin $days hari';
                                _tempoValCtrl.text = days.toString();
                                _selectedTerminId = matched?.id;
                                final entryDate = DateTime.tryParse(_dateCtrl.text) ?? DateTime.now();
                                _dueDateCtrl.text = _fmtDate(entryDate.add(Duration(days: days)));
                              });
                            },
                            fieldViewBuilder: (context, textController, focusNode, onEditingComplete) {
                              return TextField(
                                controller: textController,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: _inputDeco('Pilih / ketik termin...', isDark).copyWith(
                                  suffixIcon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                                ),
                                style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
                                onChanged: (v) {
                                  final days = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                                  final matched = provider.dues.where((d) => d.days == days || d.name == v).firstOrNull;
                                  setState(() {
                                    _tempoValCtrl.text = days.toString();
                                    _selectedTerminId = matched?.id;
                                    final entryDate = DateTime.tryParse(_dateCtrl.text) ?? DateTime.now();
                                    _dueDateCtrl.text = _fmtDate(entryDate.add(Duration(days: days)));
                                  });
                                },
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              final Color cardBg = isDark ? const Color(0xFF1C2630) : Colors.white;
                              final Color borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 4,
                                  color: cardBg,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      side: BorderSide(color: borderColor)),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final opt = options.elementAt(index);
                                        return ListTile(
                                          dense: true,
                                          title: Text(opt,
                                              style: GoogleFonts.ibmPlexSans(
                                                  fontSize: 13, color: _textPrimary)),
                                          onTap: () => onSelected(opt),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _tempoValCtrl,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco('Hari', isDark),
                            style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
                            onChanged: (v) {
                              final days = int.tryParse(v) ?? 0;
                              final matched = provider.dues.where((d) => d.days == days).firstOrNull;
                              setState(() {
                                _tempoCtrl.text = matched?.displayName ?? 'Termin $days hari';
                                _selectedTerminId = matched?.id;
                                final entryDate = DateTime.tryParse(_dateCtrl.text) ?? DateTime.now();
                                _dueDateCtrl.text = _fmtDate(entryDate.add(Duration(days: days)));
                              });
                            },
                          ),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      // Chips dinamis sesuai data api/v2/termin/trans
                      Builder(builder: (context) {
                        final duesList = provider.dues.isNotEmpty
                            ? provider.dues
                            : [
                                DueModel(id: '0', code: '0', name: 'Termin 0 hari', days: 0),
                                DueModel(id: '30', code: '30', name: 'Termin 30 hari', days: 30),
                              ];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: duesList.map((d) {
                              final isSelected = _tempoValCtrl.text.trim() == d.days.toString();
                              final color = d.days == 0 ? const Color(0xFF28A745) : _primaryColor;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _tempoValCtrl.text = d.days.toString();
                                      _tempoCtrl.text = d.displayName;
                                      _selectedTerminId = d.id;
                                      final entryDate = DateTime.tryParse(_dateCtrl.text) ?? DateTime.now();
                                      _dueDateCtrl.text = _fmtDate(entryDate.add(Duration(days: d.days)));
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withValues(alpha: 0.15)
                                          : (isDark ? const Color(0xFF222C36) : const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSelected ? color : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          d.days == 0 ? Icons.flash_on : Icons.calendar_today_outlined,
                                          size: 12,
                                          color: isSelected ? color : (isDark ? Colors.grey[400] : Colors.grey[700]),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          d.displayName,
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected ? color : (isDark ? Colors.grey[300] : Colors.grey[800]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                    ],
                  ), isDark: isDark),
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
                      Text('Informasi Dokumen', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _overlayField('Nomor Nota', child: TextField(controller: _nomorNotaCtrl, decoration: _inputDeco('INV-XXXX-XXX', isDark), style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary)), isDark: isDark)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildF3Search('Gudang Sumber', controller: _warehouseCtrl, options: _warehouses, onChanged: (v) => _selectedWarehouse = v, isDark: isDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _overlayField('Tgl. Terbit', child: _dateInput(_dateCtrl, isDark), isDark: isDark)),
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
                child: Text('Daftar Produk (Lines)', style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
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
                            case 0: return _tdProductSelect(item, r, isDark);
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
                  decoration: _inputDeco('Catatan atau memo pengiriman...', isDark),
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
                  _calcRow('Total Tagihan:', Formatters.currency(_grandTotal), true, isDark, color: _primaryColor),
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

  Future<void> _commit({
    required String status,
    required String message,
    PaymentResult? paymentResult,
    bool showPrintNota = false,
  }) async {
    final invItems = _items.where((i) => i.produkCtrl.text.trim().isNotEmpty).map((item) => InvoiceItemLine(
      productName: item.produkCtrl.text.trim(),
      description: item.deskCtrl.text.trim(),
      qty: double.tryParse(item.qtyCtrl.text) ?? 1,
      unit: item.unitCtrl.text.trim(),
      unitPrice: double.tryParse(item.hargaCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0,
      discount: double.tryParse(item.discCtrl.text) ?? 0,
      tax: item.pajak,
      total: item.jumlah,
      itemUomId: item.itemUomId,
    )).toList();

    final inv = SalesInvoice(
      id: _nomorNotaCtrl.text.trim(),
      date: DateTime.tryParse(_dateCtrl.text) ?? _existing?.date ?? DateTime.now(),
      customer: _selectedCustomer,
      warehouse: _selectedWarehouse,
      amount: _grandTotal,
      status: status,
      items: invItems,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : _keteranganCtrl.text,
      staff: _staffCtrl.text,
      termin: _tempoCtrl.text,
      dueDate: DateTime.tryParse(_dueDateCtrl.text),
      shippingDate: DateTime.tryParse(_shipDateCtrl.text),
      paymentMethod: paymentResult?.paymentMethod ?? _existing?.paymentMethod,
      paidAmount: paymentResult?.paidAmount ?? _existing?.paidAmount,
      paymentDate: paymentResult != null ? DateTime.now() : _existing?.paymentDate,
    );

    // Create Trans object mapping from the form
    final terminDays = int.tryParse(_tempoValCtrl.text.trim()) ??
        (int.tryParse(_tempoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
    final provider = context.read<AppProvider>();
    final matchedDue = provider.dues
        .where((d) => d.id == _selectedTerminId || d.days == terminDays || d.name == _tempoCtrl.text)
        .firstOrNull;

    final trans = Trans(
      transNomornota: inv.id,
      transEntrydate: (inv.date.millisecondsSinceEpoch / 1000).round(),
      transText: inv.customer,
      masterwarehouseId: inv.warehouse,
      transNilaikurs: inv.amount,
      transType: status == 'Lunas' ? 1 : 0, 
      transTerminhari: terminDays,
      masterterminId: matchedDue?.id ?? _selectedTerminId,
    );

    // Create Transline objects from items
    final lines = _items.map((item) => Transline(
      translineKeterangan: item.produkCtrl.text,
      translineQty: double.tryParse(item.qtyCtrl.text) ?? 0.0,
      translinePrice: double.tryParse(item.hargaCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      translineTotaldiscvalue: double.tryParse(item.discCtrl.text) ?? 0.0,
      translineNetvalue: item.jumlah,
    )).toList();

    List<Map<String, dynamic>>? paymentPayload;
    if (paymentResult != null) {
      paymentPayload = [paymentResult.toBackendMap()];
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF28A745),
      behavior: SnackBarBehavior.floating,
    ));
    
    // Save to local and backend
    provider.addSalesInvoice(inv);
    provider.saveSalesTransaction(trans, lines: lines, payments: paymentPayload, context: context);
    
    if (showPrintNota && mounted) {
      InvoicePrintDialog.showFromSales(context, invoice: inv);
    }

    if (mounted) {
      provider.switchModule('sales');
      widget.onBack();
    }
  }

  void _simpanDraft() {
    if (_existing != null && _existing!.status != 'Draft') {
      _showError('Faktur ini sudah terbit (${_existing!.status}). Gunakan "Simpan & Terbitkan" untuk menyimpan perubahan.');
      return;
    }
    if (_selectedCustomer.trim().isEmpty) return _showError('Partner wajib diisi.');
    if (_nomorNotaCtrl.text.trim().isEmpty) return _showError('Nomor nota wajib diisi.');
    _commit(status: 'Draft', message: 'Draft ${_nomorNotaCtrl.text.trim()} tersimpan.');
  }

  void _simpanDanTerbitkan() async {
    final hasItem = _items.any((i) => i.produkCtrl.text.trim().isNotEmpty && i.jumlah > 0);
    if (_selectedCustomer.trim().isEmpty) return _showError('Partner wajib diisi.');
    if (_nomorNotaCtrl.text.trim().isEmpty) return _showError('Nomor nota wajib diisi.');
    if (!hasItem) return _showError('Isi minimal satu baris produk dengan qty dan harga lebih dari 0.');

    // Hitung apakah termin = 0 hari (Cash) atau > 0 hari (Kredit)
    final valParsed = int.tryParse(_tempoValCtrl.text.trim());
    final tempoTextParsed = int.tryParse(_tempoCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final terminDays = valParsed ?? tempoTextParsed ?? 0;
    final isCash = terminDays == 0;

    PaymentResult? paymentResult;
    String finalStatus = 'Belum Bayar';

    if (isCash) {
      // CASH: Langsung buka modal pembayaran
      final result = await TransactionPaymentDialog.show(
        context,
        transactionId: _nomorNotaCtrl.text.trim(),
        totalAmount: _grandTotal,
        partnerName: _selectedCustomer,
        isPurchase: false,
      );

      // Jika user membatalkan / menutup modal pembayaran, batalkan proses simpan
      if (result == null) {
        return;
      }
      paymentResult = result;
      finalStatus = 'Lunas';
    } else {
      // KREDIT: Langsung simpan dengan status Belum Bayar
      finalStatus = 'Belum Bayar';
    }

    final keep = _existing != null && _existing!.status != 'Draft';
    if (keep && paymentResult == null) {
      finalStatus = _existing!.status;
    }

    await _commit(
      status: finalStatus,
      paymentResult: paymentResult,
      message: 'Faktur ${_nomorNotaCtrl.text.trim()} berhasil ${keep ? 'diperbarui' : 'diterbitkan'}.',
      showPrintNota: true,
    );
  }

  void _showProductSelectorDialog(int r) {
    final provider = context.read<AppProvider>();
    final items = provider.inventoryItems;
    final isDark = provider.isDarkMode;
    final Color _primaryColor = provider.primaryColor;
    final Color _cardBg = isDark ? const Color(0xFF1C2630) : Colors.white;
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    showDialog(
      context: context,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = items.where((it) {
              final q = query.toLowerCase();
              return it.name.toLowerCase().contains(q) ||
                  it.sku.toLowerCase().contains(q) ||
                  it.category.toLowerCase().contains(q);
            }).toList();

            return Dialog(
              backgroundColor: _cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Container(
                width: 620,
                height: 520,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pilih Produk dari Stok Gudang',
                            style: GoogleFonts.ibmPlexSans(
                                fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary)),
                        IconButton(
                            icon: Icon(Icons.close, size: 20, color: _textSecondary),
                            onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, size: 20, color: _textSecondary),
                        hintText: 'Ketik nama barang, kode SKU, atau kategori...',
                        hintStyle: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textSecondary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: _borderColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: _borderColor)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (val) {
                        setDialogState(() => query = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                items.isEmpty
                                    ? 'Belum ada data barang di gudang aktif.\nPastikan gudang sudah dipilih di menu atas.'
                                    : 'Tidak ada produk yang cocok dengan "$query".',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.ibmPlexSans(color: _textSecondary, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: _borderColor),
                              itemBuilder: (context, idx) {
                                final prod = filtered[idx];
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  title: Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _primaryColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(prod.sku,
                                            style: GoogleFonts.ibmPlexSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _primaryColor)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(prod.name,
                                            style: GoogleFonts.ibmPlexSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: _textPrimary),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Text('Kategori: ${prod.category}',
                                            style: GoogleFonts.ibmPlexSans(
                                                fontSize: 11, color: _textSecondary)),
                                        const SizedBox(width: 12),
                                        Text('Tersedia: ${prod.stockAvailable} ${prod.unit}',
                                            style: GoogleFonts.ibmPlexSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: prod.stockAvailable > 0
                                                    ? const Color(0xFF28A745)
                                                    : const Color(0xFFE55353))),
                                      ],
                                    ),
                                  ),
                                  trailing: Text(
                                    Formatters.currency(
                                        prod.unitPrice > 0 ? prod.unitPrice : prod.costPrice),
                                    style: GoogleFonts.ibmPlexSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      final item = _items[r];
                                      item.produkCtrl.text = prod.name;
                                      item.deskCtrl.text = prod.category;
                                      item.unitCtrl.text = prod.unit;
                                      final price = prod.unitPrice > 0 ? prod.unitPrice : prod.costPrice;
                                      item.hargaCtrl.text = price.toStringAsFixed(0);
                                      item.itemUomId = prod.id;
                                      item.updateJumlah();
                                    });
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tdProductSelect(_LineItem item, int r, bool isDark) {
    final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color _textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return Padding(
      padding: const EdgeInsets.all(6),
      child: InkWell(
        onTap: () => _showProductSelectorDialog(r),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.produkCtrl.text.isEmpty ? 'Pilih produk...' : item.produkCtrl.text,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    color: item.produkCtrl.text.isEmpty ? _textSecondary : _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down, size: 18, color: _textSecondary),
            ],
          ),
        ),
      ),
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

  Widget _buildF3Search(String label, {required TextEditingController controller, List<String>? options, ValueChanged<String>? onChanged, required bool isDark}) {
    final opts = options ?? ['Data A', 'Data B', 'Data C', 'Hasil Pencarian...'];
    final Color _primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color _textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    return _overlayField(label, isDark: isDark, child: RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: _getF3Focus(label),
      onSelected: (v) {
        controller.text = v;
        onChanged?.call(v);
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return opts;
        return opts.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      fieldViewBuilder: (context, textController, focusNode, onEditingComplete) {
        return TextField(
          controller: textController,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          onChanged: (v) => onChanged?.call(v),
          decoration: _inputDeco('Ketik & cari...', isDark).copyWith(suffixIcon: Icon(Icons.search, size: 16, color: _primaryColor)),
          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final Color _cardBg = isDark ? const Color(0xFF1C2630) : Colors.white;
        final Color _borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            color: _cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: _borderColor)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option, style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary)),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
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
  String? itemUomId;

  void updateJumlah() {
    final qty = double.tryParse(qtyCtrl.text) ?? 0;
    final harga = double.tryParse(hargaCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    final disc = double.tryParse(discCtrl.text) ?? 0;
    jumlah = qty * harga * (1 - disc / 100);
  }
}
