//import 'dart:js';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

//import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

//Here we will need to manage a list of items in this widget here anyways.

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "failed to fetch data .Please try again later.";
        });
      }
      //print(response.body); //In the response we are getting json data.

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData =
          json.decode(response.body); //list data will have a format of a map.

      //Now i now want to convert this back to a list of groceryItems.
      final List<GroceryItem> _loadedItems = [];
      //i'm creating a temporary list here because i then,wanna replace this list here,which we use in the overall class with this list after i parded all the loadeditems here.
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        _loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = _loadedItems;
        _isLoading = false;
      });
    } catch (err) {
      //fallback code if the error occures here
      setState(() {
        _error = "Something went wrong! Please try again later.";
      });
    }

    //final response = await http.get(url);

    //throw Exception('An error occured');//That's how you could manually throw an error.

    //print(response.statusCode);//if statues code is greater then 400 then there is a problem because all these 400 and 500 codes are error codes.
    // if (response.statusCode >= 400) {
    //   setState(() {
    //     _error = "failed to fetch data .Please try again later.";
    //   });
    // }
    // //print(response.body); //In the response we are getting json data.

    // if (response.body == 'null') {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   return;
    // }

    // final Map<String, dynamic> listData =
    //     json.decode(response.body); //list data will have a format of a map.

    // //Now i now want to convert this back to a list of groceryItems.
    // final List<GroceryItem> _loadedItems = [];
    // //i'm creating a temporary list here because i then,wanna replace this list here,which we use in the overall class with this list after i parded all the loadeditems here.
    // for (final item in listData.entries) {
    //   final category = categories.entries
    //       .firstWhere(
    //           (catItem) => catItem.value.title == item.value['category'])
    //       .value;
    //   _loadedItems.add(
    //     GroceryItem(
    //       id: item.key,
    //       name: item.value['name'],
    //       quantity: item.value['quantity'],
    //       category: category,
    //     ),
    //   );
    // }
    // setState(() {
    //   _groceryItems = _loadedItems;
    //   _isLoading = false;
    // });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );
    //Now as we are not getting any data from the new_item.dart file so we are not running these checks.
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    //Now we will have to fetch the data from the backend.

    // final url = Uri.https('');

    // final response = await http.get(url);
    // print(response);
    //_loadItems();
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //optinal:show error message
      //now we have to undo the change so by adding the item back to my list.
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text('No items added yet'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            //now i want to add an indicator for the category this
            //grocery item belongs to. i.e color in this case.
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
