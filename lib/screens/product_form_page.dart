import '../models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  State<ProductFormPage> createState() => _ProductsFormPageState();
}

class _ProductsFormPageState extends State<ProductFormPage> {
  ///Variáveis
  final _priceFocus = FocusNode();

  final _descriptionFocus = FocusNode();

  final _imageUrlFocus = FocusNode();

  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  /* Variável para o método submitForm ter acesso ao formulário.
  Essa variável deve ser vinculada a key do Form
   */

  final _formData = Map<String, Object>();
  /* Esse map irá armazenar todas as informações digitadas pelo usuário.
  E no generics indicamos Object justamente pq não estamos trabalhando apenas
  com Strings
   */

  bool _isLoading = false;
  //Precisamos ter essa variável no estado para poder configurar corretamente o CircularProgressIndicator

  ///Métodos
  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(updateImage);
    /* Esse Listener é registrado para ficar escutando, pois sempre que
    ele ganhar o foco ou perder o foco, ele chama o updateImage
     */
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        /* Se o argumento for diferente de nulo, significa que é de uma tela
        de edição, porque se ele é diferente de nulo, significa que ele está preenchido.
         */
        final product = arg as Product;
        _formData['id'] = product.id;
        _formData['name'] = product.name;
        _formData['price'] = product.price;
        _formData['description'] = product.description;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlController.text = product.imageUrl;
        //A imagem da URL precisa ser carregada diretamente do controller
      }
    }
  }
  /* Método para carregar os dados de um produto que foi salvo. Em ProductItem
  temos o botão que nos traz de volta para essa tela, mas de nada adianta esse botão
  fazer isso se nós não carregarmos os dados. Os dados são carregados através
  do ModalRoute. E esses dados precisam ser carregados dentro do _formData,
  que é quem efetivamente armazena todas as informações digitadas pelo usuário.
   */

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.dispose();
    _imageUrlFocus.removeListener(updateImage);
  } //Método para liberar recursos

  void updateImage() {
    setState(() {});
  }
  /* Utilizamos esse método com o setState para dar um refresh na tela e
  atualizar com a imagem inserida
   */

  bool isValidImageUrl(String url) {
    bool isValidImageUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    //1ª verificação
    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg');
    //2ª verificação
    return isValidImageUrl && endsWithFile;
  }

  ///Método submitForm
  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try{
      await Provider.of<ProductList>(
          context,
          listen: false,
      ).saveProductFromData(_formData);
      //O await faz com que o código aguarde o produto ser salvo, antes de seguir para as próximas linhas
      Navigator.of(context).pop();
      /* Esse pop se faz necessário estar aqui ao invés de lá no finally,
      pois em caso de êxito ao salvar o produto, esse pop vai levar de volta para a tela da lista.
      Já em caso de erro, nós teremos uma exceção, que será tratada no bloco
      do catch. E o pop do 'Ok' leva de volta para o formulário, para que
      o usuário não perca oq estava preenchendo
       */
    } catch(error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar o produto.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),)
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
        title: const Text('Formulário de Produto'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: (_formData['name'] ?? '')?.toString(),
                      //Para carregar o campo na hora de editar
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                      ),
                      onSaved: (name) => _formData['name'] = name ?? '',
                      //Salvando no atributo 'name' do formData (que é um Map) e caso não tenha nada, fica apenas a String vazia
                      textInputAction: TextInputAction.next,
                      //Faz com que apareça a opção de ir para o próximo item do formulário
                      validator: (_name) {
                        final name = _name ?? '';
                        if (name.trim().isEmpty) {
                          return 'Nome é obrigatório.';
                        }
                        if (name.trim().length < 2) {
                          return 'Nome precisa no mínimo de 3 letras.';
                        }
                        return null;
                      },
                      /* Bloco da validação: o trim ajuda a indicar oq não é aceito
                no campo do formulário. Como visto acima, o usuário não pode
                deixar o campo de formulário vazio e nem pode preencher um nome
                de produto que tenha menos de 3 letras.
                 */
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocus);
                      },
                    ),
                    TextFormField(
                      initialValue: (_formData['price'] ?? '')?.toString(),
                      //Para carregar o campo na hora de editar
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                      ),
                      validator: (_price) {
                        final priceString = _price ?? '';
                        final price = double.tryParse(priceString) ?? -1;
                        if (price <= 0) {
                          return 'Informe um preço válido.';
                        }
                        return null;
                      },
                      onSaved: (price) =>
                          _formData['price'] = double.parse(price ?? '0'),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocus,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descriptionFocus);
                      },
                    ),
                    TextFormField(
                      initialValue:
                          (_formData['description'] ?? '')?.toString(),
                      //Para carregar o campo na hora de editar
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                      ),
                      validator: (_description) {
                        final description = _description ?? '';
                        if (description.trim().isEmpty) {
                          return 'Descrição é obrigatória.';
                        }
                        if (description.trim().length < 10) {
                          return 'Descrição precisa ter no mínimo de 10 letras.';
                        }
                        return null;
                      },
                      onSaved: (description) =>
                          _formData['description'] = description ?? '',
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocus,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4, //Aumenta o tamanho de linhas disponíveis para o campo a ser preenchido
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      //Para alinhar a linha da URL com a da imagem
                      children: [
                        Expanded(
                          //Expanded faz encaixar a linha
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'URL da imagem',
                            ),
                            validator: (_imageUrl) {
                              final imageUrl = _imageUrl ?? '';
                              if (!isValidImageUrl(imageUrl)) {
                                return 'Informe uma URL válida!';
                              }
                              return null;
                            },
                            /* Bloco da validação: Qualquer coisa que não passar pelo método isValidImageUrl,
                      então não poderá vir a ser utilizado. Será necessário informar uma URL válida.
                      */
                            onSaved: (imageUrl) =>
                                _formData['imageUrl'] = imageUrl ?? '',
                            focusNode: _imageUrlFocus,
                            controller: _imageUrlController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitForm(),
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(
                            top: 20,
                            left: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          //Para alinhar o texto da caixa da imagem (vai aparecer quando estiver vazia)
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Informe a URL')
                              : Container(
                                  width: 100,
                                  height: 100,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child:
                                        Image.network(_imageUrlController.text),
                                  ),
                                ),
                          /* O controller foi criado para que possamos ter acesso a informação da URL
                        antes do usuário salvar. E nisso criamos uma condição:
                        Se o controller estiver vazio, vamos exibir o texto padrão de informar a URL,
                        caso contrário ele exibe o FittedBox
                        */
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

