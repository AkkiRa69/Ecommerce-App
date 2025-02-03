import 'dart:convert';
import 'dart:io';

import 'package:grid_practice/models/product_model.dart';
import 'package:path_provider/path_provider.dart';

class WishListHelper {
  WishListHelper._();

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/wishlist2.json');
  }

  static Future<List<ProductModel>> readModelsFromFile() async {
    final file = await _getFile(); //open file

    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        List<dynamic> jsonData = jsonDecode(content);
        return jsonData.map((item) => ProductModel.fromJson(item)).toList();
      }
    }
    return [];
  }

  static Future<void> addModelToFile(ProductModel newModel) async {
    List<ProductModel> models = await readModelsFromFile(); //read existing data

    models.add(newModel); //add new data

    List<Map<String, dynamic>> jsonData = models.map((data) {
      return {
        'name': data.name,
        'description': data.description,
        'price': data.price,
        'api_featured_image': data.imageUrl,
        'price_sign': data.priceSign,
        'tag_list': data.tagList,
        'product_type': data.productType,
        'product_colors': data.productColors.map((color) {
          return {
            'hex_value': color.hexValue,
            'colour_name': color.colorName,
          };
        }).toList(),
      };
    }).toList();

    final file = await _getFile(); //open file
    await file.writeAsString(jsonEncode(jsonData)); //write data to file
  }

  static Future<void> removeModelFromFile(ProductModel modelToRemove) async {
    List<ProductModel> models = await readModelsFromFile();

    models.removeWhere((model) => model.name == modelToRemove.name);
    List<Map<String, dynamic>> jsonData = models.map((model) {
      return {
        'name': model.name,
        'description': model.description,
        'price': model.price,
        'api_featured_image': model.imageUrl,
        'price_sign': model.priceSign,
        'tag_list': model.tagList,
        'product_type': model.productType,
        'product_colors': model.productColors.map((color) {
          return {
            'hex_value': color.hexValue,
            'colour_name': color.colorName,
          };
        }).toList(),
      };
    }).toList();

    final file = await _getFile();
    await file.writeAsString(jsonEncode(jsonData));
  }
}
