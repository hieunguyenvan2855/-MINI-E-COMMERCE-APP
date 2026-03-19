import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/cart_provider.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text('Đơn mua của tôi', style: TextStyle(fontSize: 18)),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        // LẤY DỮ LIỆU ĐƠN HÀNG TỪ PROVIDER
        body: Consumer<CartProvider>(builder: (context, cartProvider, child) {
          return TabBarView(
            children: [
              _buildOrderList(
                  'Chờ xác nhận', primaryColor, true, cartProvider.orders),
              _buildOrderList(
                  'Đang giao', primaryColor, false, cartProvider.orders),
              _buildOrderList(
                  'Đã giao', primaryColor, false, cartProvider.orders),
              _buildOrderList(
                  'Đã hủy', primaryColor, false, cartProvider.orders),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderList(String status, Color primaryColor, bool isPending,
      List<OrderItem> allOrders) {
    // Lọc ra các đơn hàng có trạng thái tương ứng với Tab hiện tại
    final orders = allOrders.where((o) => o.status == status).toList();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    if (orders.isEmpty) {
      return _buildEmptyState('Chưa có đơn hàng nào.');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storefront,
                            size: 18, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        const Text('TH4 Official Store',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                    Text(order.status,
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
              const Divider(height: 1),

              // DANH SÁCH CÁC SẢN PHẨM TRONG ĐƠN ĐÓ
              ...order.products.map((item) {
                String variationText = '';
                if (item.color != null && item.size != null) {
                  variationText = 'Phân loại: ${item.color}, ${item.size}';
                } else if (item.color != null || item.size != null) {
                  variationText = 'Phân loại: ${item.color ?? item.size}';
                }

                return Container(
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Image.network(item.product.image,
                              fit: BoxFit.cover)),
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              currencyFormat.format(item.product.price * 24000),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('x${item.quantity}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(height: 1),

              // FOOTER: TỔNG TIỀN
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Thành tiền: ',
                        style: TextStyle(color: Colors.black87, fontSize: 14)),
                    Text(currencyFormat.format(order.totalAmount),
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ACTIONS
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isPending)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () {},
                        child: const Text('Đánh giá'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: Text(isPending ? 'Liên hệ Người bán' : 'Mua Lại'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child:
                Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
