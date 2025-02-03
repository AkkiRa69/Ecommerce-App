// class ProductModel {
//   late String name;
//   late String description;
//   late String price;
//   late String imageUrl;
//   late String priceSign;

//   late List<String> tagList;
//   late String productType;
//   late String currency;

//   late List<ProductColor> productColors;

//   ProductModel({
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.imageUrl,
//     required this.priceSign,
//     required this.productColors,
//     required this.tagList,
//     required this.productType,
//     required this.currency,
//   });

//   ProductModel.fromJson(Map<String, dynamic> data) {
//     name = data['name'] ?? "";
//     description = data['description'] ?? "NO DESCRIPTION";
//     price = data['price'] ?? 0.0;
//     // imageUrl = "https:${data['api_featured_image']}";
//     imageUrl = data['api_featured_image'].startsWith("http")
//         ? data['api_featured_image']
//         : "https:${data['api_featured_image']}";
//     priceSign = data['price_sign'] ?? "";

//     tagList = (data['tag_list'] as List).map((e) {
//       return e.toString();
//     }).toList();

//     productType = data['product_type'] ?? "";
//     currency = data['currency'] ?? "";

//     productColors = (data['product_colors'] as List).map((e) {
//       return ProductColor.fromJson(e);
//     }).toList();
//   }
// }

// class ProductColor {
//   late String hexValue;
//   late String colorName;

//   ProductColor({
//     required this.hexValue,
//     required this.colorName,
//   });

//   ProductColor.fromJson(Map<String, dynamic> data) {
//     hexValue = data['hex_value'] ?? "";
//     colorName = data['colour_name'] ?? "";
//   }
// }

class ProductModel {
  int id;
  String name;
  String description;
  String price;
  String imageUrl;
  String priceSign;

  List<String> tagList;
  String productType;
  String currency;

  String selectedColor;
  int quantity;

  List<ProductColor> productColors;

  ProductModel({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.priceSign,
    required this.productColors,
    required this.tagList,
    required this.productType,
    required this.currency,
    required this.id,
    required this.selectedColor,
    required this.quantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      description: data['description'] ?? 'NO DESCRIPTION',
      price: data['price']?.toString() ?? '',
      priceSign: data['price_sign'] ?? "",
      tagList: (data['tag_list'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      productType: data['product_type'] ?? '',
      currency: data['currency'] ?? '',
      productColors: (data['product_colors'] as List<dynamic>?)
              ?.map((e) => ProductColor.fromJson(e))
              .toList() ??
          [],
      selectedColor: data['selected_color'] ?? '',
      quantity: data['quantity'] ?? 0,
      imageUrl: (data['api_featured_image']?.startsWith("http") ?? false)
          ? data['api_featured_image']
          : "https:${data['api_featured_image'] ?? ""}",
    );
  }
}

class ProductColor {
  final String hexValue;
  final String colorName;

  ProductColor({
    required this.hexValue,
    required this.colorName,
  });

  factory ProductColor.fromJson(Map<String, dynamic> data) {
    return ProductColor(
      hexValue: data['hex_value'] ?? '',
      colorName: data['colour_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hex_value': hexValue,
      'colour_name': colorName,
    };
  }
}
