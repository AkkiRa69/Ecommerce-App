import 'package:flutter/material.dart';
import 'package:grid_practice/constants/app_fonts.dart';
import 'package:grid_practice/routes/routes.dart';
import 'package:grid_practice/screens/cart_screen/cart_screen.dart';
import 'package:grid_practice/screens/homescreen/home_screen.dart';
import 'package:grid_practice/screens/login_screens/login_screen.dart';
import 'package:grid_practice/screens/main_screen/main_screen.dart';
import 'package:grid_practice/screens/map_screen/map_screen.dart';
import 'package:grid_practice/screens/payment_method/payment_method_screen.dart';
import 'package:grid_practice/screens/search_screen/search_screen.dart';
import 'package:grid_practice/screens/setting_screen/setting_screen.dart';
import 'package:grid_practice/screens/wishlist/wishlist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isLogin = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  isLogin = prefs.getBool('isLogin') ?? false;

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: AppFonts.spaceGrotesk,
      ),
      // initialRoute: Routes.main,
      home: isLogin ? const MainScreen() : LoginScreen(),
      routes: {
        Routes.main: (context) => const MainScreen(),
        Routes.home: (context) => const HomeScreen(),
        Routes.wishlist: (context) => const WishlistScreen(),
        Routes.setting: (context) => const SettingScreen(),
        Routes.paymentMethod: (context) => const PaymentMethodScreen(),
        Routes.map: (context) => const MapScreen(),
        Routes.cart: (context) => const CartScreen(),
        Routes.search: (context) => const SearchScreen(),
      },
    );
  }
}
