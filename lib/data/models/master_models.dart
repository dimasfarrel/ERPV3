// Model master data yang diambil dari server (bentuk field sesuai response asli API v2).

/// Kode `masterentity_type` (sumber: komentar kolom di farel.sql).
/// Semua master data disimpan di satu tabel `masterentity`, dibedakan angka ini.
/// Catatan: ini BUKAN `trans_type` (jenis transaksi), itu daftar terpisah.
class MasterEntityType {
  static const account = 1, itemType = 2, itemCategory = 3, item = 4;
  static const fixAssetCategory = 5, fixAsset = 6, customerCategory = 7, partner = 8;
  static const warehouse = 9, store = 10, userCategory = 11;
  static const negara = 12, provinsi = 13, kota = 14, kecamatan = 15, kelurahan = 16;
  static const brand = 17, kemasan = 18, expedisi = 19, reason = 20, jabatan = 21;
  static const termin = 22, uom = 23, tax = 24, kurs = 25, timbangan = 26, area = 27;
  static const prefix = 28, mesin = 29, loginKota = 30, device = 31, meja = 32;
  static const layanan = 33, pricebook = 34, role = 35, areaProduksi = 36, printer = 37;
  static const supplierCategory = 38, salesCategory = 39, graderCategory = 40;
  static const supplier = 41, sales = 42, grader = 43, promo = 44;
  static const tebal = 45, lebar = 46, panjang = 47, proses = 48;
}

/// Kode `trans_type` = `prefix_value` (konfirmasi backend: prefix = trans_type).
/// Sumber: daftar `prefixes` dari GET /business-context di server asli.
/// `prefix_id` (UUID) beda per business, jadi ambil dari AppProvider.prefixByType().
class TransType {
  // Pembelian
  static const purchaseQuotation = 1, purchaseOrder = 2, purchaseDelivery = 3;
  static const purchaseInvoice = 4, purchaseRetur = 5, bayarHutang = 6;
  static const uangMukaSupplier = 7, purchaseReturOrder = 9;
  // Penjualan
  static const salesQuotation = 13, salesOrder = 14, salesDelivery = 15;
  static const salesInvoice = 16, salesRetur = 17, bayarPiutang = 18, uangMukaPelanggan = 19;
  // Produksi
  static const assemblyQuotation = 25, assemblyOrder = 26, assembly = 27;
  static const disassemblyQuotation = 30, disassemblyOrder = 31, disassembly = 32;
  // Persediaan
  static const adjustmentQuotation = 40, adjustmentOrder = 41, adjustment = 42;
  static const transferAntarGudang = 50, terimaBarangMasuk = 51;
  static const transferKeluar = 55, transferMasuk = 56;
  // Keuangan
  static const orderJurnalUmum = 60, jurnalUmum = 61;
  static const orderArusMasuk = 62, arusMasuk = 63, orderArusKeluar = 64, arusKeluar = 65;
  static const orderPerpindahanDana = 66, perpindahanDana = 67;
  // Saldo awal
  static const saldoAwalBarangOrder = 80, saldoAwalBarang = 81;
  static const saldoAwalHutangOrder = 82, saldoAwalHutang = 83;
  static const saldoAwalPiutangOrder = 84, saldoAwalPiutang = 85;
  // Lain-lain
  static const loginAwal = 99;
  static const pembelianAktivaTetap = 100, penyusutanAktivaTetap = 101, penjualanAktivaTetap = 102;
  static const penyewaanAktivaTetap = 103, maintenanceAktivaTetap = 104;
  static const faktur = 110, tutupBuku = 999;
}

/// GET /staffs/trans  -> sales / agen / staff yang bisa dipilih di transaksi.
class StaffModel {
  final String id;
  final String code;
  final String name;
  final String categoryId;
  final String categoryCode;
  final String categoryName;

  StaffModel({
    required this.id,
    required this.code,
    required this.name,
    this.categoryId = '',
    this.categoryCode = '',
    this.categoryName = '',
  });

  factory StaffModel.fromJson(Map<String, dynamic> j) => StaffModel(
        id: j['staff_id']?.toString() ?? '',
        code: j['staff_code']?.toString() ?? '',
        name: j['staff_name']?.toString() ?? '',
        categoryId: j['staffcategory_id']?.toString() ?? '',
        categoryCode: j['staffcategory_code']?.toString() ?? '',
        categoryName: j['staffcategory_name']?.toString() ?? '',
      );
}

