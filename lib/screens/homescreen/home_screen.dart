import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grid_practice/constants/app_image.dart';
import 'package:grid_practice/ds/product.dart';
import 'package:grid_practice/ds/product_type.dart';
import 'package:grid_practice/ds/slide.dart';
import 'package:grid_practice/models/product_model.dart';
import 'package:grid_practice/models/product_type_model.dart';
import 'package:grid_practice/routes/routes.dart';
import 'package:grid_practice/screens/category_screen.dart/category_screen.dart';
import 'package:grid_practice/screens/detail_screen/screen_detail.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductTypeModel> productTypes = [];

  List<Map<String, dynamic>> searchProduct = [];
  var searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchProduct = products;
    _loadProductTypes();
  }

  List<Map<String, dynamic>> filterProductsByCategory(String category) {
    return products
        .where((product) =>
            product["product_type"].toLowerCase() == category.toLowerCase())
        .toList();
  }

  void _loadProductTypes() {
    setState(() {
      productTypes = productType
          .map((productTypeJson) => ProductTypeModel.fromJson(productTypeJson))
          .toList();
    });
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            buildAppBar(context),
            _buildSliverProTypeList(),
            SliverToBoxAdapter(
              child: Container(
                height: 10,
                color: const Color.fromARGB(88, 158, 158, 158),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Text(
                  "All Product",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildSliverListAllPro(),
          ],
        ),
      ),
    );
  }

  SliverAppBar buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
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
            child: Bounceable(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.cart,
                );
              },
              child: SvgPicture.asset(
                AppImage.cart02,
                width: 30,
                height: 30,
              ),
            ),
          ),
        ],
      ),
      surfaceTintColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildSliverHeader(),
      ),
    );
  }

  Widget _buildSliverListAllPro() {
    return SliverGrid.builder(
      itemCount: searchProduct.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 260,
      ),
      itemBuilder: (context, index) {
        var item = ProductModel.fromJson(searchProduct[index]);
        return _buildProductWidget(item, isDis: item.productType == "blush");
      },
    );
  }

  Widget _buildProductWidget(ProductModel item, {bool isDis = false}) {
    return GestureDetector(
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
        // crossAxisAlignment: CrossAxisAlignment.start,
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
                  placeholder: (context, url) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: _buildPlaceholder(),
                  ),
                  errorWidget: (context, url, error) => GestureDetector(
                    onTap: () {},
                    child: const Column(
                      children: [
                        Icon(Icons.error),
                        Text("No image"),
                      ],
                    ),
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
                  item.description == "" ? "No Description" : item.description,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.1,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      item.priceSign + item.price,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.1,
                        color: Colors.red,
                        decoration: isDis ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    isDis
                        ? Text(
                            " ${item.priceSign}30",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.1,
                              color: Colors.red,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverProTypeList() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Product Type",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: productType.isEmpty
                ? _buildPlaceholder()
                : ListView.separated(
                    padding: const EdgeInsets.only(left: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: productType.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      var productTypes =
                          ProductTypeModel.fromJson(productType[index]);
                      return _buildTypeList(productTypes);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeList(ProductTypeModel item) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  filterProduct: products
                      .where((pro) =>
                          pro["product_type"].toLowerCase() ==
                          item.tag.replaceFirst(" ", "_").toLowerCase())
                      .toList(),
                ),
              ),
            );
          },
          child: SizedBox(
            width: 70,
            height: 70,
            child: SvgPicture.network(
              item.image,
              fit: BoxFit.fitHeight,
              placeholderBuilder: (context) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          item.title,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(148, 158, 158, 158),
      highlightColor: Colors.grey.shade300,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        // height: 64,
      ),
    );
  }

  Widget _buildSliverHeader() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            height: 250.0,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayCurve: Curves.easeOutQuad,
          ),
          items: [0, 1, 2].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: CachedNetworkImage(
                    imageUrl: slidesCarousel[i],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 10,
          child: AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: 3,
            effect: const ExpandingDotsEffect(
              dotWidth: 10,
              dotHeight: 10,
            ),
          ),
        )
      ],
    );
  }
}
