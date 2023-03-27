import 'dart:convert';
import 'dart:math';
import '../exceptions/http_exceptions.dart';
import '../models/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ProductList with ChangeNotifier {

  final List<Product> _items = [];

  ///Implementação do filtro

  List<Product> get items => [..._items];
  //Método para exibir o clone de todos os itens

  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();
  //Método para exibir o clone apenas dos itens favoritados

  int get itemsCount {
    return _items.length;
  }
  //Método que retorna qtde de itens

  ///  GET - Método para obter os produtos armazenados no BD
  Future<void> loadProducts() async {
    _items.clear();
    //necessário limpar a lista antes de carregar, para evitar duplicidade da lista ao trocar de uma tela para outra

    final response = await http.get(
      Uri.parse('${Constants.productBaseUrl}.json'),
    );
    print(jsonDecode(response.body));
    if (response.body == 'null') return;

    Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach((productId, productData) //chave e valor
    {
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite'],
          //pegando os elementos a partir da chave
        ),
      );
    });
    notifyListeners(); // a lista será alterada, portanto, precisaremos do notifyListeners
  }

  ///
  Future<void> saveProductFromData(Map<String, Object> data) {
    bool hasId = data['id'] != null;
    //Verificação se o id está nulo

    final newProduct = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      //Se tiver id, irá considerá-lo. Caso não, um id será gerado
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(newProduct);
    } else {
      return addProduct(newProduct);
    }
  }

  /// POST
  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${Constants.productBaseUrl}.json'),
      body: jsonEncode(
        {
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        },
      ), //conversão dos dados para formato json e envio ao BD
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(
      Product(
        id: id,
        name: product.name,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      ),
    );
    notifyListeners();
  }

  /// PATCH
  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      await http.patch(
        Uri.parse('${Constants.productBaseUrl}/${product.id}.json'), //${product.id} é necessário pq precisa do id pra poder atualizar
        body: jsonEncode(
          {
            "name": product.name,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
            //"isFavorite": product.isFavorite, isFavorite faz parte do contexto da página da loja. E não de gerenc. de produtos
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  /// DELETE
  Future<void> deleteProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners(); //1º fazemos a exclusão local

      final response = await http.delete(
        Uri.parse('${Constants.productBaseUrl}/${product.id}.json'),
      ); //Depois solicitamos a exclusão lá no BD e o mesmo manda uma resposta de volta

      if(response.statusCode >= 400){
        /* Se o status da resposta for de número >= a 400,
        então significa que houve um erro.
         */
        _items.insert(index, product);
        /* E em caso de erro o item será restaurado na lista através do método insert,
        passando o index e o product como parâmetro
         */
        notifyListeners();
        throw HttpExceptions(
          msg: 'Não foi possível excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    }
  }
}

