import '../components/app_drawer.dart';
import '../components/product_item.dart';
import '../utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_list.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({Key? key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext context)
  {
    return Provider.of<ProductList>(
      context,
      listen:
          false, //Listen pra false nesse caso visto que o Provider está sendo acessado dentro do método
    ).loadProducts();
  }

  @override
  Widget build(BuildContext context) {

    final ProductList products = Provider.of(context);
    //Acesso ao provider para pegar os produtos

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        //Implementação do Pull To Refresh
        onRefresh: () => _refreshProducts(context),
        child: Padding(padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: products.itemsCount,
            itemBuilder: (ctx, index) =>
                Column(
                  children: [
                    ProductItem(products.items[index]),
                    const Divider(),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