/// GET /termin/trans atau /dues/trans -> termin pembayaran (contoh: Termin 30 hari).
class DueModel {
  final String id;
  final String code;
  final String name;
  final int days;

  DueModel({required this.id, required this.code, required this.name, required this.days});

  factory DueModel.fromJson(Map<String, dynamic> j) {
    final rawDays = j['termin_days'] ??
        j['termin_value'] ??
        j['trans_terminhari'] ??
        j['due_value'] ??
        j['days'] ??
        j['hari'] ??
        j['value'];
    final parsedDays = rawDays is num
        ? rawDays.toInt()
        : int.tryParse(rawDays?.toString() ?? '') ?? 0;

    String rawName = (j['termin_name'] ??
            j['due_name'] ??
            j['trans_terminname'] ??
            j['name'] ??
            '')
        .toString()
        .trim();

    if (rawName.isEmpty) {
      rawName = 'Termin $parsedDays hari';
    }

    return DueModel(
      id: (j['termin_id'] ??
              j['due_id'] ??
              j['mastertermin_id'] ??
              j['id'] ??
              '')
          .toString(),
      code: (j['termin_code'] ??
              j['due_code'] ??
              j['code'] ??
              '')
          .toString(),
      name: rawName,
      days: parsedDays,
    );
  }

  String get displayName => name.isNotEmpty ? name : 'Termin $days hari';
}

/// GET /desks/trans  -> meja (dipakai untuk transaksi per meja, mis. resto / bilyar).
class DeskModel {
  final String id;
  final String code;
  final String name;

  DeskModel({required this.id, required this.code, required this.name});

  factory DeskModel.fromJson(Map<String, dynamic> j) => DeskModel(
        id: j['desk_id']?.toString() ?? '',
        code: j['desk_code']?.toString() ?? '',
        name: j['desk_name']?.toString() ?? '',
      );
}

/// GET /uoms/item?item_id=...
/// Satuan konversi per item (misal PCS, LSN, GROSS).
class ItemUomModel {
  final String id; // item_uom_id / masteritemuom_id
  final String? itemId;
  final String uomId;
  final String? businessId;
  final String uomName;
  final String? uomCode;
  final double conversion;
  final String? barcode;

  ItemUomModel({
    required this.id,
    this.itemId,
    required this.uomId,
    this.businessId,
    required this.uomName,
    this.uomCode,
    this.conversion = 1.0,
    this.barcode,
  });

  factory ItemUomModel.fromJson(Map<String, dynamic> j) {
    final code = j['uom_code']?.toString() ?? j['code']?.toString();
    final name = j['uom_name']?.toString() ?? j['name']?.toString() ?? j['masteruom_name']?.toString() ?? code ?? 'PCS';
    return ItemUomModel(
      id: j['item_uom_id']?.toString() ??
          j['masteritemuom_id']?.toString() ??
          j['itemuom_id']?.toString() ??
          j['id']?.toString() ??
          '',
      itemId: j['item_id']?.toString() ?? j['masteritem_id']?.toString(),
      uomId: j['uom_id']?.toString() ?? j['masteruom_id']?.toString() ?? '',
      businessId: j['business_id']?.toString(),
      uomName: name,
      uomCode: code,
      conversion: (j['conversion_factor'] as num?)?.toDouble() ??
          (j['conversion'] as num?)?.toDouble() ??
          (j['masteritemuom_konversi'] as num?)?.toDouble() ??
          1.0,
      barcode: j['barcode']?.toString() ?? j['masteritemuom_barcode']?.toString(),
    );
  }
}

/// GET /taxes/trans
/// Jenis pajak untuk transaksi (bisa dipilih per item).
class TaxModel {
  final String id; // tax_id / mastertax_id
  final String code;
  final String name;
  final double rate;

  TaxModel({
    required this.id,
    required this.code,
    required this.name,
    this.rate = 0.0,
  });

  factory TaxModel.fromJson(Map<String, dynamic> j) {
    final code = j['tax_code']?.toString() ?? j['code']?.toString() ?? '';
    final rawName = j['tax_name']?.toString() ?? j['name']?.toString() ?? '';
    final name = rawName.trim().isNotEmpty ? rawName : (code.isNotEmpty ? code : 'Pajak');
    final rate = (j['tax_value'] as num?)?.toDouble() ??
        (j['tax_rate'] as num?)?.toDouble() ??
        (j['rate'] as num?)?.toDouble() ??
        0.0;
    return TaxModel(
      id: j['tax_id']?.toString() ?? j['id']?.toString() ?? '',
      code: code,
      name: name,
      rate: rate,
    );
  }
}

