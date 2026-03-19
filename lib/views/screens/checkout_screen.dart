import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
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
  final double shippingFee = 15000; // Giả lập phí ship

  // HÀM ĐẶT HÀNG (ĐÃ TÍCH HỢP LƯU LỊCH SỬ ĐƠN MUA)
  void _placeOrder(double totalPayment) {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                final provider =
                    Provider.of<CartProvider>(context, listen: false);

                // 1. LƯU VÀO LỊCH SỬ ĐƠN HÀNG
                provider.addOrder(widget.cartItems, totalPayment);

                // 2. Xóa sản phẩm đã thanh toán khỏi Giỏ hàng
                provider.clearCheckedItems();

                // 3. Bay về Trang chủ
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Trở về Trang Chủ',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final totalPayment = (widget.totalAmount * 24000) + shippingFee;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(fontSize: 18)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ĐỊA CHỈ NHẬN HÀNG (STYLE BÌ THƯ SHOPEE)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                      height: 3,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('assets/images/mail_border.png'),
                              fit: BoxFit.fitWidth,
                              repeat: ImageRepeat.repeatX))),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: primaryColor),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Địa chỉ nhận hàng',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              SizedBox(height: 4),
                              Text('Tân Nguyễn | (+84) 123 456 789',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              SizedBox(height: 4),
                              Text(
                                  'Đại học Thủy Lợi, 175 Tây Sơn, Đống Đa, Hà Nội',
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 2. KHỐI SẢN PHẨM & SHOP
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên Shop
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.storefront, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        const Text('TH4 Official Store',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Text('Mall',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Danh sách
                  ...widget.cartItems.map((item) {
                    String variationText = '';
                    if (item.color != null && item.size != null) {
                      variationText = 'Phân loại: ${item.color}, ${item.size}';
                    } else if (item.color != null || item.size != null) {
                      variationText = 'Phân loại: ${item.color ?? item.size}';
                    }

                    return Container(
                      color: Colors.grey.shade50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(item.product.image,
                                width: 70, height: 70, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 4),
                                if (variationText.isNotEmpty)
                                  Text(variationText,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        currencyFormat
                                            .format(item.product.price * 24000),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text('x${item.quantity}',
                                        style: const TextStyle(
                                            color: Colors.black54)),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(height: 1),

                  // Lời nhắn cho người bán & Phí vận chuyển
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text('Tin nhắn:',
                            style: TextStyle(color: Colors.black87)),
                        SizedBox(width: 16),
                        Expanded(
                            child: Text('Lưu ý cho người bán...',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phí vận chuyển (Nhanh):'),
                        Text(currencyFormat.format(shippingFee),
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. VOUCHER & THANH TOÁN
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.local_activity_outlined,
                        color: Colors.orange),
                    title: const Text('E-Commerce Voucher'),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Chọn hoặc nhập mã',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Phương thức thanh toán',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  RadioListTile(
                    title: const Row(
                      children: [
                        Icon(Icons.money, color: Colors.green, size: 24),
                        SizedBox(width: 12),
                        Text('Thanh toán khi nhận hàng (COD)',
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    value: 'COD',
                    groupValue: _paymentMethod,
                    activeColor: primaryColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val.toString()),
                  ),
                  RadioListTile(
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: Colors.pink,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.wallet,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text('Ví MoMo', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    value: 'MOMO',
                    groupValue: _paymentMethod,
                    activeColor: primaryColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) =>
                        setState(() => _paymentMethod = val.toString()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 4. TỔNG KẾT ĐƠN HÀNG
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text('Chi tiết thanh toán',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền hàng',
                          style: TextStyle(color: Colors.grey)),
                      Text(currencyFormat.format(widget.totalAmount * 24000)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền phí vận chuyển',
                          style: TextStyle(color: Colors.grey)),
                      Text(currencyFormat.format(shippingFee)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng thanh toán',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        currencyFormat.format(totalPayment),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // BOTTOM BAR - ĐẶT HÀNG
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Tổng thanh toán',
                          style:
                              TextStyle(fontSize: 13, color: Colors.black87)),
                      Text(
                        currencyFormat.format(totalPayment),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () =>
                    _placeOrder(totalPayment), // ĐÃ TRUYỀN TỔNG TIỀN VÀO ĐÂY
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  color: primaryColor,
                  child: const Text('Đặt Hàng',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
