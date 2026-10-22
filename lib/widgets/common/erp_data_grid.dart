import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/formatters.dart';
import 'resizable_table.dart';

/// Jenis filter untuk sebuah kolom.
enum ErpFilterKind {
  /// Tanpa filter.
  none,

  /// Teks: mengandung / sama dengan / diawali / tidak mengandung / kosong.
  text,

  /// Angka / nominal: rentang min–max.
  number,

  /// Tanggal: rentang dari–sampai (+ pilihan cepat).
  date,

  /// Multi-pilih dari nilai unik di kolom (mis. Status, Gudang).
  select,
}

/// Definisi kolom untuk [ErpDataGrid].
class ErpGridColumn<T> {
  final String label;
  final double flex;
  final ErpFilterKind filter;

  /// Nilai mentah untuk filter & sort (String / num / DateTime).
  final Object? Function(T row)? value;

  /// Teks yang dipakai untuk filter teks / opsi multi-pilih. Default: `value.toString()`.
  final String Function(T row)? display;

  /// Widget sel.
  final Widget Function(BuildContext context, T row) cell;

  final bool sortable;
  final bool alignRight;

  const ErpGridColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.filter = ErpFilterKind.none,
    this.value,
    this.display,
    this.sortable = true,
    this.alignRight = false,
  });

  bool get canSort => sortable && value != null;
  bool get canFilter => filter != ErpFilterKind.none && (value != null || display != null);

  String displayOf(T row) {
    if (display != null) return display!(row);
    final v = value?.call(row);
    if (v == null) return '';
    if (v is DateTime) return Formatters.dateShort(v);
    return v.toString();
  }
}

/// State filter satu kolom.
class ErpColumnFilter {
  String op; // contains | equals | starts | notContains | empty
  String text;
  double? min;
  double? max;
  DateTime? from;
  DateTime? to;
  Set<String>? selected; // null = semua

  ErpColumnFilter({
    this.op = 'contains',
    this.text = '',
    this.min,
    this.max,
    this.from,
    this.to,
    this.selected,
  });

  ErpColumnFilter copy() => ErpColumnFilter(
        op: op,
        text: text,
        min: min,
        max: max,
        from: from,
        to: to,
        selected: selected == null ? null : Set.of(selected!),
      );

  bool isActive(ErpFilterKind kind) {
    switch (kind) {
      case ErpFilterKind.text:
        return op == 'empty' || text.trim().isNotEmpty;
      case ErpFilterKind.number:
        return min != null || max != null;
      case ErpFilterKind.date:
        return from != null || to != null;
      case ErpFilterKind.select:
        return selected != null;
      case ErpFilterKind.none:
        return false;
    }
  }

  bool matches(ErpFilterKind kind, Object? value, String display) {
    switch (kind) {
      case ErpFilterKind.text:
        final s = display.toLowerCase();
        final q = text.trim().toLowerCase();
        switch (op) {
          case 'equals':
            return s == q;
          case 'starts':
            return s.startsWith(q);
          case 'notContains':
            return !s.contains(q);
          case 'empty':
            return s.trim().isEmpty;
          default:
            return s.contains(q);
        }
      case ErpFilterKind.number:
        final n = value is num ? value.toDouble() : double.tryParse(display);
        if (n == null) return false;
        if (min != null && n < min!) return false;
        if (max != null && n > max!) return false;
        return true;
      case ErpFilterKind.date:
        if (value is! DateTime) return false;
        final d = DateTime(value.year, value.month, value.day);
        if (from != null && d.isBefore(DateTime(from!.year, from!.month, from!.day))) return false;
        if (to != null && d.isAfter(DateTime(to!.year, to!.month, to!.day))) return false;
        return true;
      case ErpFilterKind.select:
        return selected!.contains(display);
      case ErpFilterKind.none:
        return true;
    }
  }

