import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grid_practice/constants/app_image.dart';
import 'package:grid_practice/helpers/wish_list_helper.dart';
import 'package:grid_practice/models/product_model.dart';
import 'package:grid_practice/routes/routes.dart';
import 'package:grid_practice/screens/detail_screen/screen_detail.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({
    super.key,
  });

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<ProductModel> wishlistItem = [];

  void _loadWishlist() async {
    final item = await WishListHelper.readModelsFromFile();
    setState(() {
      wishlistItem = item;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Widget _buildWishlistItems() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid.builder(
        // Add itemCount to prevent index out of range errors
        itemCount: wishlistItem.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          mainAxisExtent: 260,
        ),
        itemBuilder: (context, index) {
          final item = wishlistItem[index];
          return buildWislistItem(context, item);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        // controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAppBar(),
          if (wishlistItem.isEmpty)
            _buildEmptyState()
          else
            _buildWishlistItems(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 20),
            child: const Text(
              "Akk",
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 20,
            width: 1,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.search,
              );
            },
            child: Hero(
              tag: "search",
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: const Text(
                    "Search anything you want",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SvgPicture.asset(
              AppImage.cart02,
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
      surfaceTintColor: Colors.white,
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppImage.love,
              width: 64,
              height: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save items you love to your wishlist',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Bounceable buildWislistItem(BuildContext context, ProductModel item) {
    return Bounceable(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScreenDetail(
                data: item,
              ),
            ));
      },
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: item.imageUrl,
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      Text("No image"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  item.description.isEmpty
                      ? "No Description"
                      : item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text(
                      "Price: ",
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.1,
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "${item.priceSign}${item.price}",
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.1,
                          color: Colors.red,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
