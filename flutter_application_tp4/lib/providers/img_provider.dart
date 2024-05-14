import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/img_model.dart';

class ImageProvider extends ChangeNotifier {
  List<ImageModel> _images = [];

  List<ImageModel> get images => _images;

  Future<void> fetchImages() async {
    final response = await http.get(Uri.parse('https://picsum.photos/v2/list?page=1&limit=10'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _images = data
          .map<ImageModel>(
              (img) => ImageModel(id: img['id'], description: "Gambar dari Picsum", source: img['download_url']))
          .toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load images');
    }
  }

  void addImage(ImageModel image) {
    _images.add(image);
    notifyListeners();
  }

  void editImage(String id, String description, String source) {
    final image = _images.firstWhere((img) => img.id == id);
    image.description = description;
    image.source = source;
    notifyListeners();
  }
}