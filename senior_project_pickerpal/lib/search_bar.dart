import 'package:flutter/material.dart';
import 'pickup_entry.dart';
import 'pickup_feed.dart';

class SearchBar extends SearchDelegate {
  final List<Listing> items;
  SearchBar(this.items);
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Listing> newList = getSubList(query);
    return ListView.builder(
        itemCount: newList.length,
        itemBuilder: (context, index) {
          final item = newList[index];
          return ListTile(
            
            title: Center(child: Text(item.item_title)),
          );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> aList = ["yoo", "hiii", "byeee"];
    return ListView.builder(
        itemCount: aList.length,
        itemBuilder: (context, index) {
          return ListTile(title: Center(child: Text(aList[index])));
        });
  }

  List<Listing> getSubList(String que) {
    List<Listing> newList = [];

    for (Listing s in items) {
      if (s.item_title.toLowerCase().contains(que)) {
        newList.add(s);
      }
    }
    return newList;
  }
}
