import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:grid_practice/constants/app_image.dart';
import 'package:grid_practice/ds/coupons_code.dart';
import 'package:grid_practice/helpers/add_2_cart_helper.dart';
import 'package:grid_practice/models/coupon_model.dart';
import 'package:grid_practice/models/product_model.dart';
import 'package:grid_practice/routes/routes.dart';
import 'package:grid_practice/screens/map_screen/map_screen.dart';
import 'package:grid_practice/widgets/app_modal.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class BuyNowScreen2 extends StatefulWidget {
  List<ProductModel> data;

  BuyNowScreen2({
    super.key,
    required this.data,
  });

  @override
  State<BuyNowScreen2> createState() => _BuyNowScreen2State();
}

class _BuyNowScreen2State extends State<BuyNowScreen2> {
  var _address = '';
  String phone = '', couponCode = '';
  int discount = 0;
  List<int> qtys = [];
  double subtotal = 0, total = 0, discountPrice = 0;
  List<CouponModel> couponsList = [];
  bool isOrder = false;
  bool isReceived = false;
  @override
  void initState() {
    super.initState();
    couponsList = coupons
        .map(
          (e) => CouponModel.fromJSON(e),
        )
        .toList();
    qtys = List<int>.filled(widget.data.length, 0);
    getQty(widget.data);
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
          isOrder
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PROCESS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      DateFormat('hh:mm a, dd MMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              : Text(
                  widget.data[0].currency +
                      widget.data[0].priceSign +
                      (total.toStringAsFixed(2)).toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const Spacer(),
          isOrder ? _buildButtonMark() : _buildButtonOrder(),
        ],
      ),
    );
  }

  Bounceable _buildButtonOrder() {
    return Bounceable(
      onTap: () {
        setState(() {
          isOrder = true;
        });
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Bounceable _buildButtonMark() {
    return Bounceable(
      onTap: () {
        setState(() {
          isReceived = true;
        });
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: isReceived
            ? BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(5),
              )
            : BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black,
                ),
              ),
        child: Center(
          child: Text(
            !isReceived ? "Mark as Received" : "Completed",
            style: TextStyle(
              fontSize: 15,
              color: isReceived ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
          centerTitle: true,
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
        SliverList.builder(
          itemCount: widget.data.length,
          itemBuilder: (context, index) {
            final product = widget.data[index];
            return _buildSliverProduct(product, index);
          },
        ),
        _buildSliverDivider(),
        SliverToBoxAdapter(
          child: Bounceable(
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

  Widget _buildSliverProduct(ProductModel product, int index) {
    return Container(
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
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
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
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${product.currency} ${product.priceSign}${product.price}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Color: ${product.selectedColor}",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Spacer(),
                      Bounceable(
                        onTap: () async {
                          await Add2Cart.updateQuantity(
                              product, product.selectedColor, false);
                          qtys[index] = await Add2Cart.getCurrentQuantity(
                              product.name, product.selectedColor);
                          calculateTotals(); // Recalculate after quantity change
                          setState(() {});
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
                            qtys[index].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Bounceable(
                        onTap: () async {
                          await Add2Cart.updateQuantity(
                              product, product.selectedColor, true);
                          qtys[index] = await Add2Cart.getCurrentQuantity(
                              product.name, product.selectedColor);
                          calculateTotals(); // Recalculate after quantity change
                          setState(() {});
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null) {
      setState(() {
        _address = result['address'];
      });
    }
  }

  Widget _buildSliverOrderSummary() {
    // Calculate total quantity from the qtys list
    int totalQty = qtys.fold(0, (sum, qty) => sum + qty);

    // Calculate totals before building the widget
    calculateTotals();

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
                  "Order Summary ($totalQty ${totalQty > 1 ? "items" : "item"})",
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
                  "${widget.data[0].currency} ${widget.data[0].priceSign}${subtotal.toStringAsFixed(2)}",
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
                Text(
                  "${widget.data[0].currency} ${widget.data[0].priceSign}${discountPrice.toStringAsFixed(2)}",
                ),
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
                  "${widget.data[0].currency} ${widget.data[0].priceSign}${total.toStringAsFixed(2)}",
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

  void calculateTotals() {
    // Calculate subtotal based on current quantities and prices
    subtotal = 0;
    for (int i = 0; i < widget.data.length; i++) {
      subtotal += double.parse(widget.data[i].price) * qtys[i];
    }

    // Calculate discount amount
    discountPrice = (discount / 100.0) * subtotal;

    // Calculate final total
    total = subtotal - discountPrice;

    // Ensure we don't have negative values
    if (total < 0) total = 0;
    if (discountPrice < 0) discountPrice = 0;
  }

  void getQty(List<ProductModel> products) async {
    for (var i = 0; i < products.length; i++) {
      var product = products[i];
      qtys[i] = await Add2Cart.getCurrentQuantity(
          product.name, product.selectedColor);
    }
    calculateTotals(); // Calculate totals after getting quantities
    setState(() {}); // Update the UI
  }
}
