import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/app_models.dart';
import '../../widgets/common/erp_card.dart';

class SalesFormScreen extends StatefulWidget {
  final VoidCallback onBack;
  const SalesFormScreen({super.key, required this.onBack});

  @override
  State<SalesFormScreen> createState() => _SalesFormScreenState();
}

class _SalesFormScreenState extends State<SalesFormScreen> {
  String _activeTab = 'utama';
  String _selectedCustomer = 'PT Surya Gemilang Kencana';
  String _selectedWarehouse = 'Gudang Utama Malang (Kepanjen)';
  final _indukCtrl = TextEditingController(text: 'Jl. Raya Industri No. 5, Kepanjen');
  final _staffCtrl = TextEditingController();
  final _tempoCtrl = TextEditingController(text: '30 HARI');
  final _tempoValCtrl = TextEditingController(text: '30');
  final _dateCtrl = TextEditingController(text: '2026-09-22');
  final _shipDateCtrl = TextEditingController(text: '2026-09-24');
  final _dueDateCtrl = TextEditingController(text: '2026-10-22');
  final _keteranganCtrl = TextEditingController();
  final _nomorNotaCtrl = TextEditingController(text: 'INV-2026-006');
  final _notesCtrl = TextEditingController();
  bool _termasukPpn = true;
  bool _tambahBaris = true;
  bool _langsungCetak = true;
  bool _discPersen = false;

  List<_LineItem> _items = [_LineItem()];

  double get _subtotal => _items.fold(0, (s, i) => s + i.jumlah);
  double get _ppn => _termasukPpn ? _subtotal * 0.11 : 0;
  double get _grandTotal => _subtotal + _ppn;

