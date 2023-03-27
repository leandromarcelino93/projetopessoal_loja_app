import 'cart_item.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  /* Ao invés de criar um order cart item,
  é mais fácil já utilizar o CartItem por
  possuir todas as informações necessárias
   */
  final DateTime date;

  Order(
      {required this.id,
      required this.total,
      required this.products,
      required this.date});
}

