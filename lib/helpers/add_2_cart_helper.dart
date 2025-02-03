import 'dart:convert';
import 'dart:io';

import 'package:grid_practice/models/product_model.dart';
import 'package:path_provider/path_provider.dart';

class Add2Cart {
  Add2Cart._();

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/cart5.json');
  }

  static Future<List<Map<String, dynamic>>> _readRawData() async {
    final file = await _getFile();

    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        return jsonDecode(content).cast<Map<String, dynamic>>();
      }
    }
    return [];
  }

  static Future<List<ProductModel>> readModelsFromFile() async {
    final rawData = await _readRawData();

    return rawData.map((item) {
      ProductModel model = ProductModel.fromJson(item);
      model.selectedColor = item['selected_color'];
      model.quantity = item['quantity'];
      return model;
    }).toList();
  }

  static Future<void> addToCart(
      ProductModel newModel, String selectedColor, int qty) async {
    final rawData = await _readRawData();

    final existingIndex = rawData.indexWhere((item) =>
        item['name'] == newModel.name &&
        item['selected_color'] == selectedColor);

    if (existingIndex != -1) {
      rawData[existingIndex]['quantity'] += qty;
    } else {
      rawData.add({
        'name': newModel.name,
        'description': newModel.description,
        'price': newModel.price,
        'api_featured_image': newModel.imageUrl,
        'price_sign': newModel.priceSign,
        'tag_list': newModel.tagList,
        'product_type': newModel.productType,
        'product_colors': newModel.productColors.map((color) {
          return {
            'hex_value': color.hexValue,
            'colour_name': color.colorName,
          };
        }).toList(),
        'selected_color': selectedColor,
        'quantity': qty,
      });
    }

    final file = await _getFile();
    await file.writeAsString(jsonEncode(rawData));
  }

  static Future<void> removeFromCart(
      ProductModel modelToRemove, String selectedColor) async {
    final rawData = await _readRawData();

    rawData.removeWhere((item) =>
        item['name'] == modelToRemove.name &&
        item['selected_color'] == selectedColor);

    final file = await _getFile();
    await file.writeAsString(jsonEncode(rawData));
  }

  static Future<int> countItemsInCart() async {
    List<ProductModel> models = await readModelsFromFile();
    return models.length;
  }

  static Future<void> clearCart() async {
    final file = await _getFile();
    await file.writeAsString('[]'); // Write empty array to file
  }

  static Future<void> updateQuantity(
      ProductModel model, String selectedColor, bool increase) async {
    final rawData = await _readRawData();

    final existingIndex = rawData.indexWhere((item) =>
        item['name'] == model.name && item['selected_color'] == selectedColor);

    if (existingIndex != -1) {
      if (increase) {
        rawData[existingIndex]['quantity']++;
      } else {
        // Don't decrease if quantity is already 1
        if (rawData[existingIndex]['quantity'] > 1) {
          rawData[existingIndex]['quantity']--;
        }
      }

      final file = await _getFile();
      await file.writeAsString(jsonEncode(rawData));
    }
  }

// Helper function to get current quantity
  static Future<int> getCurrentQuantity(
      String productName, String selectedColor) async {
    final rawData = await _readRawData();

    final existingItem = rawData.firstWhere(
      (item) =>
          item['name'] == productName &&
          item['selected_color'] == selectedColor,
      orElse: () => {'quantity': 0},
    );

    return existingItem['quantity'] ?? 0;
  }
}
