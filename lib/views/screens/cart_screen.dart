import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/cart_provider.dart';
import 'checkout_screen.dart'; // Chú ý: Đảm bảo import file Thanh toán mà bạn vừa làm

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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(
                            right: 12,
                          ), // Thu gọn padding
                          // 1. Gắn CHECKBOX vào trước hình ảnh sản phẩm
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: item.isChecked,
                                activeColor: Colors.orange,
                                onChanged: (value) {
                                  cart.toggleCheck(productId);
                                },
                              ),
                              Image.network(
                                item.product.image,
                                width: 50,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          title: Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            currencyFormat.format(item.product.price * 24000),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => cart.removeItem(productId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // --- KHỐI TỔNG TIỀN VÀ ĐẶT HÀNG Ở DƯỚI ĐÁY ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // 2. CHECKBOX CHỌN TẤT CẢ
                          Checkbox(
                            value: cart.isAllChecked,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              cart.toggleCheckAll();
                            },
                          ),
                          const Text('Tất cả'),
                          const Spacer(),
                          const Text(
                            'Tổng cộng: ',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            currencyFormat.format(
                              cart.totalAmount * 24000,
                            ), // Sẽ tự động nhảy theo các sản phẩm được tick
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton(
                          // Nút sẽ bị khóa (mờ đi) nếu không có sản phẩm nào được tick
                          onPressed: cart.checkedItems.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CheckoutScreen(
                                        // Truyền đúng danh sách "checkedItems" thay vì truyền hết
                                        cartItems: cart.checkedItems,
                                        totalAmount: cart.totalAmount,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            disabledBackgroundColor: Colors.grey.shade300,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                          child: Text(
                            'MUA HÀNG (${cart.checkedItems.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
