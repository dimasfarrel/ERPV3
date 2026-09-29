import 'package:flutter/foundation.dart';
import '../models/app_models.dart';

enum AppView { login, business, costCenter, gudang, dashboard }

class AppProvider extends ChangeNotifier {
  AppView _currentView = AppView.login;
  String _activeModule = 'overview';
  bool _isLoading = false;
  String _searchQuery = '';

  // Auth state
  bool _isLoggedIn = false;
  String _username = 'admin_malang';
  String _userDatabase = 'ERP_MALANG_PROD';

  // Selections
  BusinessEntity? _selectedBusiness;
  CostCenter? _selectedCostCenter;
  WarehouseEntity? _selectedWarehouse;

  // Tab management
  List<Map<String, String>> _openTabs = [
    {'id': 'overview', 'name': 'Dashboard'},
    {'id': 'sales', 'name': 'Penjualan'},
    {'id': 'purchasing', 'name': 'Pembelian'},
  ];

  // Getters
  AppView get currentView => _currentView;
  String get activeModule => _activeModule;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get userDatabase => _userDatabase;
  BusinessEntity? get selectedBusiness => _selectedBusiness;
  CostCenter? get selectedCostCenter => _selectedCostCenter;
  WarehouseEntity? get selectedWarehouse => _selectedWarehouse;
  List<Map<String, String>> get openTabs => _openTabs;

  // ==================== Mock Data ====================

  final List<BusinessEntity> businessEntities = [
    BusinessEntity(
      id: 'biz-1', name: 'PT Malang Manufaktur Utama', code: 'MMU-01',
      description: 'Pusat operasional manufaktur, perakitan komponen, dan jalur produksi terpadu Jawa Timur.',
      icon: '🏭', category: 'Manufaktur & Pabrikasi', activeProjects: '14 Proyek Aktif',
    ),
    BusinessEntity(
      id: 'biz-2', name: 'PT Distribusi Logistik Malang', code: 'DLM-02',
      description: 'Unit distribusi rantai pasok, armada pengiriman regional, dan pengelolaan kargo antarkota.',
      icon: '🚚', category: 'Distribusi & Ekspedisi', activeProjects: '8 Rute Distribusi',
    ),
    BusinessEntity(
      id: 'biz-3', name: 'Malang Retail & Niaga Prima', code: 'RNP-03',
      description: 'Jaringan gerai retail, point of sale langsung konsumen, dan pusat penjualan produk jadi.',
      icon: '🛒', category: 'Retail & Komersial', activeProjects: '6 Outlet Cabang',
    ),
    BusinessEntity(
      id: 'biz-4', name: 'PT Solusi Agrobisnis Malang', code: 'SAM-04',
      description: 'Pengolahan hasil komoditas, pendingin sentral, dan pengadaan bahan baku primer industri.',
      icon: '🌱', category: 'Agrobisnis & Pangan', activeProjects: '5 Sentra Tani',
    ),
  ];

  final List<CostCenter> costCenters = [
    CostCenter(id: 'cc-1', name: 'Produksi & Manufaktur', code: 'CC-PROD', department: 'Lantai Produksi', icon: '⚙️'),
    CostCenter(id: 'cc-2', name: 'Penjualan & Distribusi', code: 'CC-SALES', department: 'Divisi Penjualan', icon: '📊'),
    CostCenter(id: 'cc-3', name: 'Administrasi & Umum', code: 'CC-ADM', department: 'Kantor Pusat', icon: '🏢'),
    CostCenter(id: 'cc-4', name: 'R&D & Inovasi', code: 'CC-RND', department: 'Riset Teknologi', icon: '🔬'),
    CostCenter(id: 'cc-5', name: 'Logistik & Supply Chain', code: 'CC-LOG', department: 'Pengadaan & Gudang', icon: '📦'),
    CostCenter(id: 'cc-6', name: 'Keuangan & Akuntansi', code: 'CC-FIN', department: 'Departemen Keuangan', icon: '💰'),
  ];

