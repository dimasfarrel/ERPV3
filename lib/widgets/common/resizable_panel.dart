import 'package:flutter/material.dart';

class ResizablePanel extends StatefulWidget {
  final Widget child;
  final double initialHeight;
  final double minHeight;
  
  const ResizablePanel({
    super.key,
    required this.child,
    this.initialHeight = 300,
    this.minHeight = 150,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final handleColor = isDark ? Colors.white38 : Colors.black26;

    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 12,
            child: widget.child,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 12,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _height = (_height + details.delta.dy).clamp(widget.minHeight, 2000.0);
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
