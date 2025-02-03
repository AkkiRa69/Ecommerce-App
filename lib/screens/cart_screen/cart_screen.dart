import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grid_practice/constants/app_image.dart';
import 'package:grid_practice/helpers/add_2_cart_helper.dart';
import 'package:grid_practice/models/product_model.dart';
import 'package:grid_practice/screens/buy_now/buy_now_screen_2.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<ProductModel> cartItem = [];
  List<int> selectedItems = [];
  List<ProductModel> selectedProducts = [];
  double total = 0;
  int totalQty = 0;

  void loadCartItem() async {
    var item = await Add2Cart.readModelsFromFile();
    setState(() {
      cartItem = item;
    });
  }

  void calculateTotal() async {
    double newTotal = 0.0;
    for (var product in selectedProducts) {
      int productQty = await Add2Cart.getCurrentQuantity(
          product.name, product.selectedColor);
      newTotal += double.parse(product.price) * productQty;
    }
    setState(() {
      total = newTotal;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCartItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Add2Cart.clearCart();
              loadCartItem();
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: cartItem.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 100,
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  const Text("No Products available in cart"),
                  const SizedBox(
                    height: 8,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var item = cartItem[index];
                        return _buildSliverProduct(item, index);
                      },
                      itemCount: cartItem.length,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "USD \$${total.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("${selectedItems.length} Items"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(),
                            ),
                            onPressed: () {
                              pushToBuyNow();
                            },
                            child: const Text("CHECKOUT"),
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

  Widget _buildSliverProduct(ProductModel product, int index) {
    return Bounceable(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
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
                  tag: product.imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Bounceable(
                            onTap: () async {
                              setState(() {
                                if (selectedItems.contains(index)) {
                                  selectedItems.remove(index);
                                } else {
                                  selectedItems.add(index);
                                }
                                selectedProducts = selectedItems
                                    .map((e) => cartItem[e])
                                    .toList();
                              });
                              calculateTotal();
                            },
                            child: SvgPicture.asset(
                              height: 25,
                              selectedItems.contains(index)
                                  ? AppImage.selected
                                  : AppImage.unselect,
                            ),
                          ),
                        ],
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
                      _buildQtyBtn(product),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(ProductModel product) {
    return Row(
      children: [
        const Spacer(),
        Bounceable(
          onTap: () async {
            await Add2Cart.updateQuantity(
                product, product.selectedColor, false);
            calculateTotal();
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
            child: FutureBuilder<int>(
              future: Add2Cart.getCurrentQuantity(
                  product.name, product.selectedColor),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('${snapshot.data}');
                }
                return const Text('1');
              },
            ),
          ),
        ),
        Bounceable(
          onTap: () async {
            await Add2Cart.updateQuantity(product, product.selectedColor, true);
            calculateTotal();
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
    );
  }

  void pushToBuyNow() {
    if (selectedProducts.isEmpty) {
      selectedProducts = cartItem;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyNowScreen2(
          data: selectedProducts,
        ),
      ),
    );
  }
}
