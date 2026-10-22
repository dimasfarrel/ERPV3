import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tabel dengan kolom yang bisa di-resize (geser garis pemisah di header).
///
/// - Lebar awal mengikuti [initialFlexes] dan memenuhi lebar yang tersedia.
/// - Saat kolom digeser, hanya kolom tersebut yang berubah (seperti Excel);
///   jika total melebihi layar, tabel bisa di-scroll horizontal.
/// - Klik dua kali pada garis pemisah untuk mengembalikan lebar default.
/// - Jika [storageKey] diisi, lebar kolom diingat selama aplikasi berjalan
///   (tidak reset saat pindah tab / rebuild layar).
class ResizableTable extends StatefulWidget {
  final List<String> headers;
  final List<double> initialFlexes;
  final double minTableWidth;
  final int rowCount;
  final Widget Function(BuildContext context, int rowIndex, int colIndex) cellBuilder;

  /// Header kustom (mis. dengan ikon filter/sort). Jika null, pakai teks [headers].
  final Widget Function(BuildContext context, int colIndex)? headerBuilder;

  /// Kunci untuk mengingat lebar kolom antar-rebuild.
  final String? storageKey;

  /// Lebar minimum tiap kolom (px).
  final double minColumnWidth;

  /// Callback saat baris di-tap (opsional).
  final void Function(int rowIndex)? onRowTap;

  const ResizableTable({
    super.key,
    required this.headers,
    required this.initialFlexes,
    this.minTableWidth = 1000,
    required this.rowCount,
    required this.cellBuilder,
    this.headerBuilder,
    this.storageKey,
    this.minColumnWidth = 48,
    this.onRowTap,
  });

  @override
  State<ResizableTable> createState() => _ResizableTableState();
}

class _ResizableTableState extends State<ResizableTable> {
  /// Cache lebar kolom per [ResizableTable.storageKey] (bertahan selama app hidup).
  static final Map<String, List<double>> _savedWidths = {};

  /// Lebar kolom dalam px. Null = mode otomatis (mengikuti flex & lebar layar).
  List<double>? _widths;
  int? _hoverHandle;
  int? _dragHandle;
  int? _hoverRow;
  final ScrollController _hCtrl = ScrollController();

  static const double _handleHitWidth = 12;

  @override
  void initState() {
    super.initState();
    final key = widget.storageKey;
    if (key != null) {
      final saved = _savedWidths[key];
      if (saved != null && saved.length == widget.headers.length) {
        _widths = List.of(saved);
      }
    }
  }

