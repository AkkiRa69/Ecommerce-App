import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grid_practice/helpers/login_helper.dart';
import 'package:grid_practice/routes/routes.dart';
import 'package:grid_practice/screens/login_screens/login_screen.dart';
import 'package:grid_practice/screens/order_screen/order_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late double screenWidth;
  late double screenHeight;
  Map<String, dynamic> user = {};
  File? profile;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username = prefs.getString('username') ?? '';
    final String profileString = prefs.getString('profile') ?? '';
    profile = File(profileString);
    user = await LoginHelper.getUserDetails(username) ?? {};
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Setting',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Bounceable(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.cart,
                );
              },
              child: SvgPicture.asset(
                "assets/cart 02.svg",
                height: 30,
                width: 30,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              color: Colors.white,
              width: screenWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 3,
                      ),
                    ),
                    child: profile == null
                        ? const Center(
                            child: Text(
                              "AKK",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Image.file(
                            profile!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user['first_name']} ${user['last_name']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "14 January",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Bounceable(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const OrderScreen(),
                    ));
              },
              child: _buildListTitle(
                image: "assets/bill.svg",
                title: "My Orders",
              ),
            ),
            const Divider(
              height: 0,
            ),
            _buildListTitle(
              image: "assets/globe.svg",
              title: "Change Language",
            ),
            const SizedBox(height: 20),
            _buildListTitle(
              image: "assets/information.svg",
              title: "About",
            ),
            const Divider(
              height: 0,
            ),
            _buildListTitle(
              image: "assets/notepad.svg",
              title: "Privacy Policy",
            ),
            const SizedBox(height: 20),
            _buildListTitle(
              onTap: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.remove('isLogin');
                await prefs.remove('username');
                await prefs.remove('profile');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ));
              },
              image: "assets/logout 01.svg",
              title: "Log out",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTitle(
      {required String image, required String title, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: SvgPicture.asset(
            image,
            width: 24,
            height: 24,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