  final List<WarehouseEntity> warehouses = [
    WarehouseEntity(id: 'wh-1', name: 'Gudang Utama Malang', code: 'GD-MLG-01', location: 'Jl. Industri Raya No.12, Malang', pic: 'Budi Santoso', capacity: 5000, utilization: 78),
    WarehouseEntity(id: 'wh-2', name: 'Gudang Transit Singosari', code: 'GD-SGS-02', location: 'Kawasan Industri Singosari, Malang', pic: 'Rina Wijaya', capacity: 2000, utilization: 58),
    WarehouseEntity(id: 'wh-3', name: 'Gudang Bahan Baku (Batu)', code: 'GD-BTU-03', location: 'Jl. Agro No.5, Batu', pic: 'Hendra Kurniawan', capacity: 3000, utilization: 42),
    WarehouseEntity(id: 'wh-4', name: 'Gudang Distribusi Retail', code: 'GD-RTL-04', location: 'Jl. Lowokwaru No.7, Malang', pic: 'Sari Dewi', capacity: 1500, utilization: 91),
  ];

  List<SalesInvoice> salesInvoices = [
    SalesInvoice(id: 'INV-2026-001', date: DateTime(2026, 9, 19), customer: 'PT Surya Gemilang Kencana', warehouse: 'Gudang Utama Malang', amount: 48500000, status: 'Lunas'),
    SalesInvoice(id: 'INV-2026-002', date: DateTime(2026, 9, 17), customer: 'PT Bintang Mitra Sejahtera', warehouse: 'Gudang Transit Singosari', amount: 32200000, status: 'Lunas'),
    SalesInvoice(id: 'INV-2026-003', date: DateTime(2026, 9, 15), customer: 'CV Cipta Karya Mandiri', warehouse: 'Gudang Distribusi Retail', amount: 18750000, status: 'Belum Bayar'),
    SalesInvoice(id: 'INV-2026-004', date: DateTime(2026, 9, 12), customer: 'Toko Makmur Sentosa Malang', warehouse: 'Gudang Utama Malang', amount: 9400000, status: 'Jatuh Tempo'),
  ];

  List<PurchaseOrder> purchaseOrders = [
    PurchaseOrder(id: 'PO-2026-088', date: DateTime(2026, 9, 18), vendor: 'CV Multi Baja Nusantara', warehouse: 'Gudang Bahan Baku (Batu)', amount: 112000000, status: 'Menunggu Otorisasi'),
    PurchaseOrder(id: 'PO-2026-087', date: DateTime(2026, 9, 16), vendor: 'PT Delta Elektronik Utama', warehouse: 'Gudang Utama Malang', amount: 84750000, status: 'Selesai Diterima'),
    PurchaseOrder(id: 'PO-2026-086', date: DateTime(2026, 9, 14), vendor: 'PT Logam Presisi Abadi', warehouse: 'Gudang Transit Singosari', amount: 45000000, status: 'Selesai Diterima'),
  ];

  List<RecentTransaction> recentTransactions = [
    RecentTransaction(id: 'INV-2026-001', date: DateTime(2026, 9, 19), partner: 'PT Surya Gemilang Kencana', type: 'Sales Order', amount: 'Rp 48.500.000', status: 'Completed'),
    RecentTransaction(id: 'PO-2026-088', date: DateTime(2026, 9, 18), partner: 'CV Multi Baja Nusantara', type: 'Purchase Order', amount: 'Rp 112.000.000', status: 'Processing'),
    RecentTransaction(id: 'TRF-2026-034', date: DateTime(2026, 9, 18), partner: 'Gudang Singosari → Malang', type: 'Stock Transfer', amount: '350 Units', status: 'In Transit'),
    RecentTransaction(id: 'INV-2026-002', date: DateTime(2026, 9, 17), partner: 'PT Bintang Mitra Sejahtera', type: 'Sales Order', amount: 'Rp 32.200.000', status: 'Completed'),
    RecentTransaction(id: 'PO-2026-087', date: DateTime(2026, 9, 16), partner: 'PT Delta Elektronik Utama', type: 'Purchase Order', amount: 'Rp 84.750.000', status: 'Completed'),
    RecentTransaction(id: 'RET-2026-005', date: DateTime(2026, 9, 15), partner: 'Toko Makmur Sentosa', type: 'Customer Return', amount: 'Rp 4.100.000', status: 'Pending Review'),
  ];

