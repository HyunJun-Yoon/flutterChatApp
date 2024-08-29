import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/goods_page.dart';
import 'package:flutter_application_1/pages/productDetail_page.dart';

class ProductSearchDelegate extends SearchDelegate {
  final void Function(String) onSearchQueryChanged;

  ProductSearchDelegate(this.onSearchQueryChanged);

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Search by Province, City',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          onSearchQueryChanged(value);
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Just to trigger the onSearchQueryChanged
    return Container();
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.close),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchQueryChanged(query);
        },
      ),
    ];
  }
}
