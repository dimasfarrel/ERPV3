import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../models/sql_models.dart';
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

  // Real Database Metadata
  Map<String, dynamic> generalSettings = {};
  List<String> userPermissions = [];
  List<Map<String, dynamic>> roleGroups = [];
  List<Map<String, dynamic>> prefixes = [];

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

  // Lite Mode Data
  List<LiteCartItem> liteCart = [];
  List<LiteCashTransaction> liteCashTransactions = [];
  List<LiteDebt> liteDebts = [];

  AppProvider() {
    // Keep initial selections empty until user steps through the multi-tier flow
    // (Unit Bisnis -> Cost Center -> Gudang)
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
    notifyListeners();
  }

  // ==================== HR & Payroll Actions ====================

  void addEmployee(Employee emp) {
    employees.insert(0, emp);
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_ip', ip);
        await prefs.setString('server_port', port);
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Login gagal: ${response.data}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal koneksi ke database http://$ip:$port ($e)'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Coba Mock Demo',
            textColor: Colors.yellow,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              loginAsDemo();
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
      await fetchPartners(14);
      await fetchPartners(2);
      await fetchEmployees(); // Fetch staff data
      
      // Fetch historical transactions
      await fetchSalesTransactions();
      await fetchPurchaseTransactions();
      
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
    // prefixValue: 14 = Sales (Customer), 2 = Purchase (Supplier)
    try {
      final res = await _api().get('/partners/trans', queryParameters: {
        'prefix_value': prefixValue,
      });
      if (res.data['success'] == true) {
        final list = res.data['data'];
        if (list is List) {
          if (prefixValue == 14) {
            customers = list.map<CustomerModel>((c) => CustomerModel(
              code: c['partner_code']?.toString() ?? '',
              companyName: c['partner_name']?.toString() ?? '',
              contact: '-',
              city: '-',
              type: c['partnercategory_code']?.toString() ?? 'UMUM',
              creditLimit: 0,
            )).toList();
          } else if (prefixValue == 2) {
            vendors = list.map<VendorModel>((v) => VendorModel(
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

  Future<void> fetchEmployees() async {
    try {
      // Coba hit endpoint '/employees' atau '/staff'
      // Sesuaikan URL-nya jika di golang backend namanya beda (misal: /master-employee)
      final res = await _api().get('/employees'); 
      if (res.data['success'] == true) {
        final list = res.data['data'];
        if (list is List) {
          employees = list.map<Employee>((e) => Employee(
            id: e['employee_id']?.toString() ?? e['id']?.toString() ?? '',
            nip: e['employee_nip']?.toString() ?? e['nip']?.toString() ?? '',
            name: e['employee_name']?.toString() ?? e['name']?.toString() ?? 'Staff',
            position: e['position']?.toString() ?? '-',
            department: e['department']?.toString() ?? '-',
            status: e['status']?.toString() ?? 'Tetap',
            joinDate: DateTime.tryParse(e['join_date']?.toString() ?? '') ?? DateTime.now(),
            baseSalary: double.tryParse(e['base_salary']?.toString() ?? '0') ?? 0,
            allowance: double.tryParse(e['allowance']?.toString() ?? '0') ?? 0,
            email: e['email']?.toString() ?? '-',
            phone: e['phone']?.toString() ?? '-',
            bankAccount: e['bank_account']?.toString() ?? '-',
          )).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetchEmployees: ${_dioMsg(e)}');
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

  Future<void> saveSalesTransaction(Trans trans, {List<Transline>? lines}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = trans.toJson();
      if (lines != null) {
        data['lines'] = lines.map((l) => l.toJson()).toList();
      }
      final res = await _api().post('/trans', data: data);
      if (res.data['success'] == true) {
        await fetchSalesTransactions();
      }
    } catch (e) {
      debugPrint('Error saveSalesTransaction: ${_dioMsg(e)}');
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
         'trans_type': 2, // assume trans_type 2 is for purchases, adjust if needed
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

  Future<void> savePurchaseTransaction(Trans trans, {List<Transline>? lines}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = trans.toJson();
      if (lines != null) {
        data['lines'] = lines.map((l) => l.toJson()).toList();
      }
      final res = await _api().post('/trans', data: data);
      if (res.data['success'] == true) {
        await fetchPurchaseTransactions();
      }
    } catch (e) {
      debugPrint('Error savePurchaseTransaction: ${_dioMsg(e)}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addInventoryItem(InventoryItem item) {
    inventoryItems.insert(0, item);
    notifyListeners();
  }

  void addSalesInvoice(SalesInvoice inv) {
    final index = salesInvoices.indexWhere((i) => i.id == inv.id);
    if (index != -1) {
      salesInvoices[index] = inv;
    } else {
      salesInvoices.insert(0, inv);
    }
    notifyListeners();
  }

  void deleteSalesInvoice(String id) {
    salesInvoices.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void addPurchaseOrder(PurchaseOrder po) {
    final index = purchaseOrders.indexWhere((p) => p.id == po.id);
    if (index != -1) {
      purchaseOrders[index] = po;
    } else {
      purchaseOrders.insert(0, po);
    }
    notifyListeners();
  }

  void deletePurchaseOrder(String id) {
    purchaseOrders.removeWhere((p) => p.id == id);
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