  List<InventoryItem> inventoryItems = [
    InventoryItem(sku: 'SKU-MCH-001', name: 'Komponen Mesin Seri MX-400', category: 'Mesin & Sparepart', stockAvailable: 48, stockMin: 10, unitPrice: 2500000, unit: 'Pcs'),
    InventoryItem(sku: 'SKU-RAW-009', name: 'Pelat Baja Cold-Rolled 3mm', category: 'Bahan Baku', stockAvailable: 8, stockMin: 25, unitPrice: 850000, unit: 'Lembar'),
    InventoryItem(sku: 'SKU-ELC-042', name: 'Inverter Listrik Industri 5KW', category: 'Elektronik', stockAvailable: 14, stockMin: 5, unitPrice: 4100000, unit: 'Unit'),
    InventoryItem(sku: 'SKU-FLX-012', name: 'Hydraulic Hose Tube 1/2 Inch', category: 'Pneumatik', stockAvailable: 6, stockMin: 15, unitPrice: 1200000, unit: 'Roll'),
    InventoryItem(sku: 'SKU-CHM-033', name: 'Oli Mesin Industri SAE 30', category: 'Bahan Kimia', stockAvailable: 32, stockMin: 10, unitPrice: 180000, unit: 'Liter'),
  ];

  List<JournalEntry> journalEntries = [
    JournalEntry(id: 'JRN-2026-001', date: DateTime(2026, 9, 19), description: 'Penjualan barang ke PT Surya Gemilang', account: 'Piutang Usaha / Pendapatan', debit: 48500000, credit: 48500000, status: 'Posted'),
    JournalEntry(id: 'JRN-2026-002', date: DateTime(2026, 9, 18), description: 'Pembelian bahan baku dari CV Logistik Prima', account: 'Persediaan / Hutang Usaha', debit: 24000000, credit: 24000000, status: 'Posted'),
    JournalEntry(id: 'JRN-2026-003', date: DateTime(2026, 9, 17), description: 'Biaya operasional gaji karyawan', account: 'Beban Gaji / Kas', debit: 85000000, credit: 85000000, status: 'Posted'),
    JournalEntry(id: 'JRN-2026-004', date: DateTime(2026, 9, 15), description: 'PPN Keluaran Penjualan September', account: 'PPN Keluaran / Hutang PPN', debit: 5335000, credit: 5335000, status: 'Draft'),
  ];

  List<ProductSku> products = [
    ProductSku(sku: 'SKU-MCH-001', name: 'Komponen Mesin Seri MX-400', category: 'Mesin', unit: 'Pcs', salePrice: 3200000, stock: 48),
    ProductSku(sku: 'SKU-RAW-009', name: 'Pelat Baja Cold-Rolled 3mm', category: 'Bahan Baku', unit: 'Lembar', salePrice: 1100000, stock: 8),
    ProductSku(sku: 'SKU-ELC-042', name: 'Inverter Listrik Industri 5KW', category: 'Elektronik', unit: 'Unit', salePrice: 5200000, stock: 14),
  ];

  List<CustomerModel> customers = [
    CustomerModel(code: 'CUST-001', companyName: 'PT Surya Gemilang Kencana', contact: 'Hendra - 081234567890', city: 'Malang', type: 'Distributor', creditLimit: 500000000),
    CustomerModel(code: 'CUST-002', companyName: 'PT Bintang Mitra Sejahtera', contact: 'Rina - 087654321098', city: 'Surabaya', type: 'Retailer', creditLimit: 200000000),
    CustomerModel(code: 'CUST-003', companyName: 'CV Cipta Karya Mandiri', contact: 'Bambang - 085678901234', city: 'Batu', type: 'End User', creditLimit: 100000000),
  ];

