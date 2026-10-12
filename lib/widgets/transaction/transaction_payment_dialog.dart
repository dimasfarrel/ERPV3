import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/master_models.dart';
import '../../data/providers/app_provider.dart';

class PaymentResult {
  final String paymentMethodId;
  final String paymentMethodCode;
  final String paymentMethodName;
  final String? accountId;
  final double amountPaid;
  final double change;
  final DateTime paymentDate;
  final String reference;
  final String note;

  PaymentResult({
    required this.paymentMethodId,
    required this.paymentMethodCode,
    required this.paymentMethodName,
    this.accountId,
    required this.amountPaid,
    required this.change,
    required this.paymentDate,
    required this.reference,
    required this.note,
  });

  String get paymentMethod => paymentMethodName;
  double get paidAmount => amountPaid;
  Map<String, dynamic> toBackendMap() => toBackendPayload();

  Map<String, dynamic> toBackendPayload() {
    String accId = accountId ?? paymentMethodId;
    final uuidReg = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (!uuidReg.hasMatch(accId)) {
      accId = 'ae813d56-e1d8-11ef-976d-6c3be5bcbf18'; // Real Kas UUID
    }
    return {
      'account_id': accId,
      'sequence_number': 1,
      'qty': 1,
      'amount': amountPaid,
      'tendered_amount': amountPaid + change,
      'is_payment': 'Y',
      'is_down_payment': 'N',
    };
  }
}

class TransactionPaymentDialog extends StatefulWidget {
  final String transactionId;
  final double totalAmount;
  final String partnerName;
  final bool isPurchase;
  final ValueChanged<PaymentResult> onConfirm;

  const TransactionPaymentDialog({
    super.key,
    required this.transactionId,
    required this.totalAmount,
    required this.partnerName,
    this.isPurchase = false,
    required this.onConfirm,
  });

  static Future<PaymentResult?> show(
    BuildContext context, {
    required String transactionId,
    required double totalAmount,
    required String partnerName,
    bool isPurchase = false,
  }) {
    return showDialog<PaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TransactionPaymentDialog(
        transactionId: transactionId,
        totalAmount: totalAmount,
        partnerName: partnerName,
        isPurchase: isPurchase,
        onConfirm: (result) => Navigator.pop(ctx, result),
      ),
    );
  }

  @override
  State<TransactionPaymentDialog> createState() => _TransactionPaymentDialogState();
}

class _TransactionPaymentDialogState extends State<TransactionPaymentDialog> {
  late TextEditingController _amountCtrl;
  final _refCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  PaymentMethodModel? _selectedMethod;

