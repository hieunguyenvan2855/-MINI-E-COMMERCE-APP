import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                      final itemKey = cart.items.keys.toList()[index];

                      String variationText = '';
                      if (item.color != null && item.size != null) {
                        variationText =
                            'Màu: ${item.color}, Size: ${item.size}';
                      } else if (item.color != null) {
                        variationText = 'Màu: ${item.color}';
                      } else if (item.size != null) {
                        variationText = 'Size: ${item.size}';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(right: 12),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value:
                                    item.isSelected, // ĐÃ ĐỔI THÀNH isSelected
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  cart.toggleItemSelection(itemKey); // ĐÃ ĐỔI
                                },
                              ),
                              Image.network(item.product.image,
                                  width: 50, fit: BoxFit.contain),
                            ],
                          ),
                          title: Text(item.product.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (variationText.isNotEmpty)
                                Text(variationText,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              Text(
                                  currencyFormat.format(
                                      item.product.price * 24000),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 20),
                                onPressed: () {
                                  cart.updateQuantity(
                                      itemKey, item.quantity - 1);
                                },
                              ),
                              Text('${item.quantity}',
                                  style: const TextStyle(fontSize: 14)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 20),
                                onPressed: () {
                                  cart.updateQuantity(
                                      itemKey, item.quantity + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // KHỐI TỔNG TIỀN & MUA HÀNG
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, -2))
                      ]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: cart.selectAll, // ĐÃ ĐỔI
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              cart.toggleSelectAll(value ?? false); // ĐÃ ĐỔI
                            },
                          ),
                          const Text('Tất cả'),
                          const Spacer(),
                          const Text('Tổng cộng: ',
                              style: TextStyle(fontSize: 16)),
                          Text(
                            currencyFormat.format(cart.totalAmount * 24000),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton(
                          onPressed: cart.selectedItemCount == 0
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutScreen(
                                        cartItems: cart.checkedItems,
                                        totalAmount: cart.totalAmount,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            disabledBackgroundColor: Colors.grey.shade300,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: Text('MUA HÀNG (${cart.selectedItemCount})',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
