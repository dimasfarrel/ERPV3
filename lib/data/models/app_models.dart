// ============================================================
//  ERP Enterprise - All Data Models (Pro & Lite Mode)
// ============================================================

enum AppEdition { pro, lite }

enum UserRole { administrator, manager, staff }

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.administrator:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
    }
  }
}

class AuthModel {
  final String username;
  final String password;
  final String location;
  final String port;
  final String database;

  AuthModel({
    this.username = '',
    this.password = '',
    this.location = '',
    this.port = '5432',
    this.database = '',
  });
}

class BusinessEntity {
  final String id;
  final String name;
  final String code;
  final String description;
  final String icon;
  final String category;
  final String activeProjects;

  BusinessEntity({
    required this.id,
    required this.name,
    this.code = '',
    this.description = '',
    this.icon = '🏢',
    this.category = 'Umum',
    this.activeProjects = '',
  });

  factory BusinessEntity.fromJson(Map<String, dynamic> json) {
    return BusinessEntity(
      id: json['id']?.toString() ?? json['business_id']?.toString() ?? json['uuid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '-',
      description: json['description'] ?? 'Entitas bisnis terdaftar',
    );
  }
}

class CostCenter {
  final String id;
  final String name;
  final String code;
  final String department;
  final String icon;

  CostCenter({
    required this.id,
    required this.name,
    required this.code,
    required this.department,
    required this.icon,
  });

  factory CostCenter.fromJson(Map<String, dynamic> json) {
    return CostCenter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '-',
      department: json['department']?.toString() ?? 'Operasional',
      icon: json['icon']?.toString() ?? '🏢',
    );
  }
}

class WarehouseEntity {
  final String id;
  final String name;
  final String code;
  final String location;
  final String pic;
  final int capacity;
  final int utilization;
  final bool isActive;

  WarehouseEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.pic,
    required this.capacity,
    required this.utilization,
    this.isActive = true,
  });

  factory WarehouseEntity.fromJson(Map<String, dynamic> json) {
    return WarehouseEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '-',
      location: json['location']?.toString() ?? 'Pusat',
      pic: json['pic']?.toString() ?? '-',
      capacity: int.tryParse(json['capacity']?.toString() ?? '1000') ?? 1000,
      utilization: int.tryParse(json['utilization']?.toString() ?? '50') ?? 50,
      isActive: json['is_active'] ?? true,
    );
  }
}

// ==========================================
// Sales & Receivables (AR Aging)
// ==========================================

class SalesInvoice {
  final String id;
  final DateTime date;
  final String customer;
  final String warehouse;
  final double amount;
  final String status;

  SalesInvoice({
    required this.id,
    required this.date,
    required this.customer,
    required this.warehouse,
    required this.amount,
    required this.status,
  });

  String get statusBadge {
    switch (status) {
      case 'Lunas': return 'success';
      case 'Belum Bayar': return 'warning';
      case 'Jatuh Tempo': return 'danger';
      default: return 'info';
    }
  }
}

class AccountsReceivable {
  final String id;
  final String soNumber;
  final String customer;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double totalAmount;
  double remainingAmount;
  final String agingBucket; // '0-30 Hari', '31-60 Hari', '61-90 Hari', '>90 Hari'
  String status; // 'Lancar', 'Perhatian', 'Macet', 'Lunas'

  AccountsReceivable({
    required this.id,
    required this.soNumber,
    required this.customer,
    required this.invoiceDate,
    required this.dueDate,
    required this.totalAmount,
    required this.remainingAmount,
    required this.agingBucket,
    required this.status,
  });
}

// ==========================================
// Purchasing & Payables (AP Aging)
// ==========================================

class PurchaseOrder {
  final String id;
  final DateTime date;
  final String vendor;
  final String warehouse;
  final double amount;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.date,
    required this.vendor,
    required this.warehouse,
    required this.amount,
    required this.status,
  });

  String get statusBadge {
    switch (status) {
      case 'Selesai Diterima': return 'success';
      case 'Menunggu Otorisasi': return 'warning';
      case 'Ditolak': return 'danger';
      default: return 'info';
    }
  }
}

class AccountsPayable {
  final String id;
  final String poNumber;
  final String supplier;
  final DateTime billDate;
  final DateTime dueDate;
  final double totalAmount;
  double remainingAmount;
  final String agingBucket;
  String status; // 'Normal', 'Segera Bayar', 'Jatuh Tempo', 'Lunas'

  AccountsPayable({
    required this.id,
    required this.poNumber,
    required this.supplier,
    required this.billDate,
    required this.dueDate,
    required this.totalAmount,
    required this.remainingAmount,
    required this.agingBucket,
    required this.status,
  });
}

// ==========================================
// Inventory, Stock & Multi-Gudang Mutasi
// ==========================================