  String describe(ErpFilterKind kind) {
    String num(double v) => Formatters.currency(v).replaceFirst('Rp ', '');
    switch (kind) {
      case ErpFilterKind.text:
        const labels = {
          'contains': 'mengandung',
          'equals': '=',
          'starts': 'diawali',
          'notContains': 'tidak mengandung',
          'empty': 'kosong',
        };
        return op == 'empty' ? 'kosong' : '${labels[op]} "$text"';
      case ErpFilterKind.number:
        if (min != null && max != null) return '${num(min!)} – ${num(max!)}';
        if (min != null) return '≥ ${num(min!)}';
        return '≤ ${num(max!)}';
      case ErpFilterKind.date:
        if (from != null && to != null) return '${Formatters.dateShort(from!)} – ${Formatters.dateShort(to!)}';
        if (from != null) return 'sejak ${Formatters.dateShort(from!)}';
        return 's/d ${Formatters.dateShort(to!)}';
      case ErpFilterKind.select:
        final list = selected!.toList();
        if (list.isEmpty) return '(tidak ada)';
        if (list.length <= 2) return list.join(', ');
        return '${list.take(2).join(', ')} +${list.length - 2}';
      case ErpFilterKind.none:
        return '';
    }
  }
}

/// Tabel data dengan kolom resizable, sort, dan filter per kolom
/// (teks, rentang angka, rentang tanggal, multi-pilih). Filter bisa dikombinasi.
class ErpDataGrid<T> extends StatefulWidget {
  final List<T> rows;
  final List<ErpGridColumn<T>> columns;

  /// Kunci unik tabel: dipakai untuk mengingat lebar kolom, filter & sort.
  final String storageKey;
  final double minTableWidth;
  final String emptyText;

  const ErpDataGrid({
    super.key,
    required this.rows,
    required this.columns,
    required this.storageKey,
    this.minTableWidth = 1000,
    this.emptyText = 'Belum ada data.',
  });

  @override
  State<ErpDataGrid<T>> createState() => _ErpDataGridState<T>();
}

class _GridMemory {
  final Map<int, ErpColumnFilter> filters;
  final int? sortCol;
  final bool asc;
  _GridMemory(this.filters, this.sortCol, this.asc);
}

class _ErpDataGridState<T> extends State<ErpDataGrid<T>> {
  /// Filter & sort diingat per storageKey supaya tidak hilang saat pindah tab.
  static final Map<String, _GridMemory> _memory = {};

  Map<int, ErpColumnFilter> _filters = {};
  int? _sortCol;
  bool _asc = true;

  @override
  void initState() {
    super.initState();
    final m = _memory[widget.storageKey];
    if (m != null) {
      _filters = m.filters.map((k, v) => MapEntry(k, v.copy()));
      _sortCol = m.sortCol;
      _asc = m.asc;
    }
  }

  void _remember() {
    _memory[widget.storageKey] = _GridMemory(
      _filters.map((k, v) => MapEntry(k, v.copy())),
      _sortCol,
      _asc,
    );
  }

  bool _isActive(int col) {
    final f = _filters[col];
    return f != null && f.isActive(widget.columns[col].filter);
  }

  int get _activeCount => List.generate(widget.columns.length, _isActive).where((e) => e).length;

  List<T> _applied() {
    final cols = widget.columns;
    var list = widget.rows.where((row) {
      for (final entry in _filters.entries) {
        final c = entry.key;
        if (c >= cols.length) continue;
        final col = cols[c];
        if (!entry.value.isActive(col.filter)) continue;
        if (!entry.value.matches(col.filter, col.value?.call(row), col.displayOf(row))) return false;
      }
      return true;
    }).toList();

    if (_sortCol != null && _sortCol! < cols.length && cols[_sortCol!].canSort) {
      final col = cols[_sortCol!];
      int cmp(T a, T b) {
        final va = col.value!(a);
        final vb = col.value!(b);
        if (va == null && vb == null) return 0;
        if (va == null) return 1;
        if (vb == null) return -1;
        int r;
        if (va is num && vb is num) {
          r = va.compareTo(vb);
        } else if (va is DateTime && vb is DateTime) {
          r = va.compareTo(vb);
        } else {
          r = va.toString().toLowerCase().compareTo(vb.toString().toLowerCase());
        }
        return _asc ? r : -r;
      }

      list.sort(cmp);
    }
    return list;
  }

