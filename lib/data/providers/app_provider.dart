import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../models/sql_models.dart';
import '../models/master_models.dart';
import '../../core/theme/app_theme.dart';

enum AppView { login, business, costCenter, gudang, dashboard }

class AppProvider extends ChangeNotifier {
  AppView _currentView = AppView.login;
  String _activeModule = 'overview';
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isSidebarOpen = true;

  // Dual Edition State (Pro vs Lite)
  AppEdition _edition = AppEdition.pro;
  UserRole _userRole = UserRole.administrator;

  // Theme state
  bool _isDarkMode = false;
  Color _primaryColor = const Color(0xFF4F46E5);

  // Auth & Database Connection State
  bool _isLoggedIn = false;
  bool _isUsingLiveDatabase = false;
  String _username = 'FARREL';
  String _userDatabase = 'ERP_MALANG_PROD';
  String _ip = '192.168.0.169';
  String _port = '8084';
  String _accessToken = '';
  String _refreshToken = '';
  String? _loginError;

  // Selections
  BusinessEntity? _selectedBusiness;
  CostCenter? _selectedCostCenter;
  WarehouseEntity? _selectedWarehouse;

  // Tab management
  List<Map<String, String>> _openTabs = [
    {'id': 'overview', 'name': 'Dashboard Eksekutif'},
    {'id': 'sales', 'name': 'Penjualan'},
    {'id': 'inventory', 'name': 'Gudang & Stok'},
    {'id': 'manufacturing', 'name': 'Manufaktur & BOM'},
    {'id': 'accounting', 'name': 'Keuangan & Akuntansi'},
  ];

  // Getters
  AppView get currentView => _currentView;
  String get activeModule => _activeModule;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isSidebarOpen => _isSidebarOpen;
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get userDatabase => _userDatabase;
  BusinessEntity? get selectedBusiness => _selectedBusiness;
  CostCenter? get selectedCostCenter => _selectedCostCenter;
  WarehouseEntity? get selectedWarehouse => _selectedWarehouse;
  List<Map<String, String>> get openTabs => _openTabs;
  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  AppEdition get edition => _edition;
  UserRole get userRole => _userRole;
  bool get isUsingLiveDatabase => _isUsingLiveDatabase;
  String get ip => _ip;
  String get port => _port;
  String? get loginError => _loginError;

  void clearLoginError() {
    _loginError = null;
    notifyListeners();
  }

  // Real Database Metadata
  Map<String, dynamic> generalSettings = {};
  List<String> userPermissions = [];
  List<Map<String, dynamic>> roleGroups = [];
  List<Map<String, dynamic>> prefixes = [];

  /// Cari prefix berdasarkan trans_type (= prefix_value), mis. TransType.salesOrder.
  /// Isinya: prefix_id (UUID per business), prefix_code, prefix_name, prefix_value.
  /// Nanti dipakai buat isi `masterprefix_id` + `trans_type` waktu save transaksi.
  Map<String, dynamic>? prefixByType(int transType) {
    for (final p in prefixes) {
      if ((p['prefix_value'] as num?)?.toInt() == transType) return p;
    }
    return null;
  }

  // ==================== Rich Enterprise Data ====================

  List<BusinessEntity> businessEntities = [];
  List<CostCenter> costCenters = [];
  List<WarehouseEntity> warehouses = [];
  List<InventoryItem> inventoryItems = [];
  List<BillOfMaterials> boms = [];
  List<WorkOrderAssembly> workOrders = [];
  List<DisassemblyOrder> disassemblyOrders = [];
  List<Employee> employees = [];
  List<PayrollRecord> payrollRecords = [];
  List<ChartOfAccount> coa = [];
  List<JournalEntry> journalEntries = [];
  List<AccountsReceivable> arAging = [];
  List<AccountsPayable> apAging = [];
  List<StockTransfer> stockTransfers = [];
  List<SalesInvoice> salesInvoices = [];
  List<PurchaseOrder> purchaseOrders = [];

  List<Trans> salesTransList = [];

  // Master data dari server (API v2) dengan default fallback untuk demo/offline
  List<StaffModel> staffs = [];
  List<DueModel> dues = [
    DueModel(id: 'termin-0', code: '0', name: 'Termin 0 hari', days: 0),
    DueModel(id: 'termin-14', code: '14', name: 'Termin 14 hari', days: 14),
    DueModel(id: 'termin-30', code: '30', name: 'Termin 30 hari', days: 30),
    DueModel(id: 'termin-60', code: '60', name: 'Termin 60 hari', days: 60),
  ];
  List<DeskModel> desks = [];
  List<TaxModel> taxes = [
    TaxModel(id: 'aeb5ce17-e1d8-11ef-976d-6c3be5bcbf18', code: 'NON PPN', name: 'NON PPN', rate: 0),
    TaxModel(id: 'aeb5ec94-e1d8-11ef-976d-6c3be5bcbf18', code: 'PPN 11', name: 'PPN 11', rate: 11),
    TaxModel(id: 'e84627c7-a521-11f0-ad51-6c3be5bcbf18', code: 'PPN 12', name: 'PPN 12', rate: 12),
  ];
  List<PaymentMethodModel> paymentMethods = [
    PaymentMethodModel(id: 'ae813d56-e1d8-11ef-976d-6c3be5bcbf18', code: 'KAS', name: 'Kas'),
    PaymentMethodModel(id: 'ae82ac7e-e1d8-11ef-976d-6c3be5bcbf18', code: 'BANK', name: 'Bank'),
    PaymentMethodModel(id: '0e5bc8d1-598d-11f0-ae3e-6c3be5bcbf18', code: 'CC', name: 'BANK KARTU KREDIT', value: 1.25),
  ];
  Map<String, List<ItemUomModel>> itemUomsCache = {};

  // Lite Mode Data
  List<LiteCartItem> liteCart = [];
  List<LiteCashTransaction> liteCashTransactions = [];
  List<LiteDebt> liteDebts = [];

  AppProvider() {
    _loadLocalTransactions();
  }

  // ==================== Mode & Edition Controls ====================

  void toggleEdition() {
    _edition = _edition == AppEdition.pro ? AppEdition.lite : AppEdition.pro;
    notifyListeners();
  }

  void setEdition(AppEdition ed) {
    _edition = ed;
    notifyListeners();
  }

  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  // ==================== Navigation Actions ====================

