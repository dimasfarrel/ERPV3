import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../../core/theme/app_theme.dart';

enum AppView { login, business, costCenter, gudang, dashboard }

class AppProvider extends ChangeNotifier {
  AppView _currentView = AppView.login;
  String _activeModule = 'overview';
  bool _isLoading = false;
  String _searchQuery = '';
  bool _isSidebarOpen = true;

  // Theme state
  bool _isDarkMode = false;
  Color _primaryColor = const Color(0xFF194BFB);

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

  // ==================== Mock Data ====================

  List<BusinessEntity> businessEntities = [];
  List<CostCenter> costCenters = [];
  List<WarehouseEntity> warehouses = [];
  List<SalesInvoice> salesInvoices = [];
  List<PurchaseOrder> purchaseOrders = [];
  List<RecentTransaction> recentTransactions = [];
  List<InventoryItem> inventoryItems = [];
  List<JournalEntry> journalEntries = [];
  List<ProductSku> products = [];
  List<CustomerModel> customers = [];
  List<VendorModel> vendors = [];

  // ==================== Actions ====================

  void navigateTo(AppView view) {
    _currentView = view;
    notifyListeners();
  }

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
      final dio = Dio();
      final url = 'http://$ip:$port/api/v2/auth/login';
      
      final response = await dio.post(
        url,
        data: {
          "client_id": "isoft_flutter",
          "username": username,
          "password": password,
          "device_name": "Postman Windows", // as requested by user
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        _isLoggedIn = true;
        _username = username;
        // Skip selection screens sementara karena datanya kosong, langsung tembak ke dashboard
        _currentView = AppView.dashboard;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Login gagal: ${response.data}'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Network Error: Gagal koneksi ke server $ip:$port'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
