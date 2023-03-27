import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  /// PATCH - Para atualização dos produtos favoritados.
  Future<void> toggleFavorite() async {
    try{
      _toggleFavorite(); //1º Estamos marcando como favorito

    final response = await http.patch(
      Uri.parse('${Constants.productBaseUrl}/$id.json'),
      body: jsonEncode({"isFavorite": isFavorite}),
    ); //E depois tentamos marcar no servidor

    if(response.statusCode >= 400){
      _toggleFavorite();
      notifyListeners();
      //Se der erro, então restauramos a marcação do modo como estava anteriormente
      }
    }
    catch (_) {
      _toggleFavorite();
      notifyListeners();
    }
  }
}