  void _toggleSort(int col) {
    if (!widget.columns[col].canSort) return;
    setState(() {
      if (_sortCol != col) {
        _sortCol = col;
        _asc = true;
      } else if (_asc) {
        _asc = false;
      } else {
        _sortCol = null;
      }
    });
    _remember();
  }

  void _clearFilter(int col) {
    setState(() => _filters.remove(col));
    _remember();
  }

  void _clearAll() {
    setState(() => _filters.clear());
    _remember();
  }

  Future<void> _openFilter(BuildContext anchorCtx, int col) async {
    final column = widget.columns[col];
    final box = anchorCtx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final anchor = box.localToGlobal(Offset(box.size.width, box.size.height));

    // Opsi unik untuk filter multi-pilih (beserta jumlah baris)
    final counts = <String, int>{};
    if (column.filter == ErpFilterKind.select) {
      for (final r in widget.rows) {
        final d = column.displayOf(r);
        counts[d] = (counts[d] ?? 0) + 1;
      }
    }

    final result = await showDialog<ErpColumnFilter>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.04),
      builder: (ctx) {
        final screen = MediaQuery.of(ctx).size;
        const panelW = 300.0;
        double left = anchor.dx - panelW;
        if (left < 8) left = 8;
        if (left + panelW > screen.width - 8) left = screen.width - panelW - 8;
        double top = anchor.dy + 4;
        if (top > screen.height - 200) top = screen.height - 420;
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top < 8 ? 8 : top,
              width: panelW,
              child: _FilterPanel(
                title: column.label,
                kind: column.filter,
                initial: _filters[col]?.copy() ?? ErpColumnFilter(),
                options: counts,
              ),
            ),
          ],
        );
      },
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.isActive(column.filter)) {
        _filters[col] = result;
      } else {
        _filters.remove(col);
      }
    });
    _remember();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final primary = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);

    final cols = widget.columns;
    final data = _applied();
    final activeCount = _activeCount;

    if (widget.rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(child: Text(widget.emptyText, style: const TextStyle(color: Colors.grey))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bar filter aktif
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: activeCount == 0
              ? const SizedBox(width: double.infinity)
              : Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    border: Border(bottom: BorderSide(color: borderColor)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.filter_alt, size: 16, color: primary),
                      Text(
                        '${data.length} dari ${widget.rows.length} baris',
                        style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
                      ),
                      for (var c = 0; c < cols.length; c++)
                        if (_isActive(c))
                          Builder(
                            builder: (chipCtx) => InputChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: isDark ? const Color(0xFF25303A) : Colors.white,
                              side: BorderSide(color: primary.withOpacity(0.4)),
                              label: Text.rich(
                                TextSpan(children: [
                                  TextSpan(text: '${cols[c].label}: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  TextSpan(text: _filters[c]!.describe(cols[c].filter)),
                                ]),
                                style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textPrimary),
                              ),
                              onPressed: () => _openFilter(chipCtx, c),
                              onDeleted: () => _clearFilter(c),
                              deleteIcon: const Icon(Icons.close, size: 14),
                            ),
                          ),
                      TextButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
                        label: Text('Hapus semua filter', style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
        ),
        ResizableTable(
          storageKey: 'grid_${widget.storageKey}',
          headers: cols.map((c) => c.label).toList(),
          initialFlexes: cols.map((c) => c.flex).toList(),
          minTableWidth: widget.minTableWidth,
          rowCount: data.length,
          headerBuilder: (ctx, i) => _buildHeader(ctx, i, textPrimary, textSecondary, primary),
          cellBuilder: (ctx, r, c) {
            final col = cols[c];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Align(
                alignment: col.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                child: DefaultTextStyle.merge(
                  style: GoogleFonts.ibmPlexSans(fontSize: 13, color: textPrimary),
                  overflow: TextOverflow.ellipsis,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 32),
                    child: Align(
                      alignment: col.alignRight ? Alignment.centerRight : Alignment.centerLeft,
                      widthFactor: 1,
                      heightFactor: 1,
                      child: col.cell(ctx, data[r]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (data.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.filter_alt_off_outlined, size: 32, color: textSecondary),
                const SizedBox(height: 8),
                Text('Tidak ada data yang cocok dengan filter.', style: GoogleFonts.ibmPlexSans(fontSize: 13, color: textSecondary)),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: _clearAll, child: const Text('Hapus semua filter')),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext ctx, int i, Color textPrimary, Color textSecondary, Color primary) {
    final col = widget.columns[i];
    final sorted = _sortCol == i;
    final active = _isActive(i);

    return InkWell(
      onTap: col.canSort ? () => _toggleSort(i) : null,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 2, top: 6, bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                col.label,
                textAlign: col.alignRight ? TextAlign.right : TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: active ? primary : textPrimary),
              ),
            ),
            if (sorted)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: primary),
              ),
            if (col.canFilter)
              Builder(
                builder: (btnCtx) => Tooltip(
                  message: active ? 'Ubah filter' : 'Filter kolom',
                  waitDuration: const Duration(milliseconds: 500),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _openFilter(btnCtx, i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: active
                          ? BoxDecoration(color: primary.withOpacity(0.15), borderRadius: BorderRadius.circular(4))
                          : null,
                      child: Icon(
                        active ? Icons.filter_alt : Icons.filter_alt_outlined,
                        size: 15,
                        color: active ? primary : textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 23),
          ],
        ),
      ),
    );
  }
}

