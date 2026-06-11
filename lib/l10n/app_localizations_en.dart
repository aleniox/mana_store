// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mana Store';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get sell => 'Sell';

  @override
  String get history => 'History';

  @override
  String get todayOverview => 'Today\'s Overview';

  @override
  String get todayRevenue => 'Today\'s Revenue';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get invoice => 'Invoice';

  @override
  String get invoices => 'Invoices';

  @override
  String get product => 'Product';

  @override
  String get products => 'Products';

  @override
  String get inStock => 'In stock';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get searchOrScan => 'Search or scan barcode\nto add products';

  @override
  String get emptyCart => 'Empty cart';

  @override
  String get noProducts => 'No products yet';

  @override
  String get noInvoices => 'No invoices yet';

  @override
  String get addFirstProduct => 'Tap + to add your first product';

  @override
  String get invoicesWillAppearHere => 'Invoices will appear here';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get pointCamera => 'Point camera at barcode';

  @override
  String get added => 'Added';

  @override
  String get notFound => 'Not found';

  @override
  String get productNotFound => 'Product not found with barcode';

  @override
  String get addNew => 'Add new';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteProduct => 'Delete product';

  @override
  String deleteConfirm(String name) {
    return 'Delete \"$name\"?\nThis action cannot be undone.';
  }

  @override
  String get deleted => 'Deleted';

  @override
  String get cannotDeleteProductInInvoice =>
      'Cannot delete: product exists in invoices';

  @override
  String get total => 'Total';

  @override
  String get payment => 'Payment';

  @override
  String get print => 'Print';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get settings => 'Settings';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get exportDatabase => 'Export (.mana)';

  @override
  String get importDatabase => 'Import (.mana)';

  @override
  String get syncProducts => 'Sync Products';

  @override
  String get exportProducts => 'Export SP (.xlsx)';

  @override
  String get importProducts => 'Import SP (.xlsx)';

  @override
  String get exportProductList => 'Export product list to Excel';

  @override
  String get importProductList => 'Import products from Excel file';

  @override
  String get databaseBackupDesc =>
      'Backup all data for safekeeping or moving to another device.';

  @override
  String get productSyncDesc =>
      'Export products to Excel for editing or bulk adding.';

  @override
  String get importWarning =>
      'Importing will REPLACE all current data with data from the file. Are you sure?';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get importSuccess => 'Import successful!';

  @override
  String importProductSuccess(int imported, int updated) {
    return 'Imported: $imported new, $updated updated';
  }

  @override
  String get stats => 'Statistics';

  @override
  String get revenueStats => 'Revenue Statistics';

  @override
  String get selectYear => 'Select year:';

  @override
  String get revenueByMonth => 'Revenue by month';

  @override
  String get revenueByYear => 'Revenue by year';

  @override
  String noDataYear(int year) {
    return 'No data for year $year';
  }

  @override
  String get noData => 'No data';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get productList => 'Product List';

  @override
  String get addProduct => 'Add product';

  @override
  String get editProduct => 'Edit product';

  @override
  String get barcode => 'Barcode';

  @override
  String get productName => 'Product name';

  @override
  String get price => 'Price';

  @override
  String get stock => 'Stock';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading';

  @override
  String get loadError => 'Error loading data';

  @override
  String get hideRevenue => 'Hide revenue';

  @override
  String get showRevenue => 'Show revenue';

  @override
  String productCount(int count) {
    return '$count products';
  }

  @override
  String invoiceCount(int count) {
    return '$count invoices';
  }

  @override
  String get revenue => 'Revenue';

  @override
  String get invoiceDetail => 'Invoice Detail';

  @override
  String invoiceNumber(int id) {
    return 'Invoice #$id';
  }

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get quantity => 'Qty';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get amount => 'Amount';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get searchProducts => 'Search products';

  @override
  String get scanToAdd => 'Scan to add';
}
