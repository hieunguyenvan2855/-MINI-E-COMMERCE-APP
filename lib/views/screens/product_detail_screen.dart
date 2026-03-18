import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:badges/badges.dart' as badge_package;
import 'package:google_fonts/google_fonts.dart';
import '../../models/product.dart';
import '../../viewmodels/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  final List<String> _sizes = ['S', 'M', 'L'];
  final List<String> _colors = ['Red', 'Blue', 'Green'];

  List<String> get _images => [widget.product.image];

  void _showVariationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Chọn biến thể',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF673AB7),
                ),
              ),
              const SizedBox(height: 24),
              Text('Kích cỡ',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: _sizes.map((size) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(size,
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      selected: _selectedSize == size,
                      selectedColor: const Color(0xFF673AB7),
                      labelStyle: TextStyle(
                          color: _selectedSize == size
                              ? Colors.white
                              : Colors.black),
                      onSelected: (selected) {
                        setState(() => _selectedSize = selected ? size : null);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text('Màu sắc',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: _colors.map((color) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(color,
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      selected: _selectedColor == color,
                      selectedColor: const Color(0xFFFFC107),
                      labelStyle: TextStyle(
                          color: _selectedColor == color
                              ? Colors.white
                              : Colors.black),
                      onSelected: (selected) {
                        setState(
                            () => _selectedColor = selected ? color : null);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text('Số lượng',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_quantity > 1) {
                              setState(() => _quantity--);
                            }
                          },
                          icon: const Icon(Icons.remove, size: 20),
                        ),
                        Text('$_quantity',
                            style: GoogleFonts.poppins(fontSize: 18)),
                        IconButton(
                          onPressed: () {
                            setState(() => _quantity++);
                          },
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
                    cartProvider.addItemWithVariations(
                      widget.product,
                      _quantity,
                      _selectedSize,
                      _selectedColor,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thêm thành công',
                            style: GoogleFonts.poppins()),
                        backgroundColor: const Color(0xFF673AB7),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Xác nhận',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalItems =
        cartProvider.items.values.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết sản phẩm',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF673AB7),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: Color(0xFF673AB7)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, color: Color(0xFF673AB7)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel with Hero
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 16,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Hero(
                tag: 'product_${widget.product.id}',
                child: Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 320,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() => _currentImageIndex = index);
                        },
                      ),
                      items: _images.map((imageUrl) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24)),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        );
                      }).toList(),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedSmoothIndicator(
                          activeIndex: _currentImageIndex,
                          count: _images.length,
                          effect: const WormEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: Color(0xFF673AB7),
                            dotColor: Color(0xFFF8F9AA),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    widget.product.title,
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF673AB7)),
                  ),
                  const SizedBox(height: 12),
                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${widget.product.price}',
                        style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${(widget.product.price * 1.2).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Variations Selector
                  InkWell(
                    onTap: _showVariationsBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tune, color: const Color(0xFF673AB7)),
                          const SizedBox(width: 8),
                          Text('Chọn Kích cỡ, Màu sắc',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              size: 18, color: Color(0xFF673AB7)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text('Mô tả sản phẩm',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF673AB7))),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description,
                    maxLines: _isDescriptionExpanded ? null : 5,
                    overflow: _isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() =>
                            _isDescriptionExpanded = !_isDescriptionExpanded);
                      },
                      child: Text(
                          _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF673AB7),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 16,
                offset: const Offset(0, -4)),
          ],
        ),
        child: Row(
          children: [
            // Left side: Chat and Cart icons
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9AA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Color(0xFF673AB7)),
                  ),
                ),
                const SizedBox(width: 8),
                badge_package.Badge(
                  badgeContent: Text('$totalItems',
                      style: const TextStyle(color: Colors.white)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9AA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Color(0xFF673AB7)),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Right side: Buttons
            Row(
              children: [
                OutlinedButton(
                  onPressed: _showVariationsBottomSheet,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF673AB7), width: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Thêm vào giỏ',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF673AB7),
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Logic mua ngay
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Mua ngay',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
