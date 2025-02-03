import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyPassTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  String validateText;
  final Widget? widget;
  bool isObscure;
  MyPassTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validateText = 'Please enter som text',
    this.widget,
    this.isObscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: !isObscure,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validateText;
        }
        return null;
      },
      decoration: InputDecoration(
        suffixIcon: widget,
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
