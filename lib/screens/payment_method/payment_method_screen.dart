import 'package:flutter/material.dart';
import 'package:grid_practice/constants/app_image.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Payment Method'),
      ),
      body: _buildPaymentMethod(),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      children: [
        ListTile(
          title: const Text('Credit Card'),
          subtitle: const Text('Visa, MasterCard, American Express'),
          leading: SizedBox(
            height: 100,
            child: Image.asset(AppImage.card3),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        Container(
          height: 10,
          color: const Color.fromARGB(89, 224, 224, 224),
        ),
        ListTile(
          title: const Text('Cash on Delivery'),
          subtitle: const Text(
            'Pay with cash upon delivery',
          ),
          leading: SizedBox(
            height: 100,
            child: Image.asset(AppImage.cash3),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