/// GET /trans/payment/method
/// Metode pembayaran transaksi (berlaku untuk SO, SI, PO, PI).
class PaymentMethodModel {
  final String id;
  final String code;
  final String name;
  final String? accountId;
  final double value;
  final double secondaryValue;

  PaymentMethodModel({
    required this.id,
    required this.code,
    required this.name,
    this.accountId,
    this.value = 0.0,
    this.secondaryValue = 0.0,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> j) => PaymentMethodModel(
        id: j['payment_method_id']?.toString() ?? j['id']?.toString() ?? '',
        code: j['payment_method_code']?.toString() ?? j['code']?.toString() ?? '',
        name: j['payment_method_name']?.toString() ?? j['name']?.toString() ?? '',
        accountId: j['account_id']?.toString() ?? j['payment_method_id']?.toString() ?? j['id']?.toString(),
        value: (j['value'] as num?)?.toDouble() ?? 0.0,
        secondaryValue: (j['secondary_value'] as num?)?.toDouble() ?? 0.0,
      );
}

/// POST /trans
/// Request body lengkap untuk menyimpan transaksi baru ke backend sesuai spesifikasi API v2.
class TransactionCreateRequest {
  final TransactionHeader header;
  final List<TransactionItemLine> items;
  final List<Map<String, dynamic>> payments;
  final List<Map<String, dynamic>> batchSerialEntries;
  final int loyaltyPointInterval;
  final int loyaltyPointValue;

  TransactionCreateRequest({
    required this.header,
    required this.items,
    this.payments = const [],
    this.batchSerialEntries = const [],
    this.loyaltyPointInterval = 0,
    this.loyaltyPointValue = 0,
  });

  Map<String, dynamic> toJson() => {
    'transaction': header.toJson(),
    'items': items.map((i) => i.toJson()).toList(),
    'payments': payments,
    'batch_serial_entries': batchSerialEntries,
    'loyalty_point_interval': loyaltyPointInterval,
    'loyalty_point_value': loyaltyPointValue,
  };
}

class TransactionHeader {
  final String transactionType; // e.g. "16" untuk SI, "2" PO
  final String? sourceTransId;
  final String partnerId;
  final String warehouseId;
  final String storeId;
  final num exchangeRate;
  final String entryDate; // ISO 8601 string, misal "2026-10-12T11:20:39+07:00"
  final String notes;
  final num discountValue;
  final String taxIncluded; // "Y" or "N"
  final String discountIsPercentage; // "Y" or "N"
  final String? terminId;

  TransactionHeader({
    required this.transactionType,
    this.sourceTransId,
    required this.partnerId,
    required this.warehouseId,
    required this.storeId,
    this.exchangeRate = 1,
    required this.entryDate,
    this.notes = '',
    this.discountValue = 0,
    this.taxIncluded = 'Y',
    this.discountIsPercentage = 'N',
    this.terminId,
  });

  Map<String, dynamic> toJson() => {
    'trans_type': transactionType,
    'partner_id': partnerId,
    'warehouse_id': warehouseId,
    'store_id': storeId,
    'exchange_rate': exchangeRate,
    'entry_date': entryDate,
    'tax_included': taxIncluded,
    'notes': notes,
    if (sourceTransId != null && sourceTransId!.isNotEmpty) 'source_trans_id': sourceTransId,
    if (discountValue > 0) 'discount_value': discountValue,
    if (discountValue > 0) 'discount_is_percentage': discountIsPercentage,
    if (terminId != null && terminId!.isNotEmpty) 'due_id': terminId,
  };
}

class TransactionItemLine {
  final String itemUomId;
  final String? taxId;
  final int sequenceNumber;
  final num quantity;
  final num unitPrice;
  final num discountValue;

  TransactionItemLine({
    required this.itemUomId,
    this.taxId,
    required this.sequenceNumber,
    required this.quantity,
    required this.unitPrice,
    this.discountValue = 0,
  });

  Map<String, dynamic> toJson() => {
    'item_uom_id': itemUomId,
    if (taxId != null && taxId!.isNotEmpty) 'tax_id': taxId,
    'sequence_number': sequenceNumber,
    'qty': quantity,
    'unit_price': unitPrice,
    if (discountValue > 0) 'discount_value': discountValue,
  };
}
