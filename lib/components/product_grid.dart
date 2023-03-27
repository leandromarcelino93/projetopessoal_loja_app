import '../components/product_grid_item.dart';
import '../models/product_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';

class ProductGrid extends StatelessWidget {

  final bool showFavoriteOnly;
  /* Recebendo a informação do Estado via construtor
  e armazenando nesta variável
   */

  const ProductGrid(this.showFavoriteOnly, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final provider = Provider.of<ProductList>(context);
    //Acesso para receber ProductList via provider

    final List<Product> loadedProducts =
        showFavoriteOnly ? provider.favoriteItems : provider.items;

    return GridView.builder(
      itemCount: loadedProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) =>
          ChangeNotifierProvider.value(
            /* Esse ChangeNotifierProvider que receberá a
            notificação referente o product.toggleFavorite();
            que está lá no botão de favoritar. E ele vai
            repassar a ProductItem qual elemento deverá ser
            reescrito ou não.
             */
            value: loadedProducts[index],
            child: const ProductGridItem(),
      ),
    );
  }
}

