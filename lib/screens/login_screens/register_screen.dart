import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:grid_practice/helpers/login_helper.dart';
import 'package:grid_practice/screens/login_screens/login_screen.dart';
import 'package:grid_practice/widgets/my_button.dart';
import 'package:grid_practice/widgets/my_pass_text_field.dart';
import 'package:grid_practice/widgets/my_text_field.dart';

// ignore: must_be_immutable
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();

  final lastNameController = TextEditingController();

  final userNameController = TextEditingController();

  final passController = TextEditingController();

  final conPassController = TextEditingController();

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                              color: Colors.black,
                            ),
                            shape: BoxShape.circle),
                      ),
                      Positioned(
                        right: 5,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  MyTextField(
                    hintText: 'First Name',
                    controller: firstNameController,
                    validateText: 'Please enter your first name',
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  MyTextField(
                    hintText: 'Last Name',
                    controller: lastNameController,
                    validateText: 'Please enter your last name',
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
                    height: 24,
                  ),
                  MyPassTextField(
                    hintText: 'Confirm Password',
                    controller: conPassController,
                    validateText: 'Please enter your confrim password',
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
                          text: 'REGISTER',
                          onPressed: () async {
                            await LoginHelper.database;
                            if (_formKey.currentState!.validate()) {
                              await LoginHelper.registerUser(
                                userNameController.text,
                                passController.text,
                                firstNameController.text,
                                lastNameController.text,
                              );

                              IconSnackBar.show(
                                context,
                                label: 'Register successfully',
                                snackBarType: SnackBarType.success,
                              );
                              Navigator.pop(context);
                            } else {
                              IconSnackBar.show(
                                context,
                                label: 'Incorrect username or password',
                                snackBarType: SnackBarType.fail,
                              );
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
                    "Already have an account?",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                    },
                    child: const Text(
                      "Login",
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
