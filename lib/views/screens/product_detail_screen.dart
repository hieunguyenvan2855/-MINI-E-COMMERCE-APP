import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/product.dart';
import '../../viewmodels/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSize;
  String? selectedColor;
  int quantity = 1;

  final List<String> sizes = ['S', 'M', 'L', 'XL'];
  final List<String> colors = ['Đen', 'Trắng', 'Xanh', 'Đỏ'];

  void _addToCart() {
    // Bắt buộc chọn Size và Màu
    if (selectedSize == null || selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn Kích thước và Màu sắc!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Gọi hàm có Variations từ Provider
    Provider.of<CartProvider>(context, listen: false).addItemWithVariations(
      widget.product,
      quantity,
      selectedSize,
      selectedColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Đã thêm vào giỏ hàng thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Container(
              color: Colors.grey.shade50,
              width: double.infinity,
              height: 300,
              child: Hero(
                tag: 'product_${widget.product.id}',
                child: Image.network(widget.product.image, fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên và Giá
                  Text(widget.product.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    // Nhân tỷ giá 24000 để khớp với Giỏ hàng và Thanh toán
                    currencyFormat.format(widget.product.price * 24000),
                    style: TextStyle(
                        fontSize: 24,
                        color: primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // Chọn Kích thước
                  const SizedBox(height: 8),
                  const Text('Kích thước:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: sizes
                        .map((size) => ChoiceChip(
                              label: Text(size,
                                  style: TextStyle(
                                      color: selectedSize == size
                                          ? Colors.white
                                          : Colors.black87)),
                              selected: selectedSize == size,
                              onSelected: (selected) => setState(
                                  () => selectedSize = selected ? size : null),
                              selectedColor: primaryColor,
                              backgroundColor: Colors.grey.shade200,
                            ))
                        .toList(),
                  ),

                  // Chọn Màu sắc
                  const SizedBox(height: 20),
                  const Text('Màu sắc:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: colors
                        .map((color) => ChoiceChip(
                              label: Text(color,
                                  style: TextStyle(
                                      color: selectedColor == color
                                          ? Colors.white
                                          : Colors.black87)),
                              selected: selectedColor == color,
                              onSelected: (selected) => setState(() =>
                                  selectedColor = selected ? color : null),
                              selectedColor: primaryColor,
                              backgroundColor: Colors.grey.shade200,
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Mô tả sản phẩm
                  const Text('Mô tả sản phẩm',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(widget.product.description,
                      style: const TextStyle(
                          color: Colors.black87, height: 1.5, fontSize: 14)),
                  const SizedBox(
                      height:
                          100), // Khoảng trống cho thanh BottomBar không đè lên text
                ],
              ),
            ),
          ],
        ),
      ),

      // THANH CÔNG CỤ ĐẶT HÀNG DƯỚI ĐÁY
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ]),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: primaryColor),
                ),
                onPressed: _addToCart,
                child: Icon(Icons.add_shopping_cart, color: primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {
                  _addToCart();
                  // Nếu đã chọn đủ size/màu thì tự động nhảy sang Giỏ hàng
                  if (selectedSize != null && selectedColor != null) {
                    Navigator.pushNamed(context, '/cart');
                  }
                },
                child: const Text('Mua Ngay',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