  final List<PaymentMethodModel> _defaultMethods = [
    PaymentMethodModel(id: 'ae813d56-e1d8-11ef-976d-6c3be5bcbf18', code: 'KAS', name: 'Kas'),
    PaymentMethodModel(id: 'ae82ac7e-e1d8-11ef-976d-6c3be5bcbf18', code: 'BANK', name: 'Bank'),
    PaymentMethodModel(id: '0e5bc8d1-598d-11f0-ae3e-6c3be5bcbf18', code: 'CC', name: 'BANK KARTU KREDIT', value: 1.25),
  ];

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.totalAmount.toStringAsFixed(0));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AppProvider>();
      if (provider.paymentMethods.isEmpty) {
        await provider.fetchPaymentMethods();
      }
      final methods = provider.paymentMethods.isNotEmpty ? provider.paymentMethods : _defaultMethods;
      if (mounted) {
        setState(() {
          _selectedMethod = methods.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  double get _enteredAmount {
    final clean = _amountCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  double get _change => (_enteredAmount - widget.totalAmount).clamp(0, double.infinity);
  double get _remaining => (widget.totalAmount - _enteredAmount).clamp(0, double.infinity);

  void _applyQuickAmount(double amount) {
    setState(() {
      _amountCtrl.text = amount.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final methods = provider.paymentMethods.isNotEmpty ? provider.paymentMethods : _defaultMethods;

    final Color cardBg = isDark ? const Color(0xFF1C2630) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);
    final Color primaryColor = isDark ? const Color(0xFF78B7FF) : const Color(0xFF1259A7);
    final Color successColor = const Color(0xFF28A745);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isPurchase ? Icons.account_balance_wallet_outlined : Icons.payments_outlined,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isPurchase ? 'Pembayaran Pembelian (PO)' : 'Halaman Pembayaran Kasir / Faktur',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '${widget.transactionId} • ${widget.partnerName}',
                          style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: borderColor),
              const SizedBox(height: 20),

              // Total Tagihan Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141C24) : const Color(0xFFF4F7F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL TAGIHAN (CASH)',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.currency(widget.totalAmount),
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: successColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Termin = 0 (Cash)',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pilihan Metode Pembayaran
              Text(
                'Metode Pembayaran',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                  color: isDark ? const Color(0xFF17202A) : Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PaymentMethodModel>(
                    isExpanded: true,
                    value: _selectedMethod ?? (methods.isNotEmpty ? methods.first : null),
                    dropdownColor: cardBg,
                    items: methods.map((m) {
                      return DropdownMenuItem<PaymentMethodModel>(
                        value: m,
                        child: Row(
                          children: [
                            Icon(
                              m.code.toUpperCase().contains('CASH')
                                  ? Icons.money
                                  : m.code.toUpperCase().contains('QRIS')
                                      ? Icons.qr_code_2
                                      : Icons.account_balance,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              m.name,
                              style: GoogleFonts.ibmPlexSans(fontSize: 13, color: textPrimary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMethod = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Jumlah Bayar
              Text(
                'Jumlah yang Dibayarkan',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
                  hintText: '0',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: primaryColor, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),

              // Quick Amount Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  ActionChip(
                    label: const Text('Uang Pas'),
                    labelStyle: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600),
                    onPressed: () => _applyQuickAmount(widget.totalAmount),
                  ),
                  if (_enteredAmount < widget.totalAmount) ...[
                    ActionChip(
                      label: Text('+ ${Formatters.currency(10000)}'),
                      labelStyle: GoogleFonts.ibmPlexSans(fontSize: 11),
                      onPressed: () => _applyQuickAmount(_enteredAmount + 10000),
                    ),
                    ActionChip(
                      label: Text('+ ${Formatters.currency(50000)}'),
                      labelStyle: GoogleFonts.ibmPlexSans(fontSize: 11),
                      onPressed: () => _applyQuickAmount(_enteredAmount + 50000),
                    ),
                    ActionChip(
                      label: Text('+ ${Formatters.currency(100000)}'),
                      labelStyle: GoogleFonts.ibmPlexSans(fontSize: 11),
                      onPressed: () => _applyQuickAmount(_enteredAmount + 10000),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Perhitungan Kembalian / Sisa
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _enteredAmount >= widget.totalAmount
                      ? successColor.withValues(alpha: 0.10)
                      : const Color(0xFFE55353).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _enteredAmount >= widget.totalAmount ? 'Kembalian:' : 'Sisa Tagihan (Kurang):',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _enteredAmount >= widget.totalAmount ? successColor : const Color(0xFFE55353),
                      ),
                    ),
                    Text(
                      Formatters.currency(_enteredAmount >= widget.totalAmount ? _change : _remaining),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _enteredAmount >= widget.totalAmount ? successColor : const Color(0xFFE55353),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nomor Referensi & Catatan
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No. Referensi / Trx ID', style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _refCtrl,
                          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Opsional (misal: No. Ref BCA)',
                            hintStyle: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Catatan Pembayaran', style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _noteCtrl,
                          style: GoogleFonts.ibmPlexSans(fontSize: 13, color: textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Lunas Tunai',
                            hintStyle: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: borderColor)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Text('Batal', style: GoogleFonts.ibmPlexSans(color: textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      'Konfirmasi & Selesaikan',
                      style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      final method = _selectedMethod ?? (methods.isNotEmpty ? methods.first : _defaultMethods.first);
                      final result = PaymentResult(
                        paymentMethodId: method.id,
                        paymentMethodCode: method.code,
                        paymentMethodName: method.name,
                        accountId: method.accountId ?? method.id,
                        amountPaid: _enteredAmount,
                        change: _change,
                        paymentDate: _paymentDate,
                        reference: _refCtrl.text.trim(),
                        note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : 'Lunas Cash',
                      );
                      widget.onConfirm(result);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
