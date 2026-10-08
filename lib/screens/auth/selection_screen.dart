import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/providers/app_provider.dart';
import '../../data/models/app_models.dart';

class SelectionScreen extends StatefulWidget {
  final int stepNumber; // 1: Business, 2: Cost Center, 3: Warehouse
  final String stepTitle;
  final String title;
  final String subtitle;
  final List<dynamic> items;
  final Function(dynamic) onSelect;
  final VoidCallback onBack;

  const SelectionScreen({
    super.key,
    required this.stepNumber,
    required this.stepTitle,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onSelect,
    required this.onBack,
  });

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  int? _hoveredIndex;

  // Design Tokens (Light Mode from MD)
  final Color _canvasColor = const Color(0xFFF6F8FA);
  final Color _baseColor = const Color(0xFFFFFFFF);
  final Color _subtleColor = const Color(0xFFEDF1F4);
  final Color _textPrimary = const Color(0xFF18232D);
  final Color _textSecondary = const Color(0xFF53616D);
  final Color _borderColor = const Color(0xFFD9E1E6);
  final Color _primaryColor = const Color(0xFF1259A7);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: _canvasColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(
              height: 3,
              child: provider.isLoading
                  ? LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor: Colors.transparent,
                      color: provider.primaryColor,
                    )
                  : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildActiveScopeBanner(provider),
                        const SizedBox(height: 24),
                        _buildTitleSection(),
                        const SizedBox(height: 24),
                        _buildGrid(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildFooter(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: _baseColor,
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.business_center, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enterprise ERP',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              Text(
                'Setup Lingkungan Kerja',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Steps
          Row(
            children: [
              _buildStepPill(1, 'Unit Bisnis', widget.stepNumber >= 1, widget.stepNumber == 1),
              _buildStepDivider(widget.stepNumber > 1),
              _buildStepPill(2, 'Cost Center', widget.stepNumber >= 2, widget.stepNumber == 2),
              _buildStepDivider(widget.stepNumber > 2),
              _buildStepPill(3, 'Gudang', widget.stepNumber >= 3, widget.stepNumber == 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepPill(int step, String label, bool isDoneOrCurrent, bool isCurrent) {
    final isDone = isDoneOrCurrent && !isCurrent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? _primaryColor : (isDone ? _subtleColor : _baseColor),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? _primaryColor : _borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDone)
            const Icon(Icons.check, size: 14, color: Color(0xFF087A65))
          else
            Text(
              '$step',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrent ? Colors.white : _textSecondary,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              color: isCurrent ? Colors.white : _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Container(
      width: 24,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? _primaryColor : _borderColor,
    );
  }

  Widget _buildActiveScopeBanner(AppProvider provider) {
    if (widget.stepNumber == 1) {
      return const SizedBox.shrink(); // Hide on first step to avoid clutter
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _baseColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _textSecondary, size: 18),
          const SizedBox(width: 8),
          Text(
            'Konteks Aktif:',
            style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w500, color: _textSecondary),
          ),
          const SizedBox(width: 12),
          if (provider.selectedBusiness != null)
            _scopeBadge(Icons.business, provider.selectedBusiness!.name),
          if (provider.selectedCostCenter != null) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: _textSecondary, size: 16),
            const SizedBox(width: 8),
            _scopeBadge(Icons.account_tree, provider.selectedCostCenter!.name),
          ],
        ],
      ),
    );
  }

  Widget _scopeBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _subtleColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _textPrimary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w500, color: _textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.stepTitle.toUpperCase(),
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.title,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: widget.stepNumber == 3 ? 1.4 : 1.6,
          ),
          itemCount: widget.items.length,
          itemBuilder: (ctx, i) => _buildCard(widget.items[i], i),
        );
      },
    );
  }

  Widget _buildCard(dynamic item, int index) {
    String name = '';
    String code = '';
    String desc = '';
    String badge = '';
    IconData iconData = Icons.domain;

    if (item is BusinessEntity) {
      name = item.name;
      code = item.code;
      desc = item.description;
      badge = item.category;
      iconData = Icons.apartment;
    } else if (item is CostCenter) {
      name = item.name;
      code = item.code;
      desc = 'Departemen ${item.department}';
      badge = item.department;
      iconData = Icons.account_tree_outlined;
    } else if (item is WarehouseEntity) {
      name = item.name;
      code = item.code;
      desc = 'Lokasi: ${item.location}';
      badge = '${item.capacity} Kapasitas';
      iconData = Icons.inventory_2_outlined;
    }

    final isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: () => widget.onSelect(item),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isHovered ? _subtleColor : _baseColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHovered ? _primaryColor : _borderColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _canvasColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Icon(iconData, size: 20, color: _textPrimary),
                  ),
                  const Spacer(),
                  Text(
                    code,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                name,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  color: _textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _canvasColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: _borderColor),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.ibmPlexSans(fontSize: 11, color: _textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: _baseColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(
              widget.stepNumber == 1 ? 'Kembali ke Login' : 'Kembali',
              style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _textPrimary,
              side: BorderSide(color: _borderColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const Spacer(),
          // User profile indicator
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: _textSecondary),
              const SizedBox(width: 8),
              Text(
                provider.username,
                style: GoogleFonts.ibmPlexSans(fontSize: 13, color: _textPrimary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