class InventoryItem {
  final String id; // item_id dari API (kosong untuk data mock)
  final String sku;
  final String name;
  final String category;
  int stockAvailable;
  final int stockMin;
  double unitPrice;
  final double costPrice;
  final String unit;
  final String warehouse;

  InventoryItem({
    this.id = '',
    required this.sku,
    required this.name,
    required this.category,
    required this.stockAvailable,
    required this.stockMin,
    required this.unitPrice,
    this.costPrice = 0.0,
    required this.unit,
    this.warehouse = 'Gudang Utama',
  });

  String get stockStatus {
    if (stockAvailable <= 0) return 'Habis';
    if (stockAvailable < stockMin) return 'Menipis';
    if (stockAvailable < stockMin * 1.5) return 'Mendekati Batas';
    return 'Aman';
  }

  String get stockBadge {
    switch (stockStatus) {
      case 'Aman': return 'success';
      case 'Mendekati Batas': return 'warning';
      case 'Menipis': return 'danger';
      case 'Habis': return 'danger';
      default: return 'info';
    }
  }
}

class StockTransfer {
  final String id;
  final String transferNo;
  final DateTime date;
  final String sourceWarehouse;
  final String destWarehouse;
  final String sku;
  final String productName;
  final int quantity;
  final String unit;
  String status; // 'Selesai', 'Dalam Perjalanan', 'Draft'
  final String notes;

  StockTransfer({
    required this.id,
    required this.transferNo,
    required this.date,
    required this.sourceWarehouse,
    required this.destWarehouse,
    required this.sku,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.status,
    this.notes = '',
  });
}

// ==========================================
// Manufaktur & Perakitan (BOM & SPK)
// ==========================================

class BomComponent {
  final String sku;
  final String name;
  final int quantity;
  final String unit;
  final double unitCost;

  BomComponent({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitCost,
  });

  double get totalCost => quantity * unitCost;
}

class BillOfMaterials {
  final String id;
  final String bomCode;
  final String finishedGoodSku;
  final String finishedGoodName;
  final String outputUnit;
  final int outputQty;
  final List<BomComponent> components;
  final double directLaborCost;
  final double overheadCost;
  final String notes;

  BillOfMaterials({
    required this.id,
    required this.bomCode,
    required this.finishedGoodSku,
    required this.finishedGoodName,
    required this.outputUnit,
    required this.outputQty,
    required this.components,
    required this.directLaborCost,
    required this.overheadCost,
    this.notes = '',
  });

  double get totalMaterialCost => components.fold(0.0, (sum, c) => sum + c.totalCost);
  double get totalProductionCost => totalMaterialCost + directLaborCost + overheadCost;
  double get totalProductionCostPerUnit => outputQty > 0 ? totalProductionCost / outputQty : 0.0;
}

class WorkOrderAssembly {
  final String id;
  final String woNumber;
  final String bomId;
  final String bomCode;
  final String finishedGoodSku;
  final String finishedGoodName;
  final int quantityPlanned;
  int quantityCompleted;
  String status; // 'Terjadwal', 'Proses Perakitan', 'Quality Control', 'Selesai'
  final DateTime startDate;
  DateTime? completionDate;
  final String targetWarehouseName;
  final double estimatedLaborCost;
  final double totalManufacturedValue;
  final String assignedSupervisor;

  WorkOrderAssembly({
    required this.id,
    required this.woNumber,
    required this.bomId,
    required this.bomCode,
    required this.finishedGoodSku,
    required this.finishedGoodName,
    required this.quantityPlanned,
    this.quantityCompleted = 0,
    required this.status,
    required this.startDate,
    this.completionDate,
    required this.targetWarehouseName,
    required this.estimatedLaborCost,
    required this.totalManufacturedValue,
    required this.assignedSupervisor,
  });

  double get progress => quantityPlanned > 0 ? (quantityCompleted / quantityPlanned).clamp(0.0, 1.0) : 0.0;
}

class DisassemblyOrder {
  final String id;
  final String doNumber;
  final String sourceSku;
  final String sourceName;
  final int quantity;
  final String unit;
  final DateTime date;
  final String reason;
  final List<BomComponent> recoveredComponents;
  final double totalRecoveryValue;
  final String status;
  final String inspector;

  DisassemblyOrder({
    required this.id,
    required this.doNumber,
    required this.sourceSku,
    required this.sourceName,
    required this.quantity,
    required this.unit,
    required this.date,
    required this.reason,
    required this.recoveredComponents,
    required this.totalRecoveryValue,
    required this.status,
    required this.inspector,
  });
}

// ==========================================
// SDM & Penggajian (HR & Payroll)
// ==========================================

class Employee {
  final String id;
  final String nip;
  final String name;
  final String department;
  final String position;
  final double baseSalary;
  final double allowance;
  final String status; // 'Tetap' | 'Kontrak'
  final DateTime joinDate;
  final String email;
  final String phone;
  final String bankAccount;

