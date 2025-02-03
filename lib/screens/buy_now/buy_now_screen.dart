import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:grid_practice/constants/app_image.dart';
import 'package:grid_practice/ds/coupons_code.dart';
import 'package:grid_practice/models/coupon_model.dart';
import 'package:grid_practice/models/product_model.dart';
import 'package:grid_practice/routes/routes.dart';
import 'package:grid_practice/screens/map_screen/map_screen.dart';
import 'package:grid_practice/widgets/app_modal.dart';

// ignore: must_be_immutable
class BuyNowScreen extends StatefulWidget {
  ProductModel data;
  String color;
  BuyNowScreen({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  State<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends State<BuyNowScreen> {
  int qty = 1;
  String _address = '';
  String phone = '', couponCode = '';
  int discount = 0;
  double subtotal = 0, total = 0, discountPrice = 0;
  List<CouponModel> couponsList = [];

  @override
  void initState() {
    super.initState();
    couponsList = coupons
        .map(
          (e) => CouponModel.fromJSON(e),
        )
        .toList();
    calculateLuy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _buildBody(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Text(
            widget.data.currency +
                widget.data.priceSign +
                (total.toStringAsFixed(2)).toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            height: 50,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Text(
                "Place Order",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
          title: Text("Orders"),
        ),
        _buildSliverDivider(),
        SliverToBoxAdapter(
          child: Bounceable(
            onTap: () => pushToMap(context),
            child: _buildSliverListTile(
              icon: AppImage.deliveryScooter2x,
              title: "Shipping Address",
              subtitle: _address.isEmpty ? "Current Location" : _address,
            ),
          ),
        ),
        _buildSliverDivider(),
        SliverToBoxAdapter(
          child: Bounceable(
            onTap: () async {
              var result = await AppModal().show(
                context,
                title: "Contact Number",
                subtitle: "Enter Phone Number",
              );
              if (result is String) {
                setState(() {
                  phone = result;
                });
              }
            },
            child: _buildSliverListTile(
              icon: AppImage.phone2x,
              title: "Contact Number",
              subtitle: phone.isEmpty ? "Enter Phone Number" : phone,
            ),
          ),
        ),
        _buildSliverDivider(),
        SliverToBoxAdapter(
          child: Bounceable(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.paymentMethod,
              );
            },
            child: _buildSliverListTile(
              icon: AppImage.cashInHand2x,
              title: "Delivery Method",
              subtitle: "Cash on Delivery",
            ),
          ),
        ),
        _buildSliverDivider(),
        _buildSliverProduct(),
        _buildSliverDivider(),
        SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () async {
              var result = await AppModal().show(
                context,
                title: "Coupon",
                subtitle: "Enter Coupon Code",
              );
              if (result is String) {
                setState(() {
                  couponCode = result;
                });

                var discountCoupon = couponsList
                    .where(
                      (element) => element.code == couponCode,
                    )
                    .first;
                setState(() {
                  discount = discountCoupon.value;
                  calculateLuy();
                });
              }
            },
            child: _buildSliverListTile(
              icon: AppImage.voucher3x,
              title: "Coupon",
              subtitle: couponCode.isEmpty ? "Standard Delivery" : couponCode,
              isCoupon: true,
            ),
          ),
        ),
        _buildSliverDivider(),
        _buildSliverOrderSummary(),
      ],
    );
  }

  Widget _buildSliverOrderSummary() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  AppImage.purchaseOrder2x,
                  width: 25,
                  height: 25,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 15),
                Text(
                  "Order Summary ($qty ${qty > 1 ? "items" : "item"}) ",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              color: Color.fromARGB(77, 158, 158, 158),
              thickness: 1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subtotal",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "${widget.data.currency} ${widget.data.priceSign}${subtotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Discount"),
                Text("\$$discountPrice"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${widget.data.currency} ${widget.data.priceSign}${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverProduct() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Hero(
                tag: widget.data.imageUrl,
                child: CachedNetworkImage(
                  imageUrl: widget.data.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${widget.data.currency} ${widget.data.priceSign}${widget.data.price}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Color: ${widget.color}",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    _buildQtyBtn(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn() {
    return Row(
      children: [
        const Spacer(),
        Bounceable(
          onTap: () {
            setState(() {
              if (qty > 1) {
                qty--;
                calculateLuy();
              }
            });
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
                top: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
                left: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.remove,
                size: 20,
              ),
            ),
          ),
        ),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.black,
            ),
          ),
          child: Center(
            child: Text(
              qty.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Bounceable(
          onTap: () {
            setState(() {
              qty++;
              calculateLuy();
            });
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
                top: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
                right: BorderSide(
                  width: 1,
                  color: Colors.black,
                ),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverListTile(
      {String? title, String? subtitle, String? icon, bool? isCoupon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            icon!,
            width: 25,
            height: 25,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          isCoupon == true
              ? Text(
                  "$discount%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildSliverDivider() {
    return SliverToBoxAdapter(
      child: Container(
        height: 8,
        color: const Color.fromARGB(112, 224, 224, 224),
      ),
    );
  }

  void pushToMap(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
    if (result != null) {
      setState(() {
        _address = result['address'];
      });
      print('Selected Address: ${result['address']}');
      print('Latitude: ${result['latitude']}');
      print('Longitude: ${result['longitude']}');
    }
  }

  void calculateLuy() {
    subtotal = double.parse(widget.data.price) * qty;
    discountPrice = subtotal * discount / 100;
    total = subtotal - discountPrice;
  }
}
