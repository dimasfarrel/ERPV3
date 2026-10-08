import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResizableTable extends StatefulWidget {
  final List<String> headers;
  final List<double> initialFlexes;
  final double minTableWidth;
  final int rowCount;
  final Widget Function(BuildContext context, int rowIndex, int colIndex) cellBuilder;

  const ResizableTable({
    super.key,
    required this.headers,
    required this.initialFlexes,
    this.minTableWidth = 1000,
    required this.rowCount,
    required this.cellBuilder,
  });

  @override
  State<ResizableTable> createState() => _ResizableTableState();
}

class _ResizableTableState extends State<ResizableTable> {
  late List<double> _flexes;

  @override
  void initState() {
    super.initState();
    _flexes = List.from(widget.initialFlexes);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF25303A) : const Color(0xFFEDF1F4);
    final borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double tableWidth = constraints.maxWidth > widget.minTableWidth ? constraints.maxWidth : widget.minTableWidth;
        final double totalFlex = _flexes.fold(0.0, (a, b) => a + b);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  color: headerBg,
                  child: Row(
                    children: List.generate(widget.headers.length, (i) {
                      final colWidth = (_flexes[i] / totalFlex) * tableWidth;
                      return Row(
                        children: [
                          SizedBox(
                            width: colWidth - (i < widget.headers.length - 1 ? 8 : 0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              child: Text(
                                widget.headers[i],
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (i < widget.headers.length - 1)
                            MouseRegion(
                              cursor: SystemMouseCursors.resizeLeftRight,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    double deltaFlex = (details.delta.dx / tableWidth) * totalFlex;
                                    
                                    if (_flexes[i] + deltaFlex < 0.2) {
                                      deltaFlex = 0.2 - _flexes[i];
                                    }
                                    if (_flexes[i+1] - deltaFlex < 0.2) {
                                      deltaFlex = _flexes[i+1] - 0.2;
                                    }
                                    
                                    _flexes[i] += deltaFlex;
                                    _flexes[i+1] -= deltaFlex;
                                  });
                                },
                                child: Container(
                                  width: 8,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Container(
                                      width: 1,
                                      height: 20,
                                      color: borderColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
                // Rows
                ...List.generate(widget.rowCount, (r) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: borderColor)),
                    ),
                    child: Row(
                      children: List.generate(widget.headers.length, (c) {
                        final colWidth = (_flexes[c] / totalFlex) * tableWidth;
                        return SizedBox(
                          width: colWidth,
                          child: Padding(
                            padding: EdgeInsets.only(right: c < widget.headers.length - 1 ? 8.0 : 0),
                            child: widget.cellBuilder(context, r, c),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
