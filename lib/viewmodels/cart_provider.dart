import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? size;
  String? color;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.size,
    this.color,
  });
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

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

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }
}
