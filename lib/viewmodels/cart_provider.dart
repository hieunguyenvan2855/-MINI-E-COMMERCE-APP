import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? size;
  String? color;
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.size,
    this.color,
    this.isSelected = true,
  });
}

// CLASS ĐƠN HÀNG ĐỂ LƯU LỊCH SỬ
class OrderItem {
  final String id;
  final double totalAmount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String status;

  OrderItem({
    required this.id,
    required this.totalAmount,
    required this.products,
    required this.dateTime,
    this.status = 'Chờ xác nhận',
  });
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  // DANH SÁCH LƯU LỊCH SỬ MUA HÀNG
  final List<OrderItem> _orders = [];

  Map<int, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  int get selectedItemCount =>
      _items.values.where((item) => item.isSelected).length;
  bool get selectAll =>
      _items.isNotEmpty && _items.values.every((item) => item.isSelected);
  List<CartItem> get checkedItems =>
      _items.values.where((item) => item.isSelected).toList();

  // Lấy danh sách lịch sử đơn hàng
  List<OrderItem> get orders => [..._orders];

  // HÀM LƯU ĐƠN HÀNG (Sửa lỗi đỏ của bạn)
  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        totalAmount: total,
        products: List.from(cartProducts),
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void toggleItemSelection(int key) {
    if (_items.containsKey(key)) {
      _items[key]!.isSelected = !_items[key]!.isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool value) {
    _items.forEach((key, item) {
      item.isSelected = value;
    });
    notifyListeners();
  }

  void updateQuantity(int key, int newQuantity) {
    if (_items.containsKey(key)) {
      if (newQuantity > 0) {
        _items[key]!.quantity = newQuantity;
      } else {
        _items.remove(key);
      }
      notifyListeners();
    }
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void addItemWithVariations(
      Product product, int quantity, String? size, String? color) {
    final key = '${product.id}_${size ?? ''}_${color ?? ''}';
    if (_items.containsKey(key.hashCode)) {
      _items[key.hashCode]!.quantity += quantity;
    } else {
      _items[key.hashCode] = CartItem(
        product: product,
        quantity: quantity,
        size: size,
        color: color,
      );
    }
    notifyListeners();
  }

  void removeItem(int key) {
    _items.remove(key);
    notifyListeners();
  }

  void clearCheckedItems() {
    _items.removeWhere((key, item) => item.isSelected);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.isSelected) {
        total += cartItem.product.price * cartItem.quantity;
      }
    });
    return total;
  }
}
