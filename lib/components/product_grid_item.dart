import '../utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';
import '../models/product.dart';

class ProductGridItem extends StatelessWidget {
  const ProductGridItem({super.key});

  @override
  Widget build(BuildContext context) {

    final product = Provider.of<Product>(context, listen: false);
    //Acesso para receber Product (esse model está dentro de ProductList) via provider
    //listen como false para não ficar escutando todas as mudanças na tela

    final cart = Provider.of<Cart>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        // ignore: sort_child_properties_last
        child: GestureDetector(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.PRODUCT_DETAIL,
              arguments: product,
            );
          },
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            /*
            Consumer é utilizado para pontos específicos que irão mudar alguma coisa na tela
            quando vc marca o listen como false
             */
            builder: (ctx, product, _) => IconButton(
              onPressed: () {
                product.toggleFavorite();
                //quando o usuário clicar, o método para favoritar será chamado
              },
              icon: Icon(
                //Lógica para alternância (animação) do botão de favoritar
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product);
              //graças ao Provider temos acesso a esse método para adicionar um produto
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //assim não fica subindo um monte de snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Produto adicionado com sucesso!'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'DESFAZER',
                    onPressed: (){
                      cart.removeSingleItem(product.id);
                    }
                  ),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}