  List<VendorModel> vendors = [
    VendorModel(code: 'VND-001', name: 'CV Multi Baja Nusantara', contact: 'Agus - 081212121212', city: 'Surabaya', supplyCategory: 'Baja & Logam', leadTimeDays: 7),
    VendorModel(code: 'VND-002', name: 'PT Delta Elektronik Utama', contact: 'Susi - 082323232323', city: 'Jakarta', supplyCategory: 'Elektronik Industri', leadTimeDays: 14),
    VendorModel(code: 'VND-003', name: 'PT Logam Presisi Abadi', contact: 'Wahyu - 083434343434', city: 'Bandung', supplyCategory: 'Komponen Presisi', leadTimeDays: 10),
  ];

  // ==================== Actions ====================

  void navigateTo(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  void login(String username) {
    _isLoading = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 800), () {
      _isLoggedIn = true;
      _username = username;
      _currentView = AppView.business;
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectBusiness(BusinessEntity biz) {
    _selectedBusiness = biz;
    _currentView = AppView.costCenter;
    notifyListeners();
  }

  void selectCostCenter(CostCenter cc) {
    _selectedCostCenter = cc;
    _currentView = AppView.gudang;
    notifyListeners();
  }

  void selectWarehouse(WarehouseEntity wh) {
    _selectedWarehouse = wh;
    _currentView = AppView.dashboard;
    notifyListeners();
  }

  void switchModule(String module, {String? customName}) {
    _activeModule = module;
    // Add tab if not present
    final exists = _openTabs.any((t) => t['id'] == module);
    if (!exists) {
      final names = {
        'overview': 'Dashboard', 'sales': 'Penjualan', 'purchasing': 'Pembelian',
        'inventory': 'Inventori', 'accounting': 'Keuangan', 'reports': 'Laporan', 'settings': 'Pengaturan',
      };
      _openTabs.add({'id': module, 'name': customName ?? names[module] ?? module, 'closable': 'true'});
    }
    notifyListeners();
  }

  void openNewForm(String type, {String? customTitle}) {
    final id = '${type}_form_${DateTime.now().millisecondsSinceEpoch}';
    final name = customTitle ?? (type == 'sales' ? 'Faktur Penjualan Baru' : 'Faktur Pembelian Baru');
    switchModule(id, customName: name);
  }

  void closeTab(String moduleId) {
    _openTabs.removeWhere((t) => t['id'] == moduleId);
    if (_activeModule == moduleId) {
      _activeModule = _openTabs.isNotEmpty ? _openTabs.last['id']! : 'overview';
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _selectedBusiness = null;
    _selectedCostCenter = null;
    _selectedWarehouse = null;
    _currentView = AppView.login;
    _activeModule = 'overview';
    _openTabs = [
      {'id': 'overview', 'name': 'Dashboard'},
      {'id': 'sales', 'name': 'Penjualan'},
      {'id': 'purchasing', 'name': 'Pembelian'},
    ];
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  // CRUD Operations
  void addSalesInvoice(SalesInvoice inv) {
    salesInvoices.insert(0, inv);
    notifyListeners();
  }

  void addPurchaseOrder(PurchaseOrder po) {
    purchaseOrders.insert(0, po);
    notifyListeners();
  }

  void addProduct(ProductSku product) {
    products.insert(0, product);
    notifyListeners();
  }

  void deleteProduct(String sku) {
    products.removeWhere((p) => p.sku == sku);
    notifyListeners();
  }

  void addCustomer(CustomerModel c) {
    customers.insert(0, c);
    notifyListeners();
  }

  void deleteCustomer(String code) {
    customers.removeWhere((c) => c.code == code);
    notifyListeners();
  }

  void addVendor(VendorModel v) {
    vendors.insert(0, v);
    notifyListeners();
  }

  void deleteVendor(String code) {
    vendors.removeWhere((v) => v.code == code);
    notifyListeners();
  }
}
