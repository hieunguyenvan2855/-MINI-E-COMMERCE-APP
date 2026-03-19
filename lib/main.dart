import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/cart_provider.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/cart_screen.dart';
import 'views/screens/order_history_screen.dart';
import 'models/product.dart';
import 'views/screens/product_detail_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF673AB7), // Tím chủ đạo của nhóm
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
          secondary: const Color(0xFFFFC107), // Vàng
        ),
        // Đã gỡ bỏ GoogleFonts để không bị lỗi thư viện
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/order_history': (context) => const OrderHistoryScreen(),
        // product_detail handled in onGenerateRoute to accept arguments
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_detail') {
          final args = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: args),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
