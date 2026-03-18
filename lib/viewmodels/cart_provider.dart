import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isChecked; // Thêm trạng thái tick chọn

  // Mặc định thêm vào giỏ là được tick luôn (isChecked = true)
  CartItem({required this.product, this.quantity = 1, this.isChecked = true});
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  // Lọc ra các sản phẩm ĐÃ ĐƯỢC TICK
  List<CartItem> get checkedItems =>
      _items.values.where((item) => item.isChecked).toList();

  // Kiểm tra xem nút "Chọn tất cả" có đang bật không
  bool get isAllChecked =>
      _items.isNotEmpty && _items.values.every((item) => item.isChecked);

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Hàm mới: Chỉ xóa những sản phẩm ĐÃ MUA thành công
  void clearCheckedItems() {
    _items.removeWhere((key, item) => item.isChecked);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Đảo trạng thái Tick/Bỏ tick của 1 sản phẩm
  void toggleCheck(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.isChecked = !_items[productId]!.isChecked;
      notifyListeners();
    }
  }

  // Bật/Tắt nút "Chọn tất cả"
  void toggleCheckAll() {
    bool newState = !isAllChecked;
    _items.forEach((key, item) {
      item.isChecked = newState;
    });
    notifyListeners();
  }

  // TỔNG TIỀN: Chỉ cộng dồn những sản phẩm isChecked == true
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.isChecked) {
        total += cartItem.product.price * cartItem.quantity;
      }
    });
    return total;
  }
}