  Employee({
    required this.id,
    required this.nip,
    required this.name,
    required this.department,
    required this.position,
    required this.baseSalary,
    required this.allowance,
    required this.status,
    required this.joinDate,
    required this.email,
    required this.phone,
    required this.bankAccount,
  });
}

class PayrollRecord {
  final String id;
  final String period;
  final String employeeId;
  final String employeeName;
  final String department;
  final double baseSalary;
  final double allowance;
  final double overtime;
  final double bpjsKetenagakerjaan;
  final double bpjsKesehatan;
  final double pph21;
  final DateTime paymentDate;
  String status; // 'Dibayar' | 'Pending'

  PayrollRecord({
    required this.id,
    required this.period,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.baseSalary,
    required this.allowance,
    required this.overtime,
    required this.bpjsKetenagakerjaan,
    required this.bpjsKesehatan,
    required this.pph21,
    required this.paymentDate,
    required this.status,
  });

  double get grossSalary => baseSalary + allowance + overtime;
  double get totalDeductions => bpjsKetenagakerjaan + bpjsKesehatan + pph21;
  double get netSalary => grossSalary - totalDeductions;
}

// ==========================================
// Keuangan & Akuntansi (COA & Journal)
// ==========================================

class ChartOfAccount {
  final String code;
  final String name;
  final String category; // 'Aset Lancar', 'Aset Tetap', 'Kewajiban', 'Ekuitas', 'Pendapatan', 'HPP', 'Beban Operasional'
  final String normalBalance; // 'Debit' | 'Kredit'
  double balance;

  ChartOfAccount({
    required this.code,
    required this.name,
    required this.category,
    required this.normalBalance,
    required this.balance,
  });
}

class JournalEntryLine {
  final String accountCode;
  final String accountName;
  final double debit;
  final double credit;

  JournalEntryLine({
    required this.accountCode,
    required this.accountName,
    required this.debit,
    required this.credit,
  });
}

class JournalEntry {
  final String id;
  final String entryNumber;
  final DateTime date;
  final String reference;
  final String description;
  final List<JournalEntryLine> lines;
  final double totalDebit;
  final double totalCredit;

  JournalEntry({
    required this.id,
    required this.entryNumber,
    required this.date,
    required this.reference,
    required this.description,
    required this.lines,
    required this.totalDebit,
    required this.totalCredit,
  });
}

// ==========================================
// Lite POS Mode Models
// ==========================================

class LiteCartItem {
  final InventoryItem product;
  int quantity;

  LiteCartItem({
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.unitPrice * quantity;
}

class LiteCashTransaction {
  final String id;
  final String type; // 'in' (Masuk/Modal) | 'out' (Keluar/Operasional)
  final String category;
  final double amount;
  final String note;
  final DateTime date;

  LiteCashTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.note,
    required this.date,
  });
}

class LiteDebt {
  final String id;
  final String orderNo;
  final String customerName;
  final String phone;
  final double amount;
  final DateTime orderDate;
  final DateTime dueDate;
  String status; // 'Belum Lunas' | 'Lunas'

  LiteDebt({
    required this.id,
    required this.orderNo,
    required this.customerName,
    required this.phone,
    required this.amount,
    required this.orderDate,
    required this.dueDate,
    this.status = 'Belum Lunas',
  });
}

// Legacy helpers
class RecentTransaction {
  final String id;
  final DateTime date;
  final String partner;
  final String type;
  final String amount;
  final String status;

  RecentTransaction({
    required this.id,
    required this.date,
    required this.partner,
    required this.type,
    required this.amount,
    required this.status,
  });

  String get statusBadge {
    switch (status) {
      case 'Completed': return 'success';
      case 'Processing': return 'info';
      case 'In Transit': return 'warning';
      case 'Pending Review': return 'danger';
      default: return 'info';
    }
  }
}

class ProductSku {
  final String sku;
  String name;
  String category;
  String unit;
  double salePrice;
  int stock;
  bool isActive;

  ProductSku({
    required this.sku,
    required this.name,
    required this.category,
    required this.unit,
    required this.salePrice,
    required this.stock,
    this.isActive = true,
  });
}

class CustomerModel {
  final String code;
  String companyName;
  String contact;
  String city;
  String type;
  double creditLimit;
  bool isActive;

  CustomerModel({
    required this.code,
    required this.companyName,
    required this.contact,
    required this.city,
    required this.type,
    required this.creditLimit,
    this.isActive = true,
  });
}

class VendorModel {
  final String code;
  String name;
  String contact;
  String city;
  String supplyCategory;
  int leadTimeDays;
  bool isActive;

  VendorModel({
    required this.code,
    required this.name,
    required this.contact,
    required this.city,
    required this.supplyCategory,
    required this.leadTimeDays,
    this.isActive = true,
  });
}