  void navigateTo(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  void switchModule(String module, {String? customName}) {
    _activeModule = module;
    final exists = _openTabs.any((t) => t['id'] == module);
    if (!exists) {
      final names = {
        'overview': 'Dashboard',
        'sales': 'Penjualan',
        'purchasing': 'Pembelian',
        'inventory': 'Gudang & Stok',
        'manufacturing': 'Manufaktur & BOM',
        'hr': 'SDM & Payroll',
        'accounting': 'Keuangan',
        'reports': 'Laporan',
        'settings': 'Pengaturan',
      };
      _openTabs.add({'id': module, 'name': customName ?? names[module] ?? module, 'closable': 'true'});
    }
    notifyListeners();
  }

  void openNewForm(String type, {String? customTitle, String? targetId}) {
    final suffix = targetId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final id = '${type}_form_$suffix';
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

  void toggleSidebar() {
    _isSidebarOpen = !_isSidebarOpen;
    notifyListeners();
  }

  void setThemeMode(bool isDark) {
    _isDarkMode = isDark;
    AppColors.updateThemeMode(isDark);
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    AppColors.updatePrimaryColor(color);
    notifyListeners();
  }

  // Load UI preferences from server
  Future<void> loadUiSettings() async {
    try {
      final response = await _api().get('/ui-settings');
      if (response.statusCode == 200) {
        final data = response.data['data'] ?? {};
        final dark = data['darkMode'] as bool?;
        final accent = data['accentColor'] as int?;
        if (dark != null) setThemeMode(dark);
        if (accent != null) setPrimaryColor(Color(accent));
      }
    } catch (e) {
      _showError(null, 'Failed to load UI settings: ${_dioMsg(e)}');
    }
  }

  // Save UI preferences to server
  Future<void> saveUiSettings() async {
    try {
      await _api().post('/ui-settings', data: {
        'darkMode': _isDarkMode,
        'accentColor': _primaryColor.value,
      });
    } catch (_) {
      // Silently ignore save errors to avoid disrupting UI
    }
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  // ==================== Manufacturing Actions ====================

  void startWorkOrder(String woId) {
    final index = workOrders.indexWhere((w) => w.id == woId);
    if (index != -1) {
      final wo = workOrders[index];
      wo.status = 'Proses Perakitan';

      // Deduct raw materials based on BOM
      final bom = boms.firstWhere((b) => b.id == wo.bomId, orElse: () => boms.first);
      for (final comp in bom.components) {
        final prodIndex = inventoryItems.indexWhere((p) => p.sku == comp.sku);
        if (prodIndex != -1) {
          final needed = comp.quantity * wo.quantityPlanned;
          final updated = (inventoryItems[prodIndex].stockAvailable - needed).clamp(0, 999999);
          inventoryItems[prodIndex].stockAvailable = updated;
        }
      }
      notifyListeners();
    }
  }

  void completeWorkOrder(String woId) {
    final index = workOrders.indexWhere((w) => w.id == woId);
    if (index != -1) {
      final wo = workOrders[index];
      wo.status = 'Selesai';
      wo.quantityCompleted = wo.quantityPlanned;
      wo.completionDate = DateTime.now();

      // Add finished good stock
      final fgIndex = inventoryItems.indexWhere((p) => p.sku == wo.finishedGoodSku);
      if (fgIndex != -1) {
        inventoryItems[fgIndex].stockAvailable += wo.quantityPlanned;
      }
      notifyListeners();
    }
  }

  void addWorkOrder(WorkOrderAssembly wo) {
    workOrders.insert(0, wo);
    notifyListeners();
  }

  void addBom(BillOfMaterials bom) {
    boms.insert(0, bom);
    // TODO: persist ke server setelah endpoint BOM dikonfirmasi backend (tabel prod/prodline)
    notifyListeners();
  }

  // ==================== HR & Payroll Actions ====================

  void addEmployee(Employee emp) {
    employees.insert(0, emp);
    // TODO: persist ke server setelah endpoint employee dikonfirmasi backend
    notifyListeners();
  }

  void markPayrollPaid(String payrollId) {
    final index = payrollRecords.indexWhere((p) => p.id == payrollId);
    if (index != -1) {
      payrollRecords[index].status = 'Dibayar';
      notifyListeners();
    }
  }

  // ==================== Financial Metrics & Journal ====================

  double get totalRevenue => coa.where((c) => c.category == 'Pendapatan').fold(0.0, (s, c) => s + c.balance);
  double get totalHpp => coa.where((c) => c.category == 'HPP').fold(0.0, (s, c) => s + c.balance);
  double get grossProfit => totalRevenue - totalHpp;
  double get totalOperatingExpenses => coa.where((c) => c.category == 'Beban Operasional').fold(0.0, (s, c) => s + c.balance);
  double get netIncome => grossProfit - totalOperatingExpenses;

  double get totalAssets => coa.where((c) => c.category == 'Aset Lancar' || c.category == 'Aset Tetap').fold(0.0, (s, c) => s + c.balance);
  double get totalLiabilities => coa.where((c) => c.category == 'Kewajiban').fold(0.0, (s, c) => s + c.balance);
  double get totalEquity => coa.where((c) => c.category == 'Ekuitas').fold(0.0, (s, c) => s + c.balance);

  void addJournalEntry(JournalEntry entry) {
    journalEntries.insert(0, entry);
    notifyListeners();
  }

  // ==================== Inventory & Transfer ====================

  void createStockTransfer(StockTransfer transfer) {
    stockTransfers.insert(0, transfer);
    // Deduct from source and add to dest if finished
    final itemIndex = inventoryItems.indexWhere((p) => p.sku == transfer.sku);
    if (itemIndex != -1 && transfer.status == 'Selesai') {
      // Stock adjusted
    }
    notifyListeners();
  }

  // ==================== LITE MODE / POS ACTIONS ====================

  void addToLiteCart(InventoryItem product) {
    final index = liteCart.indexWhere((c) => c.product.sku == product.sku);
    if (index != -1) {
      liteCart[index].quantity += 1;
    } else {
      liteCart.add(LiteCartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromLiteCart(InventoryItem product) {
    final index = liteCart.indexWhere((c) => c.product.sku == product.sku);
    if (index != -1) {
      if (liteCart[index].quantity > 1) {
        liteCart[index].quantity -= 1;
      } else {
        liteCart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void updateLiteCartQuantity(InventoryItem product, int qty) {
    final index = liteCart.indexWhere((c) => c.product.sku == product.sku);
    if (index != -1) {
      if (qty <= 0) {
        liteCart.removeAt(index);
      } else {
        liteCart[index].quantity = qty;
      }
      notifyListeners();
    }
  }

  void clearLiteCart() {
    liteCart.clear();
    notifyListeners();
  }

  double get liteCartSubtotal => liteCart.fold(0.0, (sum, item) => sum + item.subtotal);

  void processLiteCheckout({
    required String customerName,
    required String customerPhone,
    required String paymentMethod,
    required double cashGiven,
  }) {
    if (liteCart.isEmpty) return;

    final total = liteCartSubtotal;
    final orderNo = 'POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // 1. Deduct inventory stock for each purchased item
    for (final item in liteCart) {
      final pIndex = inventoryItems.indexWhere((p) => p.sku == item.product.sku);
      if (pIndex != -1) {
        inventoryItems[pIndex].stockAvailable = (inventoryItems[pIndex].stockAvailable - item.quantity).clamp(0, 999999);
      }
    }

    // 2. Add to sales invoices
    salesInvoices.insert(0, SalesInvoice(
      id: orderNo,
      date: DateTime.now(),
      customer: customerName.isNotEmpty ? customerName : 'Pelanggan Walk-In',
      warehouse: _selectedWarehouse?.name ?? 'Gudang Display Toko',
      amount: total,
      status: paymentMethod == 'Tempo' ? 'Belum Bayar' : 'Lunas',
    ));

    // 3. If Cash, record into cash transaction
    if (paymentMethod == 'Tunai') {
      liteCashTransactions.insert(0, LiteCashTransaction(
        id: 'c-${DateTime.now().millisecondsSinceEpoch}',
        type: 'in',
        category: 'Penjualan POS Tunai',
        amount: total,
        note: 'Nota $orderNo ($customerName)',
        date: DateTime.now(),
      ));
    }

    // 4. If Tempo / Bon, record into lite debts
    if (paymentMethod == 'Tempo') {
      liteDebts.insert(0, LiteDebt(
        id: 'd-${DateTime.now().millisecondsSinceEpoch}',
        orderNo: orderNo,
        customerName: customerName.isNotEmpty ? customerName : 'Pelanggan Bon Toko',
        phone: customerPhone,
        amount: total,
        orderDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 14)),
      ));
    }

    clearLiteCart();
  }

  void addLiteCashTransaction(String type, String category, double amount, String note) {
    liteCashTransactions.insert(0, LiteCashTransaction(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      category: category,
      amount: amount,
      note: note,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  void settleLiteDebt(String debtId) {
    final index = liteDebts.indexWhere((d) => d.id == debtId);
    if (index != -1) {
      final debt = liteDebts[index];
      debt.status = 'Lunas';
      // Record cash received
      liteCashTransactions.insert(0, LiteCashTransaction(
        id: 'c-${DateTime.now().millisecondsSinceEpoch}',
        type: 'in',
        category: 'Pelunasan Bon Pelanggan',
        amount: debt.amount,
        note: 'Pelunasan dari ${debt.customerName}',
        date: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  double get liteCashBalance {
    double total = 0;
    for (var c in liteCashTransactions) {
      if (c.type == 'in') total += c.amount;
      if (c.type == 'out') total -= c.amount;
    }
    return total;
  }

  // ==================== Backend REST API Operations ====================

  Future<void> login({
    required String username,
    required String password,
    required String ip,
    required String port,
    required BuildContext context,
  }) async {
    _loginError = null;
    _isLoading = true;
    notifyListeners();

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ));
      final url = 'http://$ip:$port/api/v2/auth/login';

      final response = await dio.post(
        url,
        data: {
          "client_id": "isoft_flutter",
          "username": username,
          "password": password,
          "device_name": "Postman Windows", // As required by user backend
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final respData = response.data['data'] ?? {};
        _isLoggedIn = true;
        _isUsingLiveDatabase = true;
        _username = respData['user']?['username'] ?? username;
        _ip = ip;
        _port = port;
// Removed local SharedPreferences storage; UI settings are now persisted via server API.
        _accessToken = response.data['access_token'] ?? respData['access_token'] ?? '';
        _refreshToken = response.data['refresh_token'] ?? respData['refresh_token'] ?? '';

        // Print token to console so user can copy it to Postman
        print('\n================ JWT TOKEN (Copy for Postman) ================');
        print('Bearer $_accessToken');
        print('==============================================================\n');

        // Parse Real Data from Login Response
        if (respData['business'] != null) {
          if (respData['business'] is List) {
            businessEntities = (respData['business'] as List).map<BusinessEntity>((b) {
              return BusinessEntity(
                id: b['business_id']?.toString() ?? b['id']?.toString() ?? 'b-1',
                name: b['name']?.toString() ?? 'Unknown Business',
                code: b['code']?.toString() ?? '-',
                description: b['description']?.toString() ?? '',
              );
            }).toList();
          } else if (respData['business'] is Map) {
            final b = respData['business'];
            businessEntities = [
              BusinessEntity(
                id: b['business_id']?.toString() ?? b['id']?.toString() ?? 'b-1',
                name: b['name']?.toString() ?? 'Unknown Business',
                code: b['code']?.toString() ?? '-',
                description: b['description']?.toString() ?? '',
              )
            ];
          }
        } else {
          businessEntities = [];
        }

        if (respData['cost_centers'] != null && respData['cost_centers'] is List) {
          costCenters = (respData['cost_centers'] as List).map<CostCenter>((c) {
            return CostCenter(
              id: c['id']?.toString() ?? '',
              name: c['name']?.toString() ?? '',
              code: c['code']?.toString() ?? '-',
              department: c['department']?.toString() ?? 'Operasional',
              icon: c['icon']?.toString() ?? '🏢',
            );
          }).toList();
        } else {
          costCenters = [];
        }

        if (respData['stores'] != null) {
          if (respData['stores'] is List) {
            warehouses = (respData['stores'] as List).map<WarehouseEntity>((w) {
              return WarehouseEntity(
                id: w['store_id']?.toString() ?? w['id']?.toString() ?? '',
                name: w['store_name']?.toString() ?? w['name']?.toString() ?? 'Store',
                code: w['code']?.toString() ?? '-',
                location: w['location']?.toString() ?? 'Pusat',
                pic: w['pic']?.toString() ?? '-',
                capacity: int.tryParse(w['capacity']?.toString() ?? '1000') ?? 1000,
                utilization: int.tryParse(w['utilization']?.toString() ?? '0') ?? 0,
              );
            }).toList();
          } else if (respData['stores'] is Map) {
            final w = respData['stores'];
            warehouses = [
              WarehouseEntity(
                id: w['store_id']?.toString() ?? w['id']?.toString() ?? '',
                name: w['store_name']?.toString() ?? w['name']?.toString() ?? 'Store',
                code: w['code']?.toString() ?? '-',
                location: w['location']?.toString() ?? 'Pusat',
                pic: w['pic']?.toString() ?? '-',
                capacity: int.tryParse(w['capacity']?.toString() ?? '1000') ?? 1000,
                utilization: int.tryParse(w['utilization']?.toString() ?? '0') ?? 0,
              )
            ];
          }
        } else {
          warehouses = [];
        }

        _selectedBusiness = null;
        _selectedCostCenter = null;
        _selectedWarehouse = null;

        if (businessEntities.isNotEmpty) {
          _currentView = AppView.business;
        } else if (warehouses.isNotEmpty) {
          _currentView = AppView.gudang;
        } else {
          _currentView = AppView.dashboard;
        }

      } else {
        _loginError = 'Login gagal: Periksa kembali username & password.';
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_loginError!),
            backgroundColor: const Color(0xFFC53030),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            showCloseIcon: true,
            closeIconColor: Colors.white,
            action: SnackBarAction(
              label: 'Tutup',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ));
        }
      }
    } catch (e) {
      _loginError = 'Gagal koneksi ke server http://$ip:$port. Pastikan database aktif atau gunakan Mode Demo.';
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_loginError!),
          backgroundColor: const Color(0xFFC53030),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          showCloseIcon: true,
          closeIconColor: Colors.white,
          action: SnackBarAction(
            label: 'Tutup',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loginAsDemo() {
    _loginError = null;
    _isLoggedIn = true;
    _isUsingLiveDatabase = false;
    _username = 'FARREL (Demo)';
    
    businessEntities = [
      BusinessEntity(id: 'biz-1', name: 'PT. NEXUS DEMO', code: 'NEX', description: 'Retail & Distribusi', category: 'Retail'),
      BusinessEntity(id: 'biz-2', name: 'CV. MAJU MUNDUR', code: 'MMD', description: 'Manufaktur', category: 'Manufaktur'),
    ];
    
    costCenters = [
      CostCenter(id: 'cc-1', name: 'Produksi Utama', code: 'PRD-01', department: 'Produksi', icon: '🏭'),
      CostCenter(id: 'cc-2', name: 'Operasional Cabang', code: 'OPR-JKT', department: 'Operasional', icon: '🏪'),
    ];
    
    warehouses = [
      WarehouseEntity(id: 'wh-1', name: 'Gudang Pusat Jakarta', code: 'GD-JKT', location: 'Jakarta', pic: 'Budi', capacity: 5000, utilization: 3200),
      WarehouseEntity(id: 'wh-2', name: 'Gudang Transit SBY', code: 'GD-SBY', location: 'Surabaya', pic: 'Andi', capacity: 2000, utilization: 800),
    ];
    
    products = [
      ProductSku(sku: 'SKU-001', name: 'Kopi Arabica Premium', category: 'Minuman', unit: 'Pcs', salePrice: 45000, stock: 120),
      ProductSku(sku: 'SKU-002', name: 'Susu UHT 1L', category: 'Minuman', unit: 'Pcs', salePrice: 18000, stock: 340),
      ProductSku(sku: 'SKU-003', name: 'Beras Pandan Wangi 5kg', category: 'Sembako', unit: 'Sak', salePrice: 65000, stock: 50),
    ];
    
    customers = [
      CustomerModel(code: 'CUST-001', companyName: 'PT. Untung Terus', contact: '0812345678', city: 'Jakarta', type: 'B2B', creditLimit: 50000000),
      CustomerModel(code: 'CUST-002', companyName: 'Toko Makmur', contact: '0899887766', city: 'Surabaya', type: 'B2C', creditLimit: 10000000),
    ];

    inventoryItems = [
      InventoryItem(sku: 'SKU-001', name: 'Plat Besi 2mm', category: 'Raw Material', stockAvailable: 1500, unit: 'Lembar', warehouse: 'GD-JKT', stockMin: 500, unitPrice: 150000),
      InventoryItem(sku: 'SKU-002', name: 'Baut M8', category: 'Komponen', stockAvailable: 12000, unit: 'Pcs', warehouse: 'GD-JKT', stockMin: 2000, unitPrice: 500),
    ];

    boms = [
      BillOfMaterials(id: 'bom-1', bomCode: 'BOM-RKA-01', finishedGoodSku: 'FG-001', finishedGoodName: 'Rakitan Meja Besi', components: [], outputUnit: 'Unit', outputQty: 1, directLaborCost: 50000, overheadCost: 10000),
    ];

    employees = [
      Employee(id: 'emp-1', nip: '1001', name: 'Andi Saputra', position: 'Operator', department: 'Produksi', status: 'Tetap', joinDate: DateTime(2020, 1, 15), baseSalary: 4500000, allowance: 500000, email: 'andi@demo.com', phone: '08123', bankAccount: '1234'),
    ];

    coa = [
      ChartOfAccount(code: '1-1000', name: 'Kas & Bank', category: 'Aset Lancar', normalBalance: 'Debit', balance: 250000000),
      ChartOfAccount(code: '4-1000', name: 'Pendapatan Penjualan', category: 'Pendapatan', normalBalance: 'Kredit', balance: 50000000),
    ];

    _selectedBusiness = null;
    _selectedCostCenter = null;
    _selectedWarehouse = null;
    _currentView = AppView.business;
    notifyListeners();
  }

  // ==================== Business Flow (v2 API) ====================

  String get _baseUrl => 'http://$_ip:$_port/api/v2';

  Dio _api() => Dio(BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          if (_accessToken.isNotEmpty) 'Authorization': 'Bearer $_accessToken',
        },
      ));

  void _showError(BuildContext? context, String msg) {
    debugPrint('[AppProvider] $msg');
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  String _dioMsg(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      return data?.toString() ?? e.message ?? e.type.name;
    }
    return e.toString();
  }

  /// Port riwayat yang berhasil dideteksi otomatis saat runtime
  String? _detectedHistoryPort;

  /// Ambil nomor urut nota terakhir dari database untuk prefix tertentu.
  /// Fungsi ini secara dinamis MENDETEKSI port yang aktif pada IP target (`_ip`),
  /// mencoba port login user (`_port`) terlebih dahulu, lalu port pendamping (8084 / 8087).
  Future<int?> fetchLastNotaSequence({required int transType, required String prefix}) async {
    final businessId = _selectedBusiness?.id;
    if (businessId == null || businessId.isEmpty) return null;

    final now = DateTime.now();
    final yy = (now.year % 100).toString().padLeft(2, '0');
    final startMs = DateTime(now.year).millisecondsSinceEpoch;
    final endMs = DateTime(now.year + 1).millisecondsSinceEpoch - 1;

    // Daftar kandidat port untuk dideteksi otomatis:
    final candidatePorts = <String>{
      if (_detectedHistoryPort != null) _detectedHistoryPort!,
      if (_port.isNotEmpty) _port,
      '8084',
      '8087',
    }.toList();

    for (final port in candidatePorts) {
      try {
        final res = await Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 8),
          headers: {'Content-Type': 'application/json'},
          // 404 dari gettransbydate = server aktif tapi data trans masih kosong
          validateStatus: (s) => s != null && (s == 200 || s == 404),
        )).post('http://$_ip:$port/api/v1/gettransbydate', data: {
          'masterbussiness_id': businessId,
          'trans_type': transType,
          'tgl_awal': startMs,
          'tgl_akhir': endMs,
          'masteruser_id': null,
        });

        if (res.statusCode == 404) {
          _detectedHistoryPort = port;
          return 0;
        }

        if (res.statusCode == 200) {
          _detectedHistoryPort = port;
          final data = res.data is Map ? res.data['data'] : null;
          if (data is! List) return 0;

          final regex = RegExp('^$prefix-$yy-(\\d+)\$', caseSensitive: false);
          int maxSeq = 0;
          for (final row in data) {
            if (row is! Map) continue;
            for (final key in const ['trans_text', 'trans_nomornota']) {
              final m = regex.firstMatch((row[key] ?? '').toString().trim());
              if (m != null) {
                final seq = int.tryParse(m.group(1)!) ?? 0;
                if (seq > maxSeq) maxSeq = seq;
              }
            }
          }
          return maxSeq;
        }
      } catch (e) {
        // Coba port kandidat berikutnya
        continue;
      }
    }

    debugPrint('fetchLastNotaSequence($prefix) gagal pada semua kandidat port di IP $_ip');
    return null;
  }

  /// Step 1: pilih business -> POST /auth/switch-business -> GET /business-context
  Future<void> selectBusiness(BusinessEntity biz, {BuildContext? context}) async {
    if (_isLoading) return;
    _selectedBusiness = biz;
    _selectedCostCenter = null;
    _selectedWarehouse = null;
    _isLoading = true;
    notifyListeners();

    if (!_isUsingLiveDatabase) {
      await Future.delayed(const Duration(milliseconds: 200));
      _isLoading = false;
      _currentView = costCenters.isNotEmpty
          ? AppView.costCenter
          : (warehouses.isNotEmpty ? AppView.gudang : AppView.dashboard);
      notifyListeners();
      return;
    }

    try {
      // 1. Switch business (token baru ter-scope ke business)
      final switchRes = await _api().post('/auth/switch-business', data: {
        'business_id': biz.id,
        'refresh_token': _refreshToken,
      });
      if (switchRes.data['success'] != true) {
        _showError(context, 'Gagal pindah bisnis: ${switchRes.data['message'] ?? switchRes.data}');
        return;
      }
      final sw = switchRes.data['data'] ?? {};
      _accessToken = sw['access_token']?.toString() ?? _accessToken;
      _refreshToken = sw['refresh_token']?.toString() ?? _refreshToken;
      final swBiz = sw['business'];
      if (swBiz is Map && swBiz['permissions'] is List) {
        userPermissions = (swBiz['permissions'] as List).map((p) => p.toString()).toList();
      }

      // 2. Business context: stores, general_settings, role_groups, prefixes
      final ok = await fetchBusinessContext(context: context);
      if (!ok) return;

      if (costCenters.isEmpty) {
        _showError(context, 'Business ini belum punya store / cost center.');
        return;
      }
      _currentView = AppView.costCenter;
    } catch (e) {
      _showError(context, 'Error pindah bisnis: ${_dioMsg(e)}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// GET /business-context. Store -> costCenters.
  Future<bool> fetchBusinessContext({BuildContext? context}) async {
    try {
      final res = await _api().get('/business-context');
      if (res.data['success'] != true) {
        _showError(context, 'Gagal ambil business context: ${res.data['message'] ?? res.data}');
        return false;
      }
      final data = res.data['data'] ?? {};

      final stores = data['stores'];
      costCenters = stores is List
          ? stores.map<CostCenter>((s) => CostCenter(
                id: s['store_id']?.toString() ?? '',
                name: s['store_name']?.toString() ?? 'Store',
                code: s['store_code']?.toString() ?? '-',
                department: 'Store',
                icon: '🏪',
              )).toList()
          : [];

      generalSettings = data['general_settings'] is Map
          ? Map<String, dynamic>.from(data['general_settings'])
          : {};
      roleGroups = data['role_groups'] is List
          ? List<Map<String, dynamic>>.from(
              (data['role_groups'] as List).map((e) => Map<String, dynamic>.from(e)))
          : [];
      prefixes = data['prefixes'] is List
          ? List<Map<String, dynamic>>.from(
              (data['prefixes'] as List).map((e) => Map<String, dynamic>.from(e)))
          : [];

      warehouses = [];
      return true;
    } catch (e) {
      _showError(context, 'Error business context: ${_dioMsg(e)}');
      return false;
    }
  }

  /// Step 2: pilih store (cost center) -> GET /warehouses?store_id=
  Future<void> selectCostCenter(CostCenter cc, {BuildContext? context}) async {
    if (_isLoading) return;
    _selectedCostCenter = cc;
    _selectedWarehouse = null;
    _isLoading = true;
    notifyListeners();

    if (!_isUsingLiveDatabase) {
      _isLoading = false;
      _currentView = warehouses.isNotEmpty ? AppView.gudang : AppView.dashboard;
      notifyListeners();
      return;
    }

    try {
      final ok = await fetchWarehouses(cc.id, context: context);
      if (!ok) return;
      if (warehouses.isEmpty) {
        _showError(context, 'Store ini belum punya gudang.');
        return;
      }
      
      // Fetch customers and vendors globally so they are ready for forms
      await fetchPartners(TransType.salesOrder);    // customer
      await fetchPartners(TransType.purchaseOrder); // supplier
      await Future.wait([
        fetchEmployees(),       // GET /staffs/trans
        fetchDues(),            // GET /dues/trans
        fetchDesks(),           // GET /desks/trans
        fetchTaxes(),           // GET /taxes/trans
        fetchPaymentMethods(),  // GET /trans/payment/method
      ]);

      // NOTE: fetchSalesTransactions()/fetchPurchaseTransactions() sengaja tidak
      // dipanggil: GET /trans balas 404 di server asli. Aktifkan lagi setelah
      // backend kasih endpoint riwayat transaksi yang benar.
      
      _currentView = AppView.gudang;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchWarehouses(String storeId, {BuildContext? context}) async {
    try {
      final res = await _api().get('/warehouses', queryParameters: {'store_id': storeId});
      if (res.data['success'] != true) {
        _showError(context, 'Gagal ambil gudang: ${res.data['message'] ?? res.data}');
        return false;
      }
      final list = res.data['data'];
      warehouses = list is List
          ? list.map<WarehouseEntity>((w) => WarehouseEntity(
                id: w['warehouse_id']?.toString() ?? '',
                name: w['warehouse_name']?.toString() ?? 'Gudang',
                code: w['warehouse_code']?.toString() ?? '-',
                location: _selectedCostCenter?.name ?? '-',
                pic: '-',
                capacity: 0,
                utilization: 0,
              )).toList()
          : [];
      return true;
    } catch (e) {
      _showError(context, 'Error ambil gudang: ${_dioMsg(e)}');
      return false;
    }
  }

  void selectWarehouse(WarehouseEntity wh) {
    _selectedWarehouse = wh;
    _currentView = AppView.dashboard;
    _loadLocalTransactions();
    notifyListeners();
    
    // Otomatis tarik data barang untuk gudang yang dipilih
    if (_isUsingLiveDatabase) {
      fetchItemsForWarehouse();
    }
  }

  Future<void> fetchItemsForWarehouse() async {
    if (_selectedWarehouse == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api().get('/items/trans', queryParameters: {
        'warehouse_id': _selectedWarehouse!.id,
      });
      if (res.data['success'] == true) {
        final list = res.data['data'];
        if (list is List) {
          inventoryItems = list.map<InventoryItem>((i) => InventoryItem(
            id: i['item_id']?.toString() ?? '',
            itemUomId: i['base_item_uom_id']?.toString() ?? i['item_uom_id']?.toString() ?? i['masteritemuom_id']?.toString() ?? i['itemuom_id']?.toString(),
            taxId: i['tax_id']?.toString(),
            sku: i['item_code']?.toString() ?? '-',
            name: i['item_name']?.toString() ?? '-',
            category: i['category_name']?.toString() ?? 'Umum',
            stockAvailable: int.tryParse(i['stock_quantity']?.toString() ?? '0') ?? 0,
            stockMin: int.tryParse(i['min_sale_quantity']?.toString() ?? '0') ?? 0,
            unitPrice: 0.0, // diisi oleh fetchPricesForItems()
            costPrice: 0.0,
            unit: i['base_uom_name']?.toString() ?? 'PCS',
            warehouse: _selectedWarehouse!.name,
          )).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetchItems: ${_dioMsg(e)}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Barang sudah tampil, sekarang isi harganya di belakang layar
    await fetchPricesForItems();
  }

  /// Kategori customer default untuk menampilkan harga jual di daftar barang.
  /// (Diambil dari contoh request Postman. Ganti kalau perlu kategori lain.)
  static const String defaultPartnerCategoryId = 'aeb60bb1-e1d8-11ef-976d-6c3be5bcbf18';

  /// GET /prices?item_id=&partnercategory_id=&store_id=&qty=1 untuk tiap barang.
  Future<void> fetchPricesForItems({String partnerCategoryId = defaultPartnerCategoryId}) async {
    final storeId = _selectedCostCenter?.id;
    if (storeId == null || storeId.isEmpty) return;

    final items = inventoryItems.where((it) => it.id.isNotEmpty).toList();
    const batchSize = 5; // biar server nggak dibanjiri request sekaligus

    for (var start = 0; start < items.length; start += batchSize) {
      final batch = items.skip(start).take(batchSize);
      await Future.wait(batch.map((item) async {
        try {
          final res = await _api().get('/prices', queryParameters: {
            'item_id': item.id,
            'partnercategory_id': partnerCategoryId,
            'store_id': storeId,
            'qty': 1,
          });
          final data = res.data['data'];
          if (res.data['success'] == true && data is List && data.isNotEmpty) {
            item.unitPrice = (data.first['unit_price'] as num?)?.toDouble() ?? 0.0;
          }
        } catch (e) {
          debugPrint('Error harga ${item.sku}: ${_dioMsg(e)}');
        }
      }));
      notifyListeners(); // update tabel per batch
    }
  }

  Future<void> fetchPartners(int prefixValue) async {
    // Contoh template fungsi untuk ngambil list supplier/customer (pakai prefix_value)
    // prefixValue = trans_type: TransType.salesOrder (14) = Customer, TransType.purchaseOrder (2) = Supplier
    try {
      final res = await _api().get('/partners/trans', queryParameters: {
        'prefix_value': prefixValue,
      });
      if (res.data['success'] == true) {
        final list = res.data['data'];
        if (list is List) {
          if (prefixValue == TransType.salesOrder) {
            customers = list.map<CustomerModel>((c) => CustomerModel(
              id: c['partner_id']?.toString() ?? c['id']?.toString() ?? '',
              code: c['partner_code']?.toString() ?? '',
              companyName: c['partner_name']?.toString() ?? '',
              contact: '-',
              city: '-',
              type: c['partnercategory_code']?.toString() ?? 'UMUM',
              creditLimit: 0,
            )).toList();
          } else if (prefixValue == TransType.purchaseOrder) {
            vendors = list.map<VendorModel>((v) => VendorModel(
              id: v['partner_id']?.toString() ?? v['id']?.toString() ?? '',
              code: v['partner_code']?.toString() ?? '',
              name: v['partner_name']?.toString() ?? '',
              contact: '-',
              city: '-',
              supplyCategory: v['partnercategory_code']?.toString() ?? 'UMUM',
              leadTimeDays: (v['due_value'] as num?)?.toInt() ?? 0,
            )).toList();
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetchPartners: ${_dioMsg(e)}');
    }
  }

  /// GET /staffs/trans -> staff/sales. Disimpan ke [staffs] dan juga dipetakan
  /// ke [employees] supaya halaman SDM yang sudah ada tetap terisi.
  /// (Endpoint lama '/employees' tidak ada di server, balas 404.)
  Future<void> fetchEmployees() async {
    try {
      final res = await _api().get('/staffs/trans');
      if (res.data['success'] == true) {
        final list = res.data['data'];
        if (list is List) {
          staffs = list.map((e) => StaffModel.fromJson(Map<String, dynamic>.from(e))).toList();
          employees = staffs.map<Employee>((s) => Employee(
            id: s.id,
            nip: s.code,
            name: s.name,
            position: s.categoryName.isNotEmpty ? s.categoryName : s.categoryCode,
            department: s.categoryCode.isNotEmpty ? s.categoryCode : '-',
            status: 'Aktif',
            joinDate: DateTime.now(), // server belum kirim tanggal masuk
            baseSalary: 0,
            allowance: 0,
            email: '-',
            phone: '-',
            bankAccount: '-',
          )).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetchEmployees (/staffs/trans): ${_dioMsg(e)}');
    }
  }

  /// GET /termin/trans (api/v2/termin/trans) atau fallback ke /dues/trans -> termin pembayaran (contoh: Termin 30 hari).
  Future<void> fetchDues() async {
    try {
      Response? res;
      try {
        res = await _api().get('/termin/trans');
      } catch (e) {
        try {
          res = await _api().get('/dues/trans');
        } catch (_) {}
      }
      if (res != null && res.data != null) {
        final list = res.data['data'];
        if (res.data['success'] == true && list is List && list.isNotEmpty) {
          dues = list.map((e) => DueModel.fromJson(Map<String, dynamic>.from(e))).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('[AppProvider] fetchDues: ${_dioMsg(e)} (menggunakan data default fallback)');
    }
  }

  /// GET /desks/trans -> daftar meja.
  Future<void> fetchDesks() async {
    try {
      final res = await _api().get('/desks/trans');
      final list = res.data['data'];
      if (res.data['success'] == true && list is List) {
        desks = list.map((e) => DeskModel.fromJson(Map<String, dynamic>.from(e))).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetchDesks: ${_dioMsg(e)}');
    }
  }

  /// GET /supports?entity_id=&type= -> data pendukung sebuah entity.
  /// Arti `type` belum dikonfirmasi backend (contoh Postman pakai type=2),
  /// jadi dikembalikan mentah dan tidak dipanggil otomatis.
  Future<List<Map<String, dynamic>>> fetchSupports(String entityId, {int type = 2}) async {
    try {
      final res = await _api().get('/supports', queryParameters: {
        'entity_id': entityId,
        'type': type,
      });
      final list = res.data['data'];
      if (res.data['success'] == true && list is List) {
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetchSupports: ${_dioMsg(e)}');
    }
    return [];
  }

  /// 1. GET /uoms/item?item_id=...
  /// Mengambil daftar konversi satuan untuk item tertentu (misal: PCS, LSN, GROSS).
  Future<List<ItemUomModel>> fetchItemUoms(String itemId) async {
    if (itemId.isEmpty) return [];
    if (itemUomsCache.containsKey(itemId)) {
      return itemUomsCache[itemId]!;
    }
    try {
      final res = await _api().get('/uoms/item', queryParameters: {'item_id': itemId});
      final list = res.data['data'];
      if (res.data['success'] == true && list is List) {
        final uoms = list.map((e) => ItemUomModel.fromJson(Map<String, dynamic>.from(e))).toList();
        itemUomsCache[itemId] = uoms;
        notifyListeners();
        return uoms;
      }
    } catch (e) {
      debugPrint('Error fetchItemUoms ($itemId): ${_dioMsg(e)}');
    }
    return [];
  }

  /// 2. GET /taxes/trans
  /// Mengambil data jenis pajak untuk transaksi.
  Future<void> fetchTaxes() async {
    try {
      final res = await _api().get('/taxes/trans');
      final list = res.data['data'];
      if (res.data['success'] == true && list is List && list.isNotEmpty) {
        taxes = list.map((e) => TaxModel.fromJson(Map<String, dynamic>.from(e))).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AppProvider] fetchTaxes: ${_dioMsg(e)} (menggunakan data default fallback)');
    }
  }

  /// 3. GET /trans/payment/method
  /// Mengambil daftar metode pembayaran transaksi (berlaku untuk SO, SI, PO, PI).
  Future<void> fetchPaymentMethods() async {
    try {
      final res = await _api().get('/trans/payment/method');
      final list = res.data['data'];
      if (res.data['success'] == true && list is List && list.isNotEmpty) {
        paymentMethods = list.map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e))).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AppProvider] fetchPaymentMethods: ${_dioMsg(e)} (menggunakan data default fallback)');
    }
  }

  /// 4. POST /trans
  /// Simpan / insert transaksi baru ke database menggunakan format payload resmi API v2.
  Future<bool> createTransaction(TransactionCreateRequest req, {BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api().post('/trans', data: req.toJson());
      if (res.data['success'] == true) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Transaksi berhasil disimpan ke server!'),
            backgroundColor: Color(0xFF28A745),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return true;
      } else {
        _showError(context, 'Gagal simpan transaksi: ${res.data['message'] ?? res.data}');
        return false;
      }
    } catch (e) {
      _showError(context, 'Error simpan transaksi: ${_dioMsg(e)}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSalesTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api().get('/trans', queryParameters: {
        // 'trans_type': 3, // specify trans_type here if needed for sales
      });
      if (res.data['success'] == true) {
        final list = res.data['data'];
        if (list is List) {
          final transList = list.map((e) => Trans.fromJson(e)).toList();
          salesInvoices = transList.map((t) => SalesInvoice(
            id: t.transNomornota ?? t.transId ?? '-',
            date: t.transEntrydate != null ? DateTime.fromMillisecondsSinceEpoch(t.transEntrydate! * 1000) : DateTime.now(),
            customer: t.masterpartnerId ?? t.transText ?? 'Pelanggan Umum',
            warehouse: t.masterwarehouseId ?? 'Gudang Utama',
            amount: t.transNilaikurs ?? 0.0, 
            status: t.transType == 1 ? 'Lunas' : 'Belum Bayar', 
          )).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetchSalesTransactions: ${_dioMsg(e)}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatIsoWithOffset(DateTime dt) {
    final offset = dt.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$y-$m-${d}T$h:$min:$sec$sign$hours:$minutes';
  }

  Future<String> _resolveLineUomId(Transline l) async {
    final text = l.translineKeterangan?.trim() ?? '';

    // 1. Cari produk yang cocok di inventoryItems
    InventoryItem? prod = inventoryItems.where((p) {
      if (l.masteritemuomId != null && l.masteritemuomId!.isNotEmpty) {
        if (p.id == l.masteritemuomId || p.itemUomId == l.masteritemuomId) return true;
      }
      if (text.isNotEmpty) {
        final pName = p.name.trim().toLowerCase();
        final pSku = p.sku.trim().toLowerCase();
        final tLower = text.toLowerCase();
        if (pName == tLower || pSku == tLower) return true;
        if (pName.contains(tLower) || tLower.contains(pName)) return true;
      }
      return false;
    }).firstOrNull;

    String uomId = '';
    final desiredUnit = l.translineKeterangan02?.trim().toUpperCase() ?? '';

    // A. Jika prod ditemukan, ambil daftar UOM-nya untuk dicocokkan dengan satuan pilihan user (PCS, LSN, GROSS, dll)
    if (prod != null && prod.id.isNotEmpty) {
      List<ItemUomModel> uoms = itemUomsCache[prod.id] ?? [];
      if (uoms.isEmpty) {
        uoms = await fetchItemUoms(prod.id);
      }
      if (uoms.isNotEmpty) {
        if (desiredUnit.isNotEmpty) {
          final matchedUom = uoms.where((u) =>
            (u.uomCode != null && u.uomCode!.toUpperCase() == desiredUnit) ||
            u.uomName.toUpperCase() == desiredUnit
          ).firstOrNull;
          if (matchedUom != null) {
            uomId = matchedUom.id;
          }
        }
        if (uomId.isEmpty && prod.itemUomId != null && prod.itemUomId!.isNotEmpty && prod.itemUomId != prod.id) {
          uomId = prod.itemUomId!;
        }
        if (uomId.isEmpty) {
          uomId = uoms.first.id;
        }
      }
    }

    // B. Jika prod ditemukan tanpa uom list, coba langsung prod.itemUomId
    if (uomId.isEmpty && prod?.itemUomId != null && prod!.itemUomId!.isNotEmpty && prod.itemUomId != prod.id) {
      uomId = prod.itemUomId!;
    }

    // D. Jika prod tidak ditemukan atau uomId masih kosong, periksa l.masteritemuomId
    if (uomId.isEmpty && l.masteritemuomId != null && l.masteritemuomId!.isNotEmpty) {
      final candidateId = l.masteritemuomId!;
      // Cek apakah candidateId sebenarnya adalah item_id
      final itemWithId = inventoryItems.where((p) => p.id == candidateId).firstOrNull;
      if (itemWithId != null) {
        if (itemWithId.itemUomId != null && itemWithId.itemUomId!.isNotEmpty && itemWithId.itemUomId != candidateId) {
          uomId = itemWithId.itemUomId!;
        } else {
          final uoms = await fetchItemUoms(itemWithId.id);
          if (uoms.isNotEmpty) uomId = uoms.first.id;
        }
      } else {
        // Coba fetchItemUoms siapa tahu candidateId adalah item_id
        final uoms = await fetchItemUoms(candidateId);
        if (uoms.isNotEmpty) {
          uomId = uoms.first.id;
        } else {
          // Asumsikan memang item_uom_id
          uomId = candidateId;
        }
      }
    }

    // E. Fallback darurat: jika uomId masih kosong, ambil item_uom_id dari barang pertama yang ada di gudang
    if (uomId.isEmpty && inventoryItems.isNotEmpty) {
      final firstItem = inventoryItems.first;
      if (firstItem.itemUomId != null && firstItem.itemUomId!.isNotEmpty && firstItem.itemUomId != firstItem.id) {
        uomId = firstItem.itemUomId!;
      } else {
        final uoms = await fetchItemUoms(firstItem.id);
        if (uoms.isNotEmpty) uomId = uoms.first.id;
      }
    }

    debugPrint('[ResolveUom] Line "${l.translineKeterangan}" -> resolved item_uom_id: $uomId');
    return uomId;
  }

  String _resolveLineTaxId(Transline l) {
    if (l.mastertaxId != null && l.mastertaxId!.isNotEmpty) {
      return l.mastertaxId!;
    }
    final text = l.translineKeterangan?.trim() ?? '';
    final prod = inventoryItems.where((p) {
      if (l.masteritemuomId != null && l.masteritemuomId!.isNotEmpty) {
        if (p.id == l.masteritemuomId || p.itemUomId == l.masteritemuomId) return true;
      }
      if (text.isNotEmpty) {
        final pName = p.name.trim().toLowerCase();
        final pSku = p.sku.trim().toLowerCase();
        final tLower = text.toLowerCase();
        if (pName == tLower || pSku == tLower) return true;
        if (pName.contains(tLower) || tLower.contains(pName)) return true;
      }
      return false;
    }).firstOrNull;

    if (prod?.taxId != null && prod!.taxId!.isNotEmpty) {
      return prod.taxId!;
    }
    if (taxes.isNotEmpty) {
      return taxes.first.id;
    }
    return 'aeb5ce17-e1d8-11ef-976d-6c3be5bcbf18';
  }

  Future<({bool success, String message, String? transNumber, String? transId})> saveSalesTransaction(
    Trans trans, {
    List<Transline>? lines,
    List<Map<String, dynamic>>? payments,
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (inventoryItems.isEmpty) {
        await fetchItemsForWarehouse();
      }
      if (taxes.isEmpty) {
        await fetchTaxes();
      }
      if (customers.isEmpty) {
        await fetchPartners(TransType.salesOrder);
      }
      if (costCenters.isEmpty) {
        await fetchBusinessContext();
      }

      // Cari partner UUID dari daftar customer
      final cust = customers.where((c) => c.companyName == trans.transText || c.code == trans.transText || c.id == trans.masterpartnerId).firstOrNull;
      final partnerId = cust?.id.isNotEmpty == true
          ? cust!.id
          : ((trans.masterpartnerId?.isNotEmpty == true) ? trans.masterpartnerId! : (customers.isNotEmpty ? customers.first.id : ''));

      // Cari warehouse UUID
      final wh = warehouses.where((w) => w.name == trans.masterwarehouseId || w.id == trans.masterwarehouseId).firstOrNull;
      final warehouseId = wh?.id.isNotEmpty == true
          ? wh!.id
          : (_selectedWarehouse?.id ?? (warehouses.isNotEmpty ? warehouses.first.id : ''));
      final storeId = _selectedCostCenter?.id ?? (costCenters.isNotEmpty ? costCenters.first.id : '');

      DateTime entryDt = DateTime.now();
      if (trans.transEntrydate != null && trans.transEntrydate! > 0) {
        final ms = trans.transEntrydate! > 100000000000
            ? trans.transEntrydate!
            : trans.transEntrydate! * 1000;
        entryDt = DateTime.fromMillisecondsSinceEpoch(ms);
      }
      final entryDateIso = _formatIsoWithOffset(entryDt);

      final reqItems = <TransactionItemLine>[];
      if (lines != null) {
        for (int i = 0; i < lines.length; i++) {
          final l = lines[i];
          final uomId = await _resolveLineUomId(l);
          final lineTaxId = _resolveLineTaxId(l);

          reqItems.add(TransactionItemLine(
            itemUomId: uomId,
            taxId: lineTaxId,
            sequenceNumber: i + 1,
            quantity: l.translineQty ?? 1,
            unitPrice: l.translinePrice ?? 0,
            discountValue: l.translineTotaldiscvalue ?? 0,
          ));
        }
      }

      final sanitizedPayments = <Map<String, dynamic>>[];
      if (payments != null && payments.isNotEmpty) {
        if (paymentMethods.isEmpty) {
          await fetchPaymentMethods();
        }
        final uuidReg = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
        for (final p in payments) {
          final m = Map<String, dynamic>.from(p);
          String accId = m['account_id']?.toString() ?? '';
          if (!uuidReg.hasMatch(accId)) {
            accId = paymentMethods.isNotEmpty ? paymentMethods.first.id : 'ae813d56-e1d8-11ef-976d-6c3be5bcbf18';
            m['account_id'] = accId;
          }
          sanitizedPayments.add(m);
        }
      }

      final req = TransactionCreateRequest(
        header: TransactionHeader(
          transactionType: TransType.salesInvoice.toString(), // "16"
          partnerId: partnerId,
          warehouseId: warehouseId,
          storeId: storeId,
          exchangeRate: 1,
          entryDate: entryDateIso,
          notes: trans.transText ?? 'Penjualan',
          taxIncluded: 'Y',
          terminId: trans.masterterminId,
        ),
        items: reqItems,
        payments: sanitizedPayments,
      );

      debugPrint('[SaveSales] Payload POST /trans: ${jsonEncode(req.toJson())}');
      final res = await _api().post('/trans', data: req.toJson());
      if (res.data['success'] == true) {
        final d = res.data['data'] as Map<String, dynamic>?;
        final transNumber = d?['trans_number']?.toString();
        final transId = d?['trans_id']?.toString();
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Transaksi Penjualan berhasil disimpan ke server! (${transNumber ?? ''})'),
            backgroundColor: const Color(0xFF28A745),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return (success: true, message: 'Transaksi berhasil disimpan ke server!', transNumber: transNumber, transId: transId);
      } else {
        final errMsg = res.data['error']?['message'] ?? res.data['message'] ?? 'Gagal menyimpan transaksi ke server';
        return (success: false, message: errMsg.toString(), transNumber: null, transId: null);
      }
    } catch (e) {
      final msg = _dioMsg(e);
      debugPrint('Sync sales transaction to server error: $msg');
      return (success: false, message: msg, transNumber: null, transId: null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPurchaseTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api().get('/trans', queryParameters: {
         'trans_type': TransType.purchaseOrder,
      });
      if (res.data['success'] == true) {
        final list = res.data['data'];
        if (list is List) {
          final transList = list.map((e) => Trans.fromJson(e)).toList();
          purchaseOrders = transList.map((t) => PurchaseOrder(
            id: t.transNomornota ?? t.transId ?? '-',
            date: t.transEntrydate != null ? DateTime.fromMillisecondsSinceEpoch(t.transEntrydate! * 1000) : DateTime.now(),
            vendor: t.masterpartnerId ?? t.transText ?? 'Supplier Umum',
            warehouse: t.masterwarehouseId ?? 'Gudang Utama',
            amount: t.transNilaikurs ?? 0.0, 
            status: t.transType == 1 ? 'Lunas' : 'Belum Bayar', 
          )).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetchPurchaseTransactions: ${_dioMsg(e)}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<({bool success, String message, String? transNumber, String? transId})> savePurchaseTransaction(
    Trans trans, {
    List<Transline>? lines,
    List<Map<String, dynamic>>? payments,
    BuildContext? context,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (inventoryItems.isEmpty) {
        await fetchItemsForWarehouse();
      }
      if (taxes.isEmpty) {
        await fetchTaxes();
      }
      if (vendors.isEmpty) {
        await fetchPartners(TransType.purchaseOrder);
      }
      if (costCenters.isEmpty) {
        await fetchBusinessContext();
      }

      final vend = vendors.where((v) => v.name == trans.transText || v.code == trans.transText || v.id == trans.masterpartnerId).firstOrNull;
      final partnerId = vend?.id.isNotEmpty == true
          ? vend!.id
          : ((trans.masterpartnerId?.isNotEmpty == true) ? trans.masterpartnerId! : (vendors.isNotEmpty ? vendors.first.id : ''));

      final wh = warehouses.where((w) => w.name == trans.masterwarehouseId || w.id == trans.masterwarehouseId).firstOrNull;
      final warehouseId = wh?.id.isNotEmpty == true
          ? wh!.id
          : (_selectedWarehouse?.id ?? (warehouses.isNotEmpty ? warehouses.first.id : ''));
      final storeId = _selectedCostCenter?.id ?? (costCenters.isNotEmpty ? costCenters.first.id : '');

      DateTime entryDt = DateTime.now();
      if (trans.transEntrydate != null && trans.transEntrydate! > 0) {
        final ms = trans.transEntrydate! > 100000000000
            ? trans.transEntrydate!
            : trans.transEntrydate! * 1000;
        entryDt = DateTime.fromMillisecondsSinceEpoch(ms);
      }
      final entryDateIso = _formatIsoWithOffset(entryDt);

      final reqItems = <TransactionItemLine>[];
      if (lines != null) {
        for (int i = 0; i < lines.length; i++) {
          final l = lines[i];
          final uomId = await _resolveLineUomId(l);
          final lineTaxId = _resolveLineTaxId(l);

          reqItems.add(TransactionItemLine(
            itemUomId: uomId,
            taxId: lineTaxId,
            sequenceNumber: i + 1,
            quantity: l.translineQty ?? 1,
            unitPrice: l.translinePrice ?? 0,
            discountValue: l.translineTotaldiscvalue ?? 0,
          ));
        }
      }

      final sanitizedPayments = <Map<String, dynamic>>[];
      if (payments != null && payments.isNotEmpty) {
        if (paymentMethods.isEmpty) {
          await fetchPaymentMethods();
        }
        final uuidReg = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
        for (final p in payments) {
          final m = Map<String, dynamic>.from(p);
          String accId = m['account_id']?.toString() ?? '';
          if (!uuidReg.hasMatch(accId)) {
            accId = paymentMethods.isNotEmpty ? paymentMethods.first.id : 'ae813d56-e1d8-11ef-976d-6c3be5bcbf18';
            m['account_id'] = accId;
          }
          sanitizedPayments.add(m);
        }
      }

      final req = TransactionCreateRequest(
        header: TransactionHeader(
          transactionType: TransType.purchaseOrder.toString(), // "2"
          partnerId: partnerId,
          warehouseId: warehouseId,
          storeId: storeId,
          exchangeRate: 1,
          entryDate: entryDateIso,
          notes: trans.transText ?? 'Pembelian',
          taxIncluded: 'Y',
          terminId: trans.masterterminId,
        ),
        items: reqItems,
        payments: sanitizedPayments,
      );

      debugPrint('[SavePurchase] Payload POST /trans: ${jsonEncode(req.toJson())}');
      final res = await _api().post('/trans', data: req.toJson());
      if (res.data['success'] == true) {
        final d = res.data['data'] as Map<String, dynamic>?;
        final transNumber = d?['trans_number']?.toString();
        final transId = d?['trans_id']?.toString();
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Transaksi Pembelian berhasil disimpan ke server! (${transNumber ?? ''})'),
            backgroundColor: const Color(0xFF28A745),
            behavior: SnackBarBehavior.floating,
          ));
        }
        return (success: true, message: 'Transaksi Pembelian berhasil disimpan ke server!', transNumber: transNumber, transId: transId);
      } else {
        final errMsg = res.data['error']?['message'] ?? res.data['message'] ?? 'Gagal menyimpan transaksi ke server';
        return (success: false, message: errMsg.toString(), transNumber: null, transId: null);
      }
    } catch (e) {
      final msg = _dioMsg(e);
      debugPrint('Sync purchase transaction to server error: $msg');
      return (success: false, message: msg, transNumber: null, transId: null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addInventoryItem(InventoryItem item) {
    inventoryItems.insert(0, item);
    notifyListeners();
  }

  Future<void> _saveLocalTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salesJson = jsonEncode(salesInvoices.map((i) => i.toJson()).toList());
      final poJson = jsonEncode(purchaseOrders.map((p) => p.toJson()).toList());
      await prefs.setString('saved_sales_invoices', salesJson);
      await prefs.setString('saved_purchase_orders', poJson);
    } catch (e) {
      debugPrint('Error _saveLocalTransactions: $e');
    }
  }

  Future<void> _loadLocalTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salesRaw = prefs.getString('saved_sales_invoices');
      if (salesRaw != null && salesRaw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(salesRaw);
        salesInvoices = decoded.map((e) => SalesInvoice.fromJson(e as Map<String, dynamic>)).toList();
      }
      final poRaw = prefs.getString('saved_purchase_orders');
      if (poRaw != null && poRaw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(poRaw);
        purchaseOrders = decoded.map((e) => PurchaseOrder.fromJson(e as Map<String, dynamic>)).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error _loadLocalTransactions: $e');
    }
  }

  void addSalesInvoice(SalesInvoice inv) {
    final index = salesInvoices.indexWhere((i) => i.id == inv.id);
    if (index != -1) {
      salesInvoices[index] = inv;
    } else {
      salesInvoices.insert(0, inv);
    }
    _saveLocalTransactions();
    notifyListeners();
  }

  void deleteSalesInvoice(String id) {
    salesInvoices.removeWhere((i) => i.id == id);
    _saveLocalTransactions();
    notifyListeners();
  }

  void addPurchaseOrder(PurchaseOrder po) {
    final index = purchaseOrders.indexWhere((p) => p.id == po.id);
    if (index != -1) {
      purchaseOrders[index] = po;
    } else {
      purchaseOrders.insert(0, po);
    }
    _saveLocalTransactions();
    notifyListeners();
  }

  void deletePurchaseOrder(String id) {
    purchaseOrders.removeWhere((p) => p.id == id);
    _saveLocalTransactions();
    notifyListeners();
  }

  List<ProductSku> products = [];
  List<CustomerModel> customers = [];
  List<VendorModel> vendors = [];

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

  void logout() {
    _isLoggedIn = false;
    _currentView = AppView.login;
    _edition = AppEdition.pro;
    _activeModule = 'overview';
    notifyListeners();
  }
}