/// Panel popover untuk mengedit filter satu kolom.
class _FilterPanel extends StatefulWidget {
  final String title;
  final ErpFilterKind kind;
  final ErpColumnFilter initial;
  final Map<String, int> options;

  const _FilterPanel({
    required this.title,
    required this.kind,
    required this.initial,
    required this.options,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late ErpColumnFilter f;
  late final TextEditingController _textCtrl;
  late final TextEditingController _minCtrl;
  late final TextEditingController _maxCtrl;
  final _searchCtrl = TextEditingController();
  String _optSearch = '';

  @override
  void initState() {
    super.initState();
    f = widget.initial;
    _textCtrl = TextEditingController(text: f.text);
    _minCtrl = TextEditingController(text: f.min == null ? '' : _fmtNum(f.min!));
    _maxCtrl = TextEditingController(text: f.max == null ? '' : _fmtNum(f.max!));
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmtNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  /// Terima format "1.500.000" atau "1500000" atau "1500,5".
  double? _parseNum(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll('.', '').replaceAll(' ', '').replaceAll(',', '.'));
  }

  void _apply() {
    switch (widget.kind) {
      case ErpFilterKind.text:
        f.text = _textCtrl.text;
        break;
      case ErpFilterKind.number:
        f.min = _parseNum(_minCtrl.text);
        f.max = _parseNum(_maxCtrl.text);
        break;
      default:
        break;
    }
    Navigator.of(context).pop(f);
  }

  void _reset() => Navigator.of(context).pop(ErpColumnFilter());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A222A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final primary = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);

    return Material(
      color: bg,
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_outlined, size: 16, color: primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filter: ${widget.title}',
                      style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.close, size: 16, color: textSecondary)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.all(14),
              child: _buildBody(textPrimary, textSecondary, primary, borderColor),
            ),
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  TextButton(onPressed: _reset, child: const Text('Reset')),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Terapkan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String hint, Color borderColor, {Widget? prefix}) => InputDecoration(
        hintText: hint,
        isDense: true,
        prefixIcon: prefix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
      );

  Widget _buildBody(Color textPrimary, Color textSecondary, Color primary, Color borderColor) {
    final style = GoogleFonts.ibmPlexSans(fontSize: 13, color: textPrimary);
    switch (widget.kind) {
      // ---------------- TEKS ----------------
      case ErpFilterKind.text:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: f.op,
              isDense: true,
              style: style,
              decoration: _deco('', borderColor),
              items: const [
                DropdownMenuItem(value: 'contains', child: Text('Mengandung')),
                DropdownMenuItem(value: 'equals', child: Text('Sama dengan')),
                DropdownMenuItem(value: 'starts', child: Text('Diawali dengan')),
                DropdownMenuItem(value: 'notContains', child: Text('Tidak mengandung')),
                DropdownMenuItem(value: 'empty', child: Text('Kosong')),
              ],
              onChanged: (v) => setState(() => f.op = v ?? 'contains'),
            ),
            if (f.op != 'empty') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _textCtrl,
                autofocus: true,
                style: style,
                decoration: _deco('Ketik kata kunci...', borderColor, prefix: const Icon(Icons.search, size: 18)),
                onSubmitted: (_) => _apply(),
              ),
            ],
          ],
        );

      // ---------------- ANGKA ----------------
      case ErpFilterKind.number:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Minimal', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary)),
            const SizedBox(height: 4),
            TextField(
              controller: _minCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: style,
              decoration: _deco('mis. 1.000.000', borderColor),
              onSubmitted: (_) => _apply(),
            ),
            const SizedBox(height: 10),
            Text('Maksimal', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary)),
            const SizedBox(height: 4),
            TextField(
              controller: _maxCtrl,
              keyboardType: TextInputType.number,
              style: style,
              decoration: _deco('kosongkan = tanpa batas', borderColor),
              onSubmitted: (_) => _apply(),
            ),
          ],
        );

      // ---------------- TANGGAL ----------------
      case ErpFilterKind.date:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        Widget quick(String label, DateTime from, DateTime to) {
          final selected = f.from == from && f.to == to;
          return ChoiceChip(
            label: Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 12)),
            selected: selected,
            visualDensity: VisualDensity.compact,
            onSelected: (_) => setState(() {
              f.from = from;
              f.to = to;
            }),
          );
        }

        Future<void> pick(bool isFrom) async {
          final initial = (isFrom ? f.from : f.to) ?? today;
          final d = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (d != null) setState(() => isFrom ? f.from = d : f.to = d);
        }

        Widget dateBtn(String label, DateTime? v, bool isFrom) => Expanded(
              child: OutlinedButton(
                onPressed: () => pick(isFrom),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  alignment: Alignment.centerLeft,
                  side: BorderSide(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event, size: 16, color: textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        v == null ? label : Formatters.dateShort(v),
                        style: GoogleFonts.ibmPlexSans(fontSize: 12, color: v == null ? textSecondary : textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                quick('Hari ini', today, today),
                quick('7 hari', today.subtract(const Duration(days: 6)), today),
                quick('30 hari', today.subtract(const Duration(days: 29)), today),
                quick('Bulan ini', DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0)),
                quick('Bulan lalu', DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 0)),
                quick('Tahun ini', DateTime(now.year, 1, 1), DateTime(now.year, 12, 31)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                dateBtn('Dari tanggal', f.from, true),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('–', style: style)),
                dateBtn('Sampai', f.to, false),
              ],
            ),
          ],
        );

      // ---------------- MULTI-PILIH ----------------
      case ErpFilterKind.select:
        final all = widget.options.keys.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final visible = _optSearch.isEmpty ? all : all.where((o) => o.toLowerCase().contains(_optSearch.toLowerCase())).toList();
        final selected = f.selected ?? all.toSet();
        final allChecked = selected.length == all.length;

        void setSelected(Set<String> s) {
          setState(() => f.selected = s.length == all.length ? null : s);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (all.length > 6) ...[
              TextField(
                controller: _searchCtrl,
                style: style,
                decoration: _deco('Cari nilai...', borderColor, prefix: const Icon(Icons.search, size: 18)),
                onChanged: (v) => setState(() => _optSearch = v),
              ),
              const SizedBox(height: 6),
            ],
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              tristate: true,
              value: allChecked ? true : (selected.isEmpty ? false : null),
              title: Text('(Pilih semua)', style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary)),
              onChanged: (_) => setSelected(allChecked ? <String>{} : all.toSet()),
            ),
            Divider(height: 1, color: borderColor),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView(
                shrinkWrap: true,
                children: visible.map((o) {
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: selected.contains(o),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(o.isEmpty ? '(kosong)' : o, style: style, overflow: TextOverflow.ellipsis),
                        ),
                        Text('${widget.options[o]}', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: textSecondary)),
                      ],
                    ),
                    onChanged: (v) {
                      final s = Set.of(selected);
                      v == true ? s.add(o) : s.remove(o);
                      setSelected(s);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );

      case ErpFilterKind.none:
        return const SizedBox.shrink();
    }
  }
}
