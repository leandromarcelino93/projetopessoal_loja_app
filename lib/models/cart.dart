import 'dart:math';
import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'product.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  //Map vazio referente aos itens do carrinho

  Map<String, CartItem> get items {
    return {..._items};
  } // Método semelhante ao que temos em ProductList para exibir clone da lista

  int get itemsCount {
    return _items.length;
  } /*
  Método que retorna qtde de itens no map
  E é esse método que ajuda a preencher o ícone de botão do carrinho
  com a qtde de itens que tem dentro do carrinho
  */

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
      //Atribuição aditiva para ir somando tudo
    });
    return total;
  } /* Método que retorna o total do carrinho. O forEach percorre o map por completo
   */

///Métodos que irão realizar algum tipo de alteração (e por isso todos com notifyListeners)
  void addItem(Product product){
    if(_items.containsKey(product.id)){
      _items.update(
        product.id,
        (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          name: existingItem.name,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
            id: Random().nextDouble().toString(),
            productId: product.id,
            name: product.name,
            quantity: 1,
            price: product.price),
      );
    }
    notifyListeners();
  } /* Método para adc um item ao carrinho. Se já estiver na lista, quando o usuário
  clicar no mesmo item, então será adicionado + 1 und daquele item. Senão,
  ele vai adicionar esse novo item. Por isso a necessidade de um outro id, sendo
  gerado randomicamente.
  */

  void removeItem (String productId){
    _items.remove(productId);
    notifyListeners();
  }
  //Método para remover item do carrinho

  void removeSingleItem(String productId) {
    if(!_items.containsKey(productId)){
      return;
    }
    if(_items[productId]?.quantity == 1){
      _items.remove(productId);
    } else {
      _items.update(
        productId,
            (existingItem) => CartItem(
          id: existingItem.id,
          productId: existingItem.productId,
          name: existingItem.name,
          quantity: existingItem.quantity - 1,
          //Aqui ao invés de adc, nós subtraímos!
          price: existingItem.price,
        ),
      );
    }
    notifyListeners();
  }
  /* Método para remover APENAS uma und do item do carrinho,
  e não todos igual o método logo acima. Explicação:

  - 1ª verificação:
    Se esse resultado for falso (!), ou seja, não contém a chave,
    significa que podemos simplesmente sair (return) e não precisa
    executar mais nada porque o produto não está dentro da lista de
    produtos.

  - 2ª verificção:
    Vamos procurar um elemento pela chave. Caso não encontre (?), vamos
    procurar pela quantidade. E se a qtde for igual a 1, significa que nesse
    cenário podemos excluir o item inteiro.

    Caso contrário, então a qtde é maior do que 1 e aí utilizamos a mesma
    estratégia que foi utilizada praquele lance de atualizar as qtdes.
    A diferença é que agora ao invés de adicionar, passamos então a subtrair.
  */

  void clear () {
    _items = {};
    notifyListeners();
  }
  //Método para limpar a lista toda
}

