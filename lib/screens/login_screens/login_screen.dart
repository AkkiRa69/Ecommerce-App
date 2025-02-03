import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:grid_practice/helpers/login_helper.dart';
import 'package:grid_practice/screens/login_screens/register_screen.dart';
import 'package:grid_practice/screens/main_screen/main_screen.dart';
import 'package:grid_practice/widgets/app_modal.dart';
import 'package:grid_practice/widgets/my_button.dart';
import 'package:grid_practice/widgets/my_pass_text_field.dart';
import 'package:grid_practice/widgets/my_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final userNameController = TextEditingController();
  final passController = TextEditingController();
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "AKK",
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  MyTextField(
                    hintText: 'Username',
                    controller: userNameController,
                    validateText: 'Please enter your username',
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  MyPassTextField(
                    hintText: 'Password',
                    controller: passController,
                    validateText: 'Please enter your password',
                    isObscure: isVisible,
                    widget: Bounceable(
                      onTap: () {
                        setState(() {
                          isVisible = !isVisible;
                        });
                      },
                      child: !isVisible
                          ? const Icon(Icons.visibility_off_outlined)
                          : const Icon(Icons.visibility_outlined),
                    ),
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MyButton(
                          text: "LOGIN",
                          onPressed: () async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (_formKey.currentState!.validate()) {
                              await LoginHelper.database;
                              var result = await LoginHelper.checkUserExists(
                                userNameController.text,
                                passController.text,
                              );
                              if (result) {
                                await prefs.setBool('isLogin', true);
                                await prefs.setString(
                                    'username', userNameController.text);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ));

                                AppModal.showSuccessDialog(context);
                              } else {
                                IconSnackBar.show(
                                  context,
                                  label: 'Incorrect username or password',
                                  snackBarType: SnackBarType.fail,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ));
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
