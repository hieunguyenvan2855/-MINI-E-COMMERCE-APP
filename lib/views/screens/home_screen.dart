import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import '../../models/product.dart';
import '../../viewmodels/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  bool _isLoading = false;
  int _limit = 10;
  int _activeBannerIndex = 0;
  double _appBarOpacity = 0.0;

  final List<String> _banners = [
    'https://img.freepik.com/free-vector/horizontal-sale-banner-template_23-2148897328.jpg',
    'https://img.freepik.com/free-vector/flat-design-shopping-center-social-media-cover-template_23-2149339419.jpg',
    'https://img.freepik.com/free-vector/flat-ecommerce-store-facebook-cover-template_23-2149117325.jpg',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Thời trang', 'icon': Icons.checkroom},
    {'name': 'Mỹ phẩm', 'icon': Icons.face},
    {'name': 'Điện tử', 'icon': Icons.tv},
    {'name': 'Thể thao', 'icon': Icons.sports_soccer},
    {'name': 'Điện thoại', 'icon': Icons.smartphone},
    {'name': 'Đồ gia dụng', 'icon': Icons.home},
    {'name': 'Sách', 'icon': Icons.book},
    {'name': 'Đồ chơi', 'icon': Icons.toys},
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    double newOpacity = (offset / 150).clamp(0.0, 1.0);
    if (newOpacity != _appBarOpacity) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _limit < 20) {
        _fetchProducts(loadMore: true);
      }
    }
  }

  Future<void> _fetchProducts({bool loadMore = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (loadMore)
      _limit += 6;
    else
      _limit = 10;

    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products?limit=$_limit'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = _appBarOpacity > 0.5 ? Colors.white : Colors.orange;

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _fetchProducts(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 100),
                    child: _buildBannerSlider(),
                  ),
                ),
                SliverToBoxAdapter(child: _buildCategoryGrid()),
                _buildSectionHeader('GỢI Ý HÔM NAY'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childCount: _products.length,
                    itemBuilder: (context, index) =>
                        _buildProductCard(_products[index]),
                  ),
                ),
                if (_isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator())),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
          _buildStickyAppBar(iconColor),
        ],
      ),
    );
  }

  Widget _buildStickyAppBar(Color iconColor) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
          color: Colors.orange.withOpacity(_appBarOpacity),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(_appBarOpacity),
            boxShadow: [
              if (_appBarOpacity > 0.8)
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TH4 - G13-C3',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.1,
                    ),
                  ),
                  _buildCartBadge(iconColor),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                        boxShadow: [
                          if (_appBarOpacity < 0.1)
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4)
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm trên Shopee...',
                          hintStyle:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.orange[700], size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(top: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartBadge(Color iconColor) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) => badges.Badge(
        position: badges.BadgePosition.topEnd(top: -5, end: -5),
        badgeContent: Text('${cart.itemCount}',
            style: const TextStyle(color: Colors.white, fontSize: 10)),
        showBadge: cart.itemCount > 0,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/cart'),
          child: Icon(Icons.shopping_cart_outlined, color: iconColor, size: 28),
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            onPageChanged: (index, _) =>
                setState(() => _activeBannerIndex = index),
          ),
          items: _banners
              .map((url) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        AnimatedSmoothIndicator(
          activeIndex: _activeBannerIndex,
          count: _banners.length,
          effect: const ExpandingDotsEffect(
              dotWidth: 8, dotHeight: 8, activeDotColor: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 15,
          childAspectRatio: 0.9,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!)),
              child: Icon(_categories[index]['icon'],
                  color: Colors.orange, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              _categories[index]['name'],
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(width: 4, height: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final priceVnd = NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
        .format(product.price * 24000);
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail', arguments: product);
      },
      child: Card(
        elevation: 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'product_${product.id}',
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[100], height: 160),
                  ),
                ),
                if (product.id % 2 == 0)
                  Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          color: Colors.red,
                          child: const Text('Yêu thích',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10)))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(priceVnd,
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Đã bán ${product.rating.count}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
