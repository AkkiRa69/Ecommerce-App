import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grid_practice/constants/app_image.dart';
import 'package:grid_practice/helpers/add_2_cart_helper.dart';
import 'package:grid_practice/helpers/wish_list_helper.dart';
import 'package:grid_practice/models/product_model.dart';
import 'package:grid_practice/routes/routes.dart';
import 'package:grid_practice/screens/buy_now/buy_now_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenDetail extends StatefulWidget {
  final ProductModel data;
  const ScreenDetail({super.key, required this.data});

  @override
  State<ScreenDetail> createState() => _ScreenDetailState();
}

class _ScreenDetailState extends State<ScreenDetail> {
  String _selectedColor = '';
  int _boxColor = 0;
  int cartCount = 0;
  bool isWishlisted = false;

  List<ProductModel> cart = [];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.data.productColors.isEmpty
        ? ""
        : widget.data.productColors[0].colorName;

    _resetWishlist().then((_) {
      _checkWishlist();
    });
    _updateCartCount();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    // final arg = ModalRoute.of(context)?.settings.arguments as ProductModel;
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: buildSliverBody(widget.data),
            ),
            buildFooter(context), //50
          ],
        ),
      ),
    );
  }

  Widget buildSliverBody(ProductModel item) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          expandedHeight: MediaQuery.of(context).size.height * 0.5,
          floating: true,
          pinned: true, // Keep the title visible when scrolled
          title: const Text(
            "Detail",
            style: TextStyle(color: Colors.black), // Contrast text color
          ),
          leading: IconButton(
            onPressed: () async {
              var wishLists = await WishListHelper.readModelsFromFile();

              Navigator.pop(context, wishLists);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          surfaceTintColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(top: 16, left: 20, right: 20),
            centerTitle: true,
            title: Hero(
              tag: item.imageUrl,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.twistingDots(
                    leftDotColor: const Color(0xFF1A1A3F),
                    rightDotColor: const Color(0xFFEA3799),
                    size: 80,
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 40),
                      SizedBox(height: 10),
                      Text("Image Not Available"),
                    ],
                  ),
                ),
              ),
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
                child: badges.Badge(
                  badgeContent: Text(cartCount.toString()),
                  child: const Icon(Icons.shopping_cart),
                ),
              ),
            )
          ],
        ),
        buildSliverDivider(),
        SliverFillRemaining(
            child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 20),
                title: Text(
                  item.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Price: ${item.priceSign + item.price}",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.red,
                  ),
                ),
                trailing: Bounceable(
                  scaleFactor: 0.5,
                  onTap: () {
                    _toggleWishlist().catchError((error) {
                      IconSnackBar.show(
                        context,
                        snackBarType: SnackBarType.fail,
                        label: 'Error updating wishlist',
                      );
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SvgPicture.asset(
                      isWishlisted ? AppImage.loveSolid : AppImage.love,
                      color: isWishlisted ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            buildSliverDivider(),
            buildSliverPickColor(
              // colors: item.productColors ?? [],
              item: item,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            buildSliverDivider(),
            buildSliverTag(item: item),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            buildSliverDivider(),
            buildSliverDescription(item),
          ],
        )),
      ],
    );
  }

  Widget buildSliverDescription(ProductModel item) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSliverDivider() {
    return SliverToBoxAdapter(
      child: Container(
        height: 10,
        color: const Color.fromARGB(26, 158, 158, 158),
      ),
    );
  }

  Widget buildSliverHeader(ProductModel item) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 300,
        child: Hero(
          tag: item.imageUrl,
          child: CachedNetworkImage(
            imageUrl: item.imageUrl,
            placeholder: (context, url) => Center(
              child: LoadingAnimationWidget.twistingDots(
                leftDotColor: const Color(0xFF1A1A3F),
                rightDotColor: const Color(0xFFEA3799),
                size: 200,
              ),
            ),
            errorWidget: (context, url, error) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error),
                SizedBox(height: 10),
                Text("No Image"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSliverPickColor({required ProductModel item}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              item.productColors.isEmpty
                  ? "Color: No Color"
                  : "Color: $_selectedColor",
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                itemCount:
                    item.productColors.isEmpty ? 2 : item.productColors.length,
                itemBuilder: (context, index) {
                  var color = item.productColors.isEmpty
                      ? '#FFFFFF'
                      : item.productColors[index].hexValue;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = item.productColors[index].colorName;

                        _boxColor = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              color
                                  .replaceFirst('#', '0xFF')
                                  .split(',')
                                  .first
                                  .replaceFirst('#', '0xFF'),
                            ),
                          ),
                          border: _boxColor == index
                              ? Border.all(
                                  color: Colors.black,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSliverTag({required ProductModel item}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Tags",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: item.tagList.isEmpty
                  ? buildTypeList("There's no tag")
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: item.tagList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return buildTypeList(item.tagList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () async {
                // // Update the cart count immediately after adding
                // final count = await Add2Cart.countItemsInCart();
                // setState(() {
                //   cartCount = count;
                // });

                await Add2Cart.addToCart(widget.data, _selectedColor, 1);
                IconSnackBar.show(
                  context,
                  snackBarType: SnackBarType.success,
                  label: 'Added to wishlist',
                );
                await _updateCartCount();
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 2,
                    color: Colors.black,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Add to Cart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return BuyNowScreen(
                        data: widget.data,
                        color: _selectedColor,
                      );
                    },
                  ),
                );
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Buy Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildTypeList(String tagList) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          tagList,
          style: const TextStyle(
            color: Color.fromARGB(189, 0, 0, 0),
          ),
        ),
      ),
    );
  }

  Future<void> _resetWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wishlist'); // Clear existing data
    await prefs.setStringList('wishlist', []); // Initialize with empty list
  }

  Future<void> _checkWishlist() async {
    var wishLists = await WishListHelper.readModelsFromFile();
    isWishlisted = wishLists.any(
      (element) => element.name == widget.data.name,
    );
    setState(() {});
  }

  Future<void> _toggleWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> wishlist = [];

      try {
        wishlist = prefs.getStringList('wishlist') ?? [];
      } catch (e) {
        await _resetWishlist();
        wishlist = [];
      }

      setState(() {
        isWishlisted = !isWishlisted;
      });

      if (isWishlisted) {
        if (!wishlist.contains(widget.data.id.toString())) {
          wishlist.add(widget.data.id.toString());
        }
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.success,
          label: 'Added to wishlist',
        );
        await WishListHelper.addModelToFile(widget.data);
      } else {
        wishlist.remove(widget.data.id.toString());
        IconSnackBar.show(
          context,
          snackBarType: SnackBarType.fail,
          label: 'Removed from wishlist',
        );
        await WishListHelper.removeModelFromFile(widget.data);
      }

      await prefs.setStringList('wishlist', wishlist);
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      IconSnackBar.show(
        context,
        snackBarType: SnackBarType.fail,
        label: 'Error updating wishlist',
      );
    }
  }

  Future<void> _loadCart() async {
    // Fetch the cart data using Add2Cart
    final cartData = await Add2Cart.readModelsFromFile();
    setState(() {
      cart = cartData;
    });
  }

  Future<void> _updateCartCount() async {
    // Fetch the cart count using Add2Cart
    final count = await Add2Cart.countItemsInCart();
    setState(() {
      cartCount = count;
    });
  }
}
