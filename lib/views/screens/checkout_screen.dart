import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_provider.dart'; // Đảm bảo đường dẫn này đúng

class CheckoutScreen extends StatefulWidget {
  // Yêu cầu: Truyền bộ list các sản phẩm từ Giỏ hàng sang trang này
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'COD';
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  void _placeOrder() {
    // 1. Hiện Dialog báo thành công
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Đặt hàng thành công!', textAlign: TextAlign.center),
        content: const Text('Cảm ơn bạn đã mua sắm. Đơn hàng đang chờ xử lý.'),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                // Đổi clear() thành clearCheckedItems()
                Provider.of<CartProvider>(context, listen: false)
                    .clearCheckedItems();

                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Về Trang Chủ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ĐỊA CHỈ NHẬN HÀNG (UI Giả lập) ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tên của bạn | (+84) 123 456 789',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '175 Tây Sơn, Đống Đa, Hà Nội',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- DANH SÁCH SẢN PHẨM ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sản phẩm đơn hàng',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ...widget.cartItems
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dùng ảnh thật từ dữ liệu nhóm bạn
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.image,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Quy đổi giá nhân với 24000 giống file cart_screen.dart của nhóm bạn
                                        Text(
                                          currencyFormat.format(
                                            item.product.price * 24000,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'x${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // --- CHỌN PHƯƠNG THỨC THANH TOÁN ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  RadioListTile(
                    title: const Text('Thanh toán khi nhận hàng (COD)'),
                    value: 'COD',
                    groupValue: _paymentMethod,
                    activeColor: Colors.orange,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val.toString()),
                  ),
                  RadioListTile(
                    title: const Text('Ví MoMo'),
                    value: 'MOMO',
                    groupValue: _paymentMethod,
                    activeColor: Colors.orange,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val.toString()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- BOTTOM BAR ---
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng thanh toán', style: TextStyle(fontSize: 14)),
                  Text(
                    currencyFormat.format(
                      widget.totalAmount * 24000,
                    ), // Dùng định dạng giá của nhóm
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _placeOrder,
                child: const Text(
                  'Đặt Hàng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
