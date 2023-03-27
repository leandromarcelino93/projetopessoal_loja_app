import '../components/app_drawer.dart';
import '../components/order_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_list.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<OrderList>(context, listen: false).loadOrders(),
        //o FutureBuilder é focado para trabalhar com requisições assíncronas, assim como é loadOrders
        builder: ((ctx, snapshot) {
          //o snapshot dá a possibilidade de verificar qual o status da conexão
          if (snapshot.connectionState == ConnectionState.waiting) {
            print(snapshot.error);
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return Consumer<OrderList>(
              builder: (ctx, orders, child) => ListView.builder(
                itemCount: orders.itemsCount,
                itemBuilder: (ctx, index) =>
                    OrderWidget(order: orders.items[index]),
              ),
            );
          }
        }),
      ),
    );
  }
}
