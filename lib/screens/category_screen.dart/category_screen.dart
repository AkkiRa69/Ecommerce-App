import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grid_practice/models/product_model.dart';
import 'package:grid_practice/screens/detail_screen/screen_detail.dart';

class CategoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> filterProduct; //products
  const CategoryScreen({super.key, required this.filterProduct});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    // final filterProduct = ModalRoute.of(context)?.settings.arguments
    //     as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Category Products"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
      ),
      body: widget.filterProduct.isEmpty
          ? const Center(
              child: Text("No products found in this category."),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(10),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: widget.filterProduct.length,
                    itemBuilder: (context, index) {
                      final item =
                          ProductModel.fromJson(widget.filterProduct[index]);
                      return _buildProductWidget(item);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProductWidget(ProductModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ScreenDetail(
                  data: item,
                );
              },
              settings: RouteSettings(
                arguments: item,
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
                    child: Container(),
                  ),
                  errorWidget: (context, url, error) => GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.error),
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
                Text(
                  "Price: ${item.priceSign + item.price}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.1,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