  final _customers = ['PT Surya Gemilang Kencana', 'PT Bintang Mitra Sejahtera', 'CV Cipta Karya Mandiri', 'Toko Makmur Sentosa Malang'];
  final _warehouses = ['Gudang Utama Malang (Kepanjen)', 'Gudang Transit Singosari', 'Gudang Distribusi Retail'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPageHeader(),
        _buildTabNav(),
        Expanded(
          child: Container(
            color: AppColors.bgApp,
            child: _activeTab == 'utama' ? _buildUtamaTab()
              : _activeTab == 'lain' ? _buildLainTab()
              : _buildHistoryTab(),
          ),
        ),
        _buildFooterBar(),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: widget.onBack,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('Penjualan', style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AppProvider>().openNewForm('sales');
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('+ Tab Form Baru'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Text('Buat Faktur Penjualan Baru', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.3))
              ),
              child: Text('DRAFT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildTabNav() {
    final tabs = [('utama', '[UTAMA]'), ('lain', '[LAIN]'), ('history', '[HISTORY]')];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: tabs.map((t) {
          final isActive = _activeTab == t.$1;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = t.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isActive ? AppColors.primary : Colors.transparent, width: 2.5)),
              ),
              child: Text(t.$2, style: GoogleFonts.inter(fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textMuted)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUtamaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Header fields - 3 columns
        ErpCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final col1 = Column(children: [
                _buildF3Search('Partner [F3]', initial: _selectedCustomer, options: _customers),
                const SizedBox(height: 12),
                _buildF3Search('Induk [F3]', initial: _indukCtrl.text),
                const SizedBox(height: 12),
                _buildF3Search('Staff [F3]', initial: _staffCtrl.text),
                const SizedBox(height: 12),
                _overlayField('Tempo [F3]', child: Row(children: [
                  Expanded(child: TextField(controller: _tempoCtrl, decoration: _inputDeco('30 HARI...'))),
                  const SizedBox(width: 8),
                  SizedBox(width: 70, child: TextField(controller: _tempoValCtrl, textAlign: TextAlign.center, decoration: _inputDeco('30'))),
                ])),
              ]);

              final col2 = Column(children: [
                _overlayField('Tgl. Input', child: TextField(controller: _dateCtrl, decoration: _inputDeco('YYYY-MM-DD'))),
                const SizedBox(height: 12),
                _overlayField('Tgl. Kirim', child: TextField(controller: _shipDateCtrl, decoration: _inputDeco('YYYY-MM-DD'))),
                const SizedBox(height: 12),
                _overlayField('Tgl. Jatem', child: TextField(controller: _dueDateCtrl, decoration: _inputDeco('YYYY-MM-DD'))),
              ]);

              final col3 = Column(children: [
                _overlayField('Keterangan', child: TextField(controller: _keteranganCtrl, decoration: _inputDeco('Keterangan atas dokumen...'))),
                const SizedBox(height: 12),
                _overlayField('Nomor Nota', child: TextField(controller: _nomorNotaCtrl, decoration: _inputDeco('INV-XXXX-XXX'))),
                const SizedBox(height: 12),
                _buildF3Search('Gudang [F3]', initial: _selectedWarehouse, options: _warehouses),
              ]);

              if (isMobile) {
                return Column(children: [col1, const SizedBox(height: 12), col2, const SizedBox(height: 12), col3]);
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 20),
                  Expanded(child: col2),
                  const SizedBox(width: 20),
                  Expanded(child: col3),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        // Product table
        ErpCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            // Table header
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 900,
                child: Column(children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bgApp,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.5), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1), 4: FlexColumnWidth(1.8), 5: FlexColumnWidth(1),
                        6: FlexColumnWidth(1), 7: FlexColumnWidth(1.8), 8: FlexColumnWidth(0.5),
                      },
                      children: [
                        TableRow(children: [
                          _thCell('Produk'), _thCell('Deskripsi'), _thCell('Qty'), _thCell('Unit'),
                          _thCell('Harga Satuan'), _thCell('Diskon'), _thCell('Pajak'), _thCell('Jumlah'), _thCell(''),
                        ]),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ..._items.asMap().entries.map((e) => _buildItemRow(e.key, e.value)),
                  InkWell(
                    onTap: () => setState(() => _items.add(_LineItem())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.add, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('+ Tambah Baris Produk', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        // Calc + Notes
        ErpCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              
              final notes = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Catatan Faktur', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: _inputDeco('Catatan atau memo pengiriman...'),
                ),
              ]);
              
              final calc = SizedBox(
                width: isMobile ? double.infinity : 320,
                child: Column(children: [
                  _calcRow('Subtotal:', Formatters.currency(_subtotal), bold: false),
                  const SizedBox(height: 6),
                  _calcRow('PPN (11%):', Formatters.currency(_ppn), bold: false),
                  const Divider(height: 20),
                  _calcRow('Total Tagihan:', Formatters.currency(_grandTotal), bold: true, color: AppColors.primary),
                ]),
              );
              
              if (isMobile) {
                return Column(
                  children: [
                    notes,
                    const SizedBox(height: 20),
                    calc,
                  ],
                );
              }
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: notes),
                  const SizedBox(width: 40),
                  calc,
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildItemRow(int index, _LineItem item) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderLight))),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1),
          3: FlexColumnWidth(1), 4: FlexColumnWidth(1.8), 5: FlexColumnWidth(1),
          6: FlexColumnWidth(1), 7: FlexColumnWidth(1.8), 8: FlexColumnWidth(0.5),
        },
        children: [
          TableRow(children: [
            _tdInput(item.produkCtrl, 'Pilih produk...', onChanged: (_) => setState(() {})),
            _tdInput(item.deskCtrl, 'Deskripsi...'),
            _tdInput(item.qtyCtrl, '0', isNumber: true, onChanged: (_) => setState(() { item.updateJumlah(); })),
            _tdInput(item.unitCtrl, 'Pcs'),
            _tdInput(item.hargaCtrl, '0', isNumber: true, onChanged: (_) => setState(() { item.updateJumlah(); })),
            _tdInput(item.discCtrl, '0', isNumber: true, onChanged: (_) => setState(() { item.updateJumlah(); })),
            TableCell(child: Padding(
              padding: const EdgeInsets.all(6),
              child: DropdownButtonFormField<String>(
                value: item.pajak,
                isDense: true,
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
                onChanged: (v) => setState(() { item.pajak = v!; item.updateJumlah(); }),
                items: const [
                  DropdownMenuItem(value: 'PPN', child: Text('PPN', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: '-', child: Text('-', style: TextStyle(fontSize: 12))),
                ],
              ),
            )),
            TableCell(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(Formatters.currency(item.jumlah), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            )),
            TableCell(child: Center(
              child: IconButton(
                icon: const Icon(Icons.close, size: 14, color: AppColors.danger),
                onPressed: _items.length > 1 ? () => setState(() => _items.removeAt(index)) : null,
              ),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _buildLainTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ErpCard(
        child: Column(children: [
          _buildLainGrid(),
          const Divider(height: 28),
          _buildLainCheckboxes(),
        ]),
      ),
    );
  }

  Widget _buildLainGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: [
        _lainField('Sumber [F3]', full: true),
        _lainFieldWidget('Model Label', DropdownButtonFormField<String>(
          value: '1', isExpanded: true,
          decoration: _dropDeco(''),
          onChanged: (_) {},
          items: ['1', '2', '3'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        )),
        _lainField('C.CTR [F3]', initial: 'MAIN STORE'),
        _lainField('Warehouse [F3]', initial: 'G001'),
        _lainFieldWidget('Kurs [F3]', Row(children: [
          SizedBox(width: 80, child: DropdownButtonFormField<String>(
            value: 'IDR', isDense: true,
            decoration: _dropDeco(''),
            onChanged: (_) {},
            items: ['IDR', 'USD', 'EUR', 'SGD'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
          )),
          const SizedBox(width: 8),
          Expanded(child: TextField(decoration: _inputDeco('Rate...'), controller: TextEditingController(text: '1'))),
        ])),
        _lainField('Expedisi [F3]'),
        _lainField('Nomor Resi'),
        _lainFieldWidget('Disc Group ⚡', TextField(
          decoration: _inputDeco('0.00'),
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(color: AppColors.danger, fontWeight: FontWeight.w700),
        )),
        _lainField('Max Baris', initial: '100'),
        _lainField('Nomor Giro'),
        _lainField('Tgl. Giro Jatem', initial: 'YYYY-MM-DD'),
        _lainField('Tgl. Giro Cair', initial: 'YYYY-MM-DD'),
        _lainField('Telp [F3] (1)'),
        _lainField('Telp [F3] (2)'),
        _lainField('Kontak [F3] (1)'),
        _lainField('Kontak [F3] (2)'),
        _lainField('Alamat [F3]', full: true),
        _lainField('Rekening [F3]', full: true),
      ],
    );
  }

  Widget _buildLainCheckboxes() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Model Produk', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
      const SizedBox(height: 8),
      Row(children: [
        _radio('Jasa'), const SizedBox(width: 20), _radio('Komersial'), const SizedBox(width: 20), _radio('Semua Produk', selected: true),
      ]),
      const SizedBox(height: 16),
      Wrap(spacing: 20, children: [
        _checkbox('Termasuk PPN', _termasukPpn, (v) => setState(() => _termasukPpn = v!)),
        _checkbox('Jika ada item, tambahkan baris', _tambahBaris, (v) => setState(() => _tambahBaris = v!)),
        _checkbox('Langsung cetak', _langsungCetak, (v) => setState(() => _langsungCetak = v!)),
        _checkbox('Disc persen', _discPersen, (v) => setState(() => _discPersen = v!)),
      ]),
    ]);
  }

  Widget _buildHistoryTab() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.history_rounded, size: 64, color: AppColors.borderLight),
        const SizedBox(height: 16),
        Text('Belum ada riwayat untuk dokumen ini.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildFooterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: widget.onBack,
            child: Text('Batal', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          ),
          Row(children: [
            OutlinedButton(
              onPressed: () {},
              child: const Text('Simpan Draft'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _simpanDanTerbitkan,
              child: const Text('Simpan & Terbitkan'),
            ),
          ]),
        ],
      ),
    );
  }

  void _simpanDanTerbitkan() {
    final inv = SalesInvoice(
      id: _nomorNotaCtrl.text,
      date: DateTime.now(),
      customer: _selectedCustomer,
      warehouse: _selectedWarehouse,
      amount: _grandTotal,
      status: 'Belum Bayar',
    );
    context.read<AppProvider>().addSalesInvoice(inv);
    widget.onBack();
  }

  // ---- Helpers ----

  Widget _overlayField(String label, {required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      const SizedBox(height: 5),
      child,
    ]);
  }

  Widget _lainField(String label, {String? initial, bool full = false}) {
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
            decoration: _inputDeco('Ketik & cari...').copyWith(suffixIcon: const Icon(Icons.search, size: 16, color: AppColors.primary)),
            style: GoogleFonts.inter(fontSize: 13),
          );
        },
      );
    } else {
      childWidget = TextField(controller: TextEditingController(text: initial ?? ''), decoration: _inputDeco('Input...'));
    }
    return SizedBox(
      width: full ? double.infinity : 220,
      child: _overlayField(label, child: childWidget),
    );
  }

  Widget _buildF3Search(String label, {String? initial, List<String>? options}) {
    final opts = options ?? ['Data A', 'Data B', 'Data C', 'Hasil Pencarian...'];
    return _overlayField(label, child: Autocomplete<String>(
      initialValue: TextEditingValue(text: initial ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return opts;
        return opts.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextField(
          controller: controller, focusNode: focusNode, onEditingComplete: onEditingComplete,
          decoration: _inputDeco('Ketik & cari...').copyWith(suffixIcon: const Icon(Icons.search, size: 16, color: AppColors.primary)),
          style: GoogleFonts.inter(fontSize: 13),
        );
      },
    ));
  }

  Widget _lainFieldWidget(String label, Widget child) {
    return SizedBox(
      width: 220,
      child: _overlayField(label, child: child),
    );
  }

  Widget _radio(String label, {bool selected = false}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(value: label, groupValue: selected ? label : null, onChanged: (_) {}, activeColor: AppColors.primary),
      Text(label, style: GoogleFonts.inter(fontSize: 13)),
    ]);
  }

  Widget _checkbox(String label, bool value, Function(bool?) onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.primary, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      Text(label, style: GoogleFonts.inter(fontSize: 13)),
    ]);
  }

  Widget _calcRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.inter(fontSize: bold ? 15 : 13, color: AppColors.textMuted)),
      Text(value, style: GoogleFonts.inter(fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color ?? AppColors.secondary)),
    ]);
  }

  Widget _thCell(String text) => TableCell(child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
  ));

  Widget _tdInput(TextEditingController ctrl, String hint, {bool isNumber = false, Function(String)? onChanged}) {
    return TableCell(child: Padding(
      padding: const EdgeInsets.all(4),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.borderLight),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.borderLight)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    ));
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.borderLight),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  InputDecoration _dropDeco(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
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
