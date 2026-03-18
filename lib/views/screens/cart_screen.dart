import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Giỏ hàng trống',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tiếp tục mua sắm'),
                  ),
                ],
              ),
            );
          }

          final itemsList = cart.items.entries.toList();

          return Column(
            children: [
              // Main content with ListView
              Expanded(
                child: ListView.builder(
                  itemCount: itemsList.length,
                  itemBuilder: (context, index) {
                    final productId = itemsList[index].key;
                    final item = itemsList[index].value;
                    final itemTotal = item.product.price * item.quantity;

                    return Dismissible(
                      key: ValueKey(productId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (direction) async {
                        return await _showDeleteConfirmation(context, cart, productId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Checkbox
                                Checkbox(
                                  value: item.isSelected,
                                  onChanged: (value) {
                                    cart.toggleItemSelection(productId);
                                  },
                                  activeColor: const Color(0xFF673AB7),
                                ),
                                // Product Image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[100],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.product.image,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(Icons.image_not_supported,
                                              color: Colors.grey[400]),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Product Info & Quantity Controls
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Title
                                      Text(
                                        item.product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Variation info (Size/Color)
                                      if (item.size != null ||
                                          item.color != null)
                                        Text(
                                          '${item.size ?? ''} ${item.color ?? ''}'
                                              .trim(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      // Price
                                      Text(
                                        currencyFormat
                                            .format(item.product.price * 24000),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF673AB7),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Quantity Counter
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (item.quantity <= 1) {
                                                  _showDeleteConfirmation(
                                                      context, cart, productId);
                                                } else {
                                                  cart.updateQuantity(productId,
                                                      item.quantity - 1);
                                                }
                                              },
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                child: const Icon(Icons.remove,
                                                    size: 16),
                                              ),
                                            ),
                                            Container(
                                              width: 32,
                                              height: 28,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(
                                                      color: Colors.grey[300]!),
                                                  right: BorderSide(
                                                      color: Colors.grey[300]!),
                                                ),
                                              ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => cart.updateQuantity(
                                                  productId, item.quantity + 1),
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                alignment: Alignment.center,
                                                child: const Icon(Icons.add,
                                                    size: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Total Item Price
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Tổng',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      currencyFormat.format(itemTotal * 24000),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Sticky Bottom Bar with Select All Checkbox
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    // Select All Row
                    Row(
                      children: [
                        Checkbox(
                          value: cart.selectAll,
                          onChanged: (value) {
                            cart.toggleSelectAll(value ?? false);
                          },
                          activeColor: const Color(0xFF673AB7),
                        ),
                        const Text(
                          'Chọn tất cả',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Text(
                          '${cart.selectedItemCount}/${cart.itemCount} sản phẩm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Total Amount & Checkout
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng thanh toán:',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              Text(
                                currencyFormat.format(cart.totalAmount * 24000),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: cart.selectedItemCount == 0
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Thanh toán ${cart.selectedItemCount} sản phẩm: ${currencyFormat.format(cart.totalAmount)}',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            disabledBackgroundColor: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            'MUA HÀNG',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, CartProvider cart, int productId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content:
              const Text('Bạn có muốn xóa sản phẩm này khỏi giỏ hàng không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                cart.removeItem(productId);
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa khỏi giỏ hàng')),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
