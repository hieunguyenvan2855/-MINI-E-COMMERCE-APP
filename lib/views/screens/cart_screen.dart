import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Giỏ hàng trống'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      final productId = cart.items.keys.toList()[index];
                      return ListTile(
                        leading: Image.network(item.product.image, width: 50),
                        title: Text(item.product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(currencyFormat.format(item.product.price * 24000)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('x${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cart.removeItem(productId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng cộng:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        currencyFormat.format(cart.totalAmount * 24000),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Thanh toán
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('MUA HÀNG', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
