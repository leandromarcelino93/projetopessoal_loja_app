import '../components/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../models/order_list.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final Cart cart = Provider.of(context);
    //Acesso ao provider

    final items = cart.items.values.toList();
    /* Precisa do values pra pegar todos os itens do carrinho
    Se deixar só ".items" ele traz o map
     */

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 25,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Chip(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    label: Text(
                      'R\$ ${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.headline6?.color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  CartButton(cart: cart),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              //Com o itemCount passamos a exibir na tela os itens selecionados pra compra
              itemBuilder: (ctx, index) => CartItemWidget(items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

///Widget extraído para controlar a lógica do botão 'COMPRAR'
/*
  Visto que não precisava transformar td o componente em Stateful para poder
  controlar a lógica desse botão comprar. O objetivo é evitar que ele mande
  pedidos duplicados. Sua ação será limitada a ter feito à apenas uma única compra.
 */

class CartButton extends StatefulWidget {
  const CartButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<CartButton> createState() => _CartButtonState();
}

class _CartButtonState extends State<CartButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : TextButton(
            onPressed: widget.cart.itemsCount == 0
                ? null
                :
                /* Condição feita para evitar que o botão comprar salve pedidos vazios.
                Se não tiver itens no carrinho, o retorno será nulo. Se tiver, ele
                prossegue com a execução dos blocos abaixo
                */
                () async {
                    setState(() => _isLoading = true);
                    //Botão de carregando começa a ser exibido

                    await Provider.of<OrderList>(context, listen: false)
                        .addOrder(widget.cart);

                    widget.cart.clear();
                    /* Quando o usuário clicar em comprar, o clear
                    vai limpar a lista com itens do carrinho. Mas isso só será feito
                    depois que tiver processado o pedido. Aqui o uso do async/await
                    é essencial para concluir o objetivo de evitar a duplicidade de pedidos.
                    */
                    setState(() => _isLoading = false);
                   //Depois que o pedido tiver sido processado, aí então o botão some
                  },
            style: TextButton.styleFrom(
                textStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            )),
            child: const Text('COMPRAR'),
          );
  }
}
