import '../components/app_drawer.dart';
import '../models/product_list.dart';
import '../utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/badge.dart';
import '../components/product_grid.dart';
import '../models/cart.dart';

enum FilterOptions {
  favorite,
  all,
}

class ProductsOverviewPage extends StatefulWidget {

  const ProductsOverviewPage({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewPage> createState() => _ProductsOverviewPageState();
}

class _ProductsOverviewPageState extends State<ProductsOverviewPage> {

  ///Variáveis
  bool _isLoading = true;
  //Precisamos ter essa variável no estado para poder configurar corretamente o CircularProgressIndicator

  bool _showFavoriteOnly = false;

  ///Métodos
  @override
  void initState() {
    super.initState();
    Provider.of<ProductList>(context, listen: false).loadProducts().then((value) {
      setState(() {
        _isLoading = false; //Depois que terminar de carregar os produtos, o loading (CircularProgressIndicator) sumir
      });
    });
    //Listen pra false já que não estamos no build
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Loja'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(value: FilterOptions.favorite, child: Text('Somente Favoritos')),
              const PopupMenuItem(value: FilterOptions.all, child: Text('Todos')),
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if(selectedValue == FilterOptions.favorite){
                  _showFavoriteOnly = true;
                } else {
                  _showFavoriteOnly = false;
                }
              });
            },
          ),
          Consumer<Cart>(
            builder: (ctx, cart, _) =>
              Badge(
                /* O ícone do botão foi envolvido com o componente criado,
                que exibe a qtde de itens no carrinho
                 */
                  value: cart.itemsCount.toString(),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.CART);
                    }, icon: const Icon(Icons.shopping_cart),
                  ),
                //Esse child no parâmetro é o child ali de cima com o ícone
              ),
          ),
        ],
      ),
      body: _isLoading ?
      const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ProductGrid(_showFavoriteOnly),
            ),
      drawer: const AppDrawer(),
    );
  }
}

