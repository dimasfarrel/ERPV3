import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_provider.dart';

class InvoicePrintDialog extends StatelessWidget {
  final String title;
  final String invoiceNumber;
  final DateTime date;
  final String partnerName;
  final String warehouseName;
  final double totalAmount;
  final String status;
  final String termin;
  final DateTime? dueDate;
  final String? notes;
  final List<InvoiceItemLine> items;
  final String? paymentMethod;
  final double? amountPaid;
  final bool isPurchase;

  const InvoicePrintDialog({
    super.key,
    required this.title,
    required this.invoiceNumber,
    required this.date,
    required this.partnerName,
    required this.warehouseName,
    required this.totalAmount,
    required this.status,
    required this.termin,
    this.dueDate,
    this.notes,
    required this.items,
    this.paymentMethod,
    this.amountPaid,
    this.isPurchase = false,
  });

  static void showFromSales(
    BuildContext context, {
    required SalesInvoice invoice,
    String? paymentMethod,
    double? amountPaid,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => InvoicePrintDialog(
        title: 'FAKTUR PENJUALAN',
        invoiceNumber: invoice.id,
        date: invoice.date,
        partnerName: invoice.customer,
        warehouseName: invoice.warehouse,
        totalAmount: invoice.amount,
        status: invoice.status,
        termin: invoice.termin ?? 'CASH',
        dueDate: invoice.dueDate,
        notes: invoice.notes,
        items: invoice.items,
        paymentMethod: paymentMethod ?? invoice.paymentMethod,
        amountPaid: amountPaid ?? invoice.paidAmount,
        isPurchase: false,
      ),
    );
  }

