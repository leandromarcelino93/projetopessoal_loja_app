import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'cart.dart';
import 'order.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class OrderList with ChangeNotifier {
  final List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }
  
  int get itemsCount{
    return _items.length;
  }

  ///  GET - Método para obter os pedidos armazenados no BD
  Future<void> loadOrders() async {
    _items.clear();
    //necessário limpar a lista antes de carregar, para evitar duplicidade da lista ao trocar de uma tela para outra
    final response = await http.get(
      Uri.parse('${Constants.orderBaseUrl}.json'),
    );
    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) //chave e valor
        {
      _items.add(
        Order(
          id: orderId,
          date: DateTime.parse(orderData['date']),
          total: orderData['total'],
          products: (orderData['products'] as List<dynamic>).map((item) {
             return CartItem(
               id: item['id'],
               productId: item['productId'],
               name: item['name'],
               quantity: item['quantity'],
               price: item['price'] ?? 0,
             );
          }).toList(),
        ),
      );
    });
    notifyListeners();
    //print(data);
  }

  /// POST - Para salvar os pedidos no BD. (Aula 288)
  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();

    final response = await http.post(
      Uri.parse('${Constants.orderBaseUrl}.json'),
      body: jsonEncode(
        {
          'total': cart.totalAmount,
          'date': date.toIso8601String(), //para salvar em um formato que facilita o processo
          'products': cart.items.values
          .map(
          (cartItem) => {
            'id': cartItem.id,
            'productId': cartItem.productId,
            'name': cartItem.name,
            'quantity': cartItem.quantity,
            'price': cartItem.price,
          },
            /* Para passar os produtos, é necessário percorrer
            os itens do carrinho. O items é um map.
            Chamamos então o método map para MAPEAR os itens do carrinho
            (cartItem) e retornamos um map com as informações necessárias
            referente aos pedidos.
             */
          ).
          toList(), //toList para que possa jogar a lista dentro do 'products' criado lá no BD
        },
      ), //conversão dos dados para formato json e envio ao BD
    );
    final id = jsonDecode(response.body)['name'];
    _items.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        date: date,
        products: cart.items.values.toList(),
      ),
    );
    notifyListeners();
  }
}
