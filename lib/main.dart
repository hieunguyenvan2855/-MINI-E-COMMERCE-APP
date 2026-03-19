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
        primaryColor: Colors.orange, // Đã đổi sang Cam chủ đạo
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/order_history': (context) => const OrderHistoryScreen(),
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