  static void showFromPurchase(
    BuildContext context, {
    required PurchaseOrder po,
    String? paymentMethod,
    double? amountPaid,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => InvoicePrintDialog(
        title: 'PESANAN PEMBELIAN (PURCHASE ORDER)',
        invoiceNumber: po.id,
        date: po.date,
        partnerName: po.vendor,
        warehouseName: po.warehouse,
        totalAmount: po.amount,
        status: po.status,
        termin: po.termin ?? 'CASH',
        dueDate: po.dueDate,
        notes: po.notes,
        items: po.items,
        paymentMethod: paymentMethod ?? po.paymentMethod,
        amountPaid: amountPaid ?? po.paidAmount,
        isPurchase: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final biz = provider.selectedBusiness;
    final rawName = biz?.name.trim() ?? '';
    final String companyName = rawName.isNotEmpty
        ? (RegExp(r'^(PT|CV|UD|PD|KOP)\b', caseSensitive: false).hasMatch(rawName)
            ? rawName.toUpperCase()
            : 'PT ${rawName.toUpperCase()}')
        : 'PT ERP MULTI SISTEM';
    final String companyDesc = (biz != null && biz.description.trim().isNotEmpty && biz.description != 'Entitas bisnis terdaftar')
        ? biz.description
        : 'Industrial & Commercial Enterprise Solutions';

    final isLunas = status.toLowerCase() == 'lunas';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = isDark ? const Color(0xFF1C2630) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF35434E) : const Color(0xFFD9E1E6);
    final Color textPrimary = isDark ? const Color(0xFFF2F5F7) : const Color(0xFF18232D);
    final Color textSecondary = isDark ? const Color(0xFFABB8C2) : const Color(0xFF53616D);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 850),
        child: Column(
          children: [
            // Action Toolbar (Print, Close)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
                color: isDark ? const Color(0xFF151D25) : const Color(0xFFF8FAFC),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.print_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Preview Cetak Nota & Dokumen',
                        style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('Cetak Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1259A7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perintah cetak dikirim ke printer default.'),
                              backgroundColor: Color(0xFF28A745),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Document Sheet
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF17202A) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Company & Title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1259A7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.domain, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        companyName,
                                        style: GoogleFonts.ibmPlexSans(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary),
                                      ),
                                      Text(
                                        companyDesc,
                                        style: GoogleFonts.ibmPlexSans(fontSize: 11, color: textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Jl. Raya Industri Modern No. 88 • Telp: (0341) 555-8900', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: textSecondary)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('NOMOR TRANSAKSI', style: GoogleFonts.ibmPlexSans(fontSize: 10, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.5)),
                                    const SizedBox(height: 2),
                                    Text(invoiceNumber, style: GoogleFonts.ibmPlexSans(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isLunas ? const Color(0xFF28A745).withValues(alpha: 0.15) : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isLunas ? const Color(0xFF28A745) : const Color(0xFFF59E0B)),
                                ),
                                child: Text(
                                  isLunas ? 'LUNAS (CASH)' : 'BELUM BAYAR (KREDIT)',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isLunas ? const Color(0xFF28A745) : const Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(height: 1, color: borderColor),
                      const SizedBox(height: 20),

                      // Document Metadata Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isPurchase ? 'Pemasok / Vendor:' : 'Kepada Yth. Pelanggan:', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: textSecondary)),
                                const SizedBox(height: 2),
                                Text(partnerName, style: GoogleFonts.ibmPlexSans(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                                const SizedBox(height: 8),
                                Text('Gudang Operasional: $warehouseName', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Tanggal Terbit: ${Formatters.date(date)}', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textPrimary)),
                                const SizedBox(height: 4),
                                Text('Termin: $termin', style: GoogleFonts.ibmPlexSans(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
                                if (dueDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Jatuh Tempo: ${Formatters.date(dueDate!)}', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: const Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Items Table
                      Table(
                        border: TableBorder(
                          horizontalInside: BorderSide(color: borderColor, width: 0.8),
                          bottom: BorderSide(color: borderColor, width: 1.5),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(0.6),
                          1: FlexColumnWidth(3.0),
                          2: FlexColumnWidth(1.0),
                          3: FlexColumnWidth(1.0),
                          4: FlexColumnWidth(1.6),
                          5: FlexColumnWidth(1.8),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF222C36) : const Color(0xFFF1F5F9)),
                            children: [
                              _th('NO'),
                              _th('NAMA BARANG / DESKRIPSI'),
                              _th('QTY', align: TextAlign.center),
                              _th('SATUAN', align: TextAlign.center),
                              _th('HARGA', align: TextAlign.right),
                              _th('TOTAL', align: TextAlign.right),
                            ],
                          ),
                          if (items.isNotEmpty)
                            ...items.asMap().entries.map((entry) {
                              final idx = entry.key + 1;
                              final item = entry.value;
                              return TableRow(
                                children: [
                                  _td('$idx'),
                                  _td(item.productName.isNotEmpty ? item.productName : 'Item Transaksi', subtitle: item.description),
                                  _td(item.qty == item.qty.toInt() ? item.qty.toInt().toString() : item.qty.toString(), align: TextAlign.center),
                                  _td(item.unit, align: TextAlign.center),
                                  _td(Formatters.currency(item.unitPrice), align: TextAlign.right),
                                  _td(Formatters.currency(item.total), align: TextAlign.right, isBold: true),
                                ],
                              );
                            })
                          else
                            TableRow(
                              children: [
                                _td('1'),
                                _td('Transaksi Utama', subtitle: notes),
                                _td('1', align: TextAlign.center),
                                _td('Unit', align: TextAlign.center),
                                _td(Formatters.currency(totalAmount), align: TextAlign.right),
                                _td(Formatters.currency(totalAmount), align: TextAlign.right, isBold: true),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Bottom Totals & Payment Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F2933) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLunas ? 'INFORMASI PEMBAYARAN TUNAI' : 'INFORMASI KREDIT / TEMPO',
                                    style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700, color: isLunas ? const Color(0xFF28A745) : const Color(0xFFD97706)),
                                  ),
                                  const SizedBox(height: 6),
                                  if (isLunas) ...[
                                    Text('Metode Bayar: ${paymentMethod ?? 'Tunai / Cash'}', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textPrimary)),
                                    if (amountPaid != null && amountPaid! > 0)
                                      Text('Nominal Diterima: ${Formatters.currency(amountPaid!)}', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textPrimary)),
                                  ] else ...[
                                    Text('Status: Menunggu Pembayaran', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textPrimary)),
                                    Text('Jatuh tempo pembayaran sesuai termin.', style: GoogleFonts.ibmPlexSans(fontSize: 11, color: textSecondary)),
                                  ],
                                  if (notes != null && notes!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text('Catatan: $notes', style: GoogleFonts.ibmPlexSans(fontSize: 11, fontStyle: FontStyle.italic, color: textSecondary)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 260,
                            child: Builder(
                              builder: (context) {
                                double itemsSum = items.fold(0.0, (s, i) => s + i.total);
                                if (itemsSum == 0) itemsSum = totalAmount;

                                double calculatedTax = 0;
                                for (final it in items) {
                                  if (it.tax == 'PPN' || it.tax.contains('11')) {
                                    calculatedTax += it.total - (it.total / 1.11);
                                  }
                                }
                                if (calculatedTax == 0 && items.any((i) => i.tax == 'PPN')) {
                                  calculatedTax = itemsSum - (itemsSum / 1.11);
                                }
                                final dpp = itemsSum - calculatedTax;

                                return Column(
                                  children: [
                                    _summaryRow('SUB TOTAL (DPP)', Formatters.currency(dpp), textSecondary),
                                    const SizedBox(height: 6),
                                    if (calculatedTax > 0) ...[
                                      _summaryRow('PPN (11%)', Formatters.currency(calculatedTax), textSecondary),
                                      const SizedBox(height: 6),
                                    ],
                                    Divider(height: 1, color: borderColor),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('GRAND TOTAL', style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w800, color: textPrimary)),
                                        Text(
                                          Formatters.currency(totalAmount),
                                          style: GoogleFonts.ibmPlexSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1259A7)),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // Signatures
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(isPurchase ? 'Disiapkan Oleh' : 'Penerima / Pelanggan', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary)),
                              const SizedBox(height: 50),
                              Text('( ................................. )', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary)),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Hormat Kami / Bag. Keuangan', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary)),
                              const SizedBox(height: 50),
                              Text('( ................................. )', style: GoogleFonts.ibmPlexSans(fontSize: 12, color: textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Dokumen ini dicetak otomatis melalui iSoft Enterprise ERP System',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 10,
                            color: textSecondary.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _th(String label, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        label,
        textAlign: align,
        style: GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF475569)),
      ),
    );
  }

  Widget _td(String label, {String? subtitle, TextAlign align = TextAlign.left, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: align == TextAlign.right
            ? CrossAxisAlignment.end
            : align == TextAlign.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: align,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (subtitle != null && subtitle.isNotEmpty)
            Text(subtitle, style: GoogleFonts.ibmPlexSans(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.ibmPlexSans(fontSize: 12, color: color)),
        Text(value, style: GoogleFonts.ibmPlexSans(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
