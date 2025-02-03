class ProductTypeModel {
  late String title;
  late String tag;
  late String image;

  ProductTypeModel({
    required this.title,
    required this.tag,
    required this.image,
  });

  ProductTypeModel.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? "";
    tag = json['tag'] ?? "";
    image = json['image'] ?? "";
  }
}
