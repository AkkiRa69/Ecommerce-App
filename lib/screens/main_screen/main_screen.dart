import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:grid_practice/constants/app_image.dart';
import 'package:grid_practice/screens/homescreen/home_screen.dart';
import 'package:grid_practice/screens/setting_screen/setting_screen.dart';
import 'package:grid_practice/screens/wishlist/wishlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      const HomeScreen(),
      const WishlistScreen(),
      const SettingScreen(),
    ];
  }

  // Add a method to reset to Home screen
  // void _goToHomeScreen() {
  //   setState(() {
  //     _currentIndex = 0; // Reset to Home screen
  //   });
  //   _pageController.jumpToPage(0);
  // }

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      color: Colors.white,
      curve: Curves.easeInOutCirc,
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 13),
        child: GNav(
          haptic: true,
          // rippleColor: Colors.black,
          // hoverColor: Colors.black,
          gap: 8,
          activeColor: Colors.white,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.grey[100]!,
          color: Colors.black,
          tabs: [
            buildGButton(
              title: "Home",
              icon: AppImage.home03,
              iconFill: AppImage.homeSolid,
              index: 0,
            ),
            buildGButton(
              title: "Wishlist",
              icon: AppImage.love,
              iconFill: AppImage.loveSolid,
              index: 1,
            ),
            buildGButton(
              title: "Settings",
              icon: AppImage.setting,
              iconFill: AppImage.settingSolid,
              index: 2,
            ),
          ],
          selectedIndex: _currentIndex,
          onTabChange: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }

  GButton buildGButton({
    required String title,
    required String icon,
    required String iconFill,
    required int index,
  }) {
    return GButton(
      icon: Icons.iso,
      gap: 10,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      leading: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        child: SvgPicture.asset(
          _currentIndex == index ? iconFill : icon,
          width: 40,
          height: 40,
          color: _currentIndex == index ? Colors.black : Colors.black,
        ),
      ),
      text: title.toUpperCase(),
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      // border: Border.all(
      //   color: _currentIndex == index ? Colors.black : Colors.transparent,
      //   width: 2,
      // ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
