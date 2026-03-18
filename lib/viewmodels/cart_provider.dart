import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? size;
  String? color;
  bool isSelected; // Checkbox state

  CartItem({
    required this.product,
    this.quantity = 1,
    this.size,
    this.color,
    this.isSelected = false,
  });

  // Serialize CartItem to JSON
  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'title': product.title,
        'price': product.price,
        'image': product.image,
        'quantity': quantity,
        'size': size,
        'color': color,
        'isSelected': isSelected,
      };

  // Deserialize CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      product: product,
      quantity: json['quantity'] as int? ?? 1,
      size: json['size'] as String?,
      color: json['color'] as String?,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};
  bool _selectAll = false;

  Map<int, CartItem> get items => {..._items};
  bool get selectAll => _selectAll;

  int get itemCount => _items.length;

  CartProvider() {
    _loadFromStorage();
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    _saveToStorage();
    notifyListeners();
  }

  void addItemWithVariations(
      Product product, int quantity, String? size, String? color) {
    final key = product.id;
    if (_items.containsKey(key)) {
      _items[key]!.quantity += quantity;
      if (size != null) _items[key]!.size = size;
      if (color != null) _items[key]!.color = color;
    } else {
      _items[key] = CartItem(
        product: product,
        quantity: quantity,
        size: size,
        color: color,
      );
    }
    _saveToStorage();
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    _updateSelectAllState();
    _saveToStorage();
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      if (newQuantity <= 0) {
        _items.remove(productId);
        _updateSelectAllState();
      } else {
        _items[productId]!.quantity = newQuantity;
      }
      _saveToStorage();
      notifyListeners();
    }
  }

  void toggleItemSelection(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.isSelected = !_items[productId]!.isSelected;
      _updateSelectAllState();
      _saveToStorage();
      notifyListeners();
    }
  }

  void toggleSelectAll(bool value) {
    _selectAll = value;
    for (var item in _items.values) {
      item.isSelected = value;
    }
    _saveToStorage();
    notifyListeners();
  }

  void _updateSelectAllState() {
    if (_items.isEmpty) {
      _selectAll = false;
    } else {
      _selectAll = _items.values.every((item) => item.isSelected);
    }
  }

  void clear() {
    _items.clear();
    _selectAll = false;
    _saveToStorage();
    notifyListeners();
  }

  // Calculate total only for selected items
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      if (cartItem.isSelected) {
        total += cartItem.product.price * cartItem.quantity;
      }
    });
    return total;
  }

  // Get count of selected items
  int get selectedItemCount {
    return _items.values.where((item) => item.isSelected).length;
  }

  // PERSISTENCE: Save cart to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.entries
          .map((e) => json.encode({
                'productId': e.key,
                'data': e.value.toJson(),
              }))
          .toList();
      await prefs.setStringList('cart_items', cartData);
      await prefs.setBool('select_all', _selectAll);
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // PERSISTENCE: Load cart from SharedPreferences
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getStringList('cart_items');
      _selectAll = prefs.getBool('select_all') ?? false;

      if (cartData != null && cartData.isNotEmpty) {
        for (var item in cartData) {
          final decoded = json.decode(item) as Map<String, dynamic>;
          final productId = decoded['productId'] as int;
          final itemData = decoded['data'] as Map<String, dynamic>;

          // Create a Product object from saved data
          final product = Product(
            id: productId,
            title: itemData['title'] as String,
            price: itemData['price'] as double,
            description: '',
            category: '',
            image: itemData['image'] as String,
            rating: Rating(rate: 0, count: 0),
          );

          _items[productId] = CartItem.fromJson(itemData, product);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
    }
  }
}
