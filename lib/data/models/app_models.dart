// ============================================================
//  ERP Malang - All Data Models
// ============================================================

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
    required this.code,
    required this.description,
    required this.icon,
    required this.category,
    required this.activeProjects,
  });
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
}

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

class InventoryItem {
  final String sku;
  final String name;
  final String category;
  final int stockAvailable;
  final int stockMin;
  final double unitPrice;
  final String unit;

  InventoryItem({
    required this.sku,
    required this.name,
    required this.category,
    required this.stockAvailable,
    required this.stockMin,
    required this.unitPrice,
    required this.unit,
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

class JournalEntry {
  final String id;
  final DateTime date;
  final String description;
  final String account;
  final double debit;
  final double credit;
  final String status;

  JournalEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.account,
    required this.debit,
    required this.credit,
    required this.status,
  });
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
