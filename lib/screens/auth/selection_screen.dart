import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/app_models.dart';
import '../../widgets/common/erp_card.dart';

// Generic selection screen for Business, Cost Center, and Warehouse
class SelectionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<dynamic> items;
  final Function(dynamic) onSelect;
  final Function onBack;

  const SelectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onSelect,
    required this.onBack,
  });

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> with TickerProviderStateMixin {
  int? _hoveredIndex;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            Positioned(top: -100, right: -80, child: _blob(400, AppColors.primary.withOpacity(0.07))),
            Positioned(bottom: -120, left: -100, child: _blob(350, AppColors.primary.withOpacity(0.04))),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildGrid()),
                    _buildNavBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
        ),
        child: Column(
          children: [
            Text(widget.title, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.secondary)),
            const SizedBox(height: 4),
            Text(widget.subtitle, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: widget.items.length,
      itemBuilder: (ctx, i) => _buildCard(widget.items[i], i),
    );
  }

  Widget _buildCard(dynamic item, int index) {
    String icon = '';
    String name = '';
    String code = '';
    String desc = '';
    String sub = '';

    if (item is BusinessEntity) {
      icon = item.icon; name = item.name; code = item.code;
      desc = item.description; sub = item.activeProjects;
    } else if (item is CostCenter) {
      icon = item.icon; name = item.name; code = item.code;
      desc = item.department; sub = '';
    } else if (item is WarehouseEntity) {
      icon = '🏭'; name = item.name; code = item.code;
      desc = item.location; sub = '${item.utilization}% Terpakai';
    }

    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: () => widget.onSelect(item),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isHovered ? AppColors.primarySurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isHovered ? AppColors.primary : AppColors.borderLight, width: isHovered ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: isHovered ? AppColors.primary.withOpacity(0.12) : Colors.black.withOpacity(0.04),
                  blurRadius: isHovered ? 20 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 28)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(code, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(desc, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(sub, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => widget.onBack(),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Kembali'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
        ),
      ),
    );
  }
}
