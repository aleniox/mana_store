// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Mana Store';

  @override
  String get dashboard => 'Trang chủ';

  @override
  String get sell => 'Bán hàng';

  @override
  String get history => 'Lịch sử';

  @override
  String get todayOverview => 'Tổng quan hôm nay';

  @override
  String get todayRevenue => 'Doanh thu hôm nay';

  @override
  String get totalRevenue => 'Tổng doanh thu';

  @override
  String get invoice => 'Hóa đơn';

  @override
  String get invoices => 'Hóa đơn';

  @override
  String get product => 'Sản phẩm';

  @override
  String get products => 'Sản phẩm';

  @override
  String get inStock => 'Còn null';

  @override
  String get outOfStock => 'Hết hàng';

  @override
  String get quickAccess => 'Truy cập nhanh';

  @override
  String get searchOrScan => 'Tìm kiếm hoặc quét mã vạch\nđể thêm sản phẩm';

  @override
  String get emptyCart => 'Giỏ hàng trống';

  @override
  String get noProducts => 'Chưa có sản phẩm nào';

  @override
  String get noInvoices => 'Chưa có hóa đơn nào';

  @override
  String get addFirstProduct => 'Bấm + để thêm sản phẩm đầu tiên';

  @override
  String get invoicesWillAppearHere => 'Hóa đơn sẽ xuất hiện tại đây';

  @override
  String get scanBarcode => 'Quét mã vạch';

  @override
  String get pointCamera => 'Hướng camera vào mã vạch';

  @override
  String get added => 'Đã thêm';

  @override
  String get notFound => 'Không tìm thấy';

  @override
  String get productNotFound => 'Không tìm thấy sản phẩm với mã';

  @override
  String get addNew => 'Thêm mới';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get deleteProduct => 'Xóa sản phẩm';

  @override
  String deleteConfirm(String name) {
    return 'Xóa \"$name\"?\nHành động này không thể hoàn tác.';
  }

  @override
  String get deleted => 'Đã xóa';

  @override
  String get cannotDeleteProductInInvoice =>
      'Không thể xóa: sản phẩm đã có trong hóa đơn';

  @override
  String get total => 'Tổng cộng';

  @override
  String get payment => 'Thanh toán';

  @override
  String get print => 'In';

  @override
  String get exportPdf => 'Xuất PDF';

  @override
  String get exportExcel => 'Xuất Excel';

  @override
  String get settings => 'Cài đặt';

  @override
  String get backupRestore => 'Sao lưu & Phục hồi';

  @override
  String get exportDatabase => 'Xuất (.mana)';

  @override
  String get importDatabase => 'Nhập (.mana)';

  @override
  String get syncProducts => 'Đồng bộ kho hàng';

  @override
  String get exportProducts => 'Xuất SP (.xlsx)';

  @override
  String get importProducts => 'Nhập SP (.xlsx)';

  @override
  String get exportProductList => 'Xuất danh sách sản phẩm ra Excel';

  @override
  String get importProductList => 'Nhập sản phẩm từ file Excel';

  @override
  String get databaseBackupDesc =>
      'Sao lưu toàn bộ dữ liệu để dự phòng hoặc chuyển sang máy khác.';

  @override
  String get productSyncDesc =>
      'Xuất danh sách sản phẩm ra Excel để chỉnh sửa hoặc thêm hàng loạt.';

  @override
  String get importWarning =>
      'Việc nhập dữ liệu sẽ XOÁ toàn bộ dữ liệu hiện tại và thay bằng dữ liệu trong file. Bạn có chắc chắn không?';

  @override
  String get accept => 'Chấp nhận';

  @override
  String get reject => 'Từ chối';

  @override
  String get importSuccess => 'Nhập dữ liệu thành công!';

  @override
  String importProductSuccess(int imported, int updated) {
    return 'Nhập thành công: $imported mới, $updated cập nhật';
  }

  @override
  String get stats => 'Thống kê';

  @override
  String get revenueStats => 'Thống kê doanh thu';

  @override
  String get selectYear => 'Chọn năm:';

  @override
  String get revenueByMonth => 'Doanh thu theo tháng';

  @override
  String get revenueByYear => 'Doanh thu theo năm';

  @override
  String noDataYear(int year) {
    return 'Chưa có dữ liệu năm $year';
  }

  @override
  String get noData => 'Chưa có dữ liệu';

  @override
  String get month => 'Tháng';

  @override
  String get year => 'Năm';

  @override
  String get productList => 'Kho hàng';

  @override
  String get addProduct => 'Thêm sản phẩm';

  @override
  String get editProduct => 'Sửa sản phẩm';

  @override
  String get barcode => 'Mã vạch';

  @override
  String get productName => 'Tên sản phẩm';

  @override
  String get price => 'Giá';

  @override
  String get stock => 'Tồn kho';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get error => 'Lỗi';

  @override
  String get loading => 'Đang tải';

  @override
  String get loadError => 'Lỗi tải dữ liệu';

  @override
  String get hideRevenue => 'Ẩn doanh thu';

  @override
  String get showRevenue => 'Hiện doanh thu';

  @override
  String productCount(int count) {
    return '$count sản phẩm';
  }

  @override
  String invoiceCount(int count) {
    return '$count hóa đơn';
  }

  @override
  String get revenue => 'Doanh thu';

  @override
  String get invoiceDetail => 'Chi tiết hóa đơn';

  @override
  String invoiceNumber(int id) {
    return 'Hóa đơn #$id';
  }

  @override
  String get date => 'Ngày';

  @override
  String get time => 'Giờ';

  @override
  String get quantity => 'SL';

  @override
  String get unitPrice => 'Đơn giá';

  @override
  String get amount => 'Thành tiền';

  @override
  String get subtotal => 'Tạm tính';

  @override
  String get searchProducts => 'Tìm kiếm sản phẩm';

  @override
  String get scanToAdd => 'Quét để thêm';
}