  @override
  void didUpdateWidget(covariant ResizableTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_widths != null && _widths!.length != widget.headers.length) {
      _widths = null;
    }
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    super.dispose();
  }

  List<double> _autoWidths(double available) {
    final base = available > widget.minTableWidth ? available : widget.minTableWidth;
    final flexes = widget.initialFlexes.length == widget.headers.length
        ? widget.initialFlexes
        : List<double>.filled(widget.headers.length, 1);
    final total = flexes.fold(0.0, (a, b) => a + b);
    return flexes.map((f) => f / total * base).toList();
  }

  /// Lebar efektif untuk dirender. Kolom terakhir melebar mengisi sisa ruang.
  List<double> _effectiveWidths(double available) {
    if (_widths == null) return _autoWidths(available);
    final w = List.of(_widths!);
    final sum = w.fold(0.0, (a, b) => a + b);
    if (sum < available && w.isNotEmpty) w[w.length - 1] += available - sum;
    return w;
  }

  void _startDrag(int i, List<double> current) {
    setState(() {
      _widths ??= List.of(current);
      _dragHandle = i;
    });
  }

  void _updateDrag(int i, double dx) {
    if (_widths == null) return;
    setState(() {
      final next = _widths![i] + dx;
      _widths![i] = next < widget.minColumnWidth ? widget.minColumnWidth : next;
    });
  }

  void _endDrag() {
    if (_dragHandle == null) return;
    setState(() => _dragHandle = null);
    final key = widget.storageKey;
    if (key != null && _widths != null) _savedWidths[key] = List.of(_widths!);
  }

  void _resetWidths() {
    setState(() => _widths = null);
    final key = widget.storageKey;
    if (key != null) _savedWidths.remove(key);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);
    final borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final primary = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final rowHover = isDark ? const Color(0xFF1F2A33) : const Color(0xFFF6F8FA);

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite ? constraints.maxWidth : widget.minTableWidth;
        final widths = _effectiveWidths(available);
        final totalWidth = widths.fold(0.0, (a, b) => a + b);
        final n = widget.headers.length;

        // ---------- Header ----------
        final header = Container(
          color: headerBg,
          child: Row(
            children: List.generate(n, (i) {
              final isLast = i == n - 1;
              final active = _hoverHandle == i || _dragHandle == i;
              return SizedBox(
                width: widths[i],
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : _handleHitWidth / 2),
                      child: widget.headerBuilder != null
                          ? widget.headerBuilder!(context, i)
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              child: Text(
                                widget.headers[i],
                                style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                    ),
                    if (!isLast)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        width: _handleHitWidth,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeColumn,
                          onEnter: (_) => setState(() => _hoverHandle = i),
                          onExit: (_) => setState(() => _hoverHandle = null),
                          // Listener mentah: tidak ikut "gesture arena", jadi tidak
                          // direbut oleh scroll horizontal/vertikal di atasnya.
                          child: Listener(
                            behavior: HitTestBehavior.opaque,
                            onPointerDown: (e) {
                              if (e.kind == PointerDeviceKind.mouse && e.buttons != kPrimaryMouseButton) return;
                              _startDrag(i, widths);
                            },
                            onPointerMove: (e) {
                              if (_dragHandle == i) _updateDrag(i, e.delta.dx);
                            },
                            onPointerUp: (_) => _endDrag(),
                            onPointerCancel: (_) => _endDrag(),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onDoubleTap: _resetWidths,
                              child: Tooltip(
                                message: 'Geser untuk ubah lebar kolom • klik 2x untuk reset',
                                waitDuration: const Duration(milliseconds: 800),
                                child: Center(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    width: active ? 3 : 1.5,
                                    margin: EdgeInsets.symmetric(vertical: active ? 4 : 8),
                                    decoration: BoxDecoration(
                                      color: active ? primary : borderColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        );

        // ---------- Rows ----------
        final rows = List.generate(widget.rowCount, (r) {
          Widget row = Container(
            decoration: BoxDecoration(
              color: _hoverRow == r && widget.onRowTap != null ? rowHover : null,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: List.generate(n, (c) {
                return SizedBox(
                  width: widths[c],
                  child: Padding(
                    padding: EdgeInsets.only(right: c < n - 1 ? 8.0 : 0),
                    child: widget.cellBuilder(context, r, c),
                  ),
                );
              }),
            ),
          );
          if (widget.onRowTap != null) {
            row = MouseRegion(
              onEnter: (_) => setState(() => _hoverRow = r),
              onExit: (_) => setState(() => _hoverRow = null),
              child: GestureDetector(onTap: () => widget.onRowTap!(r), child: row),
            );
          }
          return row;
        });

        return Scrollbar(
          controller: _hCtrl,
          child: SingleChildScrollView(
            controller: _hCtrl,
            scrollDirection: Axis.horizontal,
            // Matikan scroll saat sedang resize supaya drag tidak "direbut"
            physics: _dragHandle != null ? const NeverScrollableScrollPhysics() : null,
            child: SizedBox(
              width: totalWidth,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [header, ...rows],
                  ),
                  // Garis bantu vertikal antar kolom (yang aktif disorot)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _ColumnLinesPainter(
                          widths: widths,
                          color: borderColor.withOpacity(0.55),
                          activeIndex: _dragHandle,
                          activeColor: primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColumnLinesPainter extends CustomPainter {
  final List<double> widths;
  final Color color;
  final int? activeIndex;
  final Color activeColor;

  _ColumnLinesPainter({
    required this.widths,
    required this.color,
    required this.activeIndex,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;
    double x = 0;
    for (var i = 0; i < widths.length - 1; i++) {
      x += widths[i];
      final isActive = i == activeIndex;
      paint
        ..color = isActive ? activeColor : color
        ..strokeWidth = isActive ? 2 : 1;
      canvas.drawLine(Offset(x - 0.5, 0), Offset(x - 0.5, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ColumnLinesPainter old) =>
      old.widths != widths || old.activeIndex != activeIndex || old.color != color;
}
