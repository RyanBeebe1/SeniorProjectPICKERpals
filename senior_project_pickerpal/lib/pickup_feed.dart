import 'package:flutter/material.dart';
import 'package:senior_project_pickerpal/backend_service.dart';
import 'package:senior_project_pickerpal/pickup_entry.dart';

class ListingFeed extends StatefulWidget {
  ListingFeed({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListingFeed createState() => _ListingFeed();
}

final List<Listing> items = [];

class _ListingFeed extends State<ListingFeed> {
  ScrollController _controller = ScrollController();
  List<int> ids = [
    4151,
    2577,
    11830,
    13237,
    4151,
    2577,
    11830,
    13237,
    4151,
    2577,
    11830,
    13237,
  ];
  bool loading = false, refreshing = false;

  Future<void> _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 3000));
    for (int id in ids) {
      BackendService.fetchListing(
              'http://services.runescape.com/m=itemdb_oldschool/api/catalogue/detail.json?item=' +
                  id.toString())
          .whenComplete(() {})
          .then((pick) {
        setState(() {
          items.add(pick);
        });
      });
    }
    refreshing = false;
    print("loadingg done.");
    return null;
  }

  Future<void> _onLoad() async {
    await Future.delayed(Duration(milliseconds: 500));
    for (int id in ids) {
      BackendService.fetchListing(
              'http://services.runescape.com/m=itemdb_oldschool/api/catalogue/detail.json?item=' +
                  id.toString())
          .whenComplete(() {})
          .then((pick) {
        setState(() {
          items.add(pick);
        });
      });
    }
    loading = false;
    print("loadingg done.");
    return null;
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _onLoad();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        setState(() {
          if (!loading) {
            loading = true;
            print("now loading");
          }
        });
      }
      if (_controller.offset <= _controller.position.minScrollExtent &&
          !_controller.position.outOfRange) {
        setState(() {
          print("reach the top");
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {
          refreshing = true;
        });
        items.clear();
        return _onRefresh();
      },
      child: ListView.separated(
          separatorBuilder: (context, ind) {
            if ((ind+1)%20==0) return ListTile(title: Center(child: Text("PAGE SOMETHING"),),);  else  return Divider(color: Colors.lightGreen,);
          },
          primary: false,
          controller: _controller,
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return ListTile(
                title: Center(child: Text("LOAD MORE")),
                onTap: () {
                  _onLoad();
                },
              );
            } else {
              final item = items[index];
              return Dismissible(
                key: Key(item.hashCode.toString()),
                onDismissed: (direction) {
                  setState(() {
                    items.removeAt(index);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () {
                            setState(() {
                              items.insert(index, item);
                            });
                          }),
                      content: Text(item.name + " dismissed"),
                    ));
                  });
                },
                background: Container(
                    child: Center(
                      child: Text("Y E E E E E E E E E E E E E T"),
                    ),
                    color: Colors.red),
                secondaryBackground: Container(
                    child: Text("Y E E E E E E E E E E E T"),
                    color: Colors.green),
                child: ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => new SimpleDialog(
                              contentPadding: EdgeInsets.all(10.0),
                              children: <Widget>[
                                Text(
                                  item.name + "  " + index.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0),
                                ),
                                Padding(padding: EdgeInsets.all(20.0)),
                                Image.network(
                                  item.icon_large,
                                  height: 100,
                                  width: 100,
                                ),
                                Padding(padding: EdgeInsets.all(20.0)),
                                Text(
                                  item.description,
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 30.0,
                                    width: 10.0,
                                    child: Text(
                                      "Ok",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.lightGreen,
                                      border: Border.all(color: Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            ),
                      );
                    },
                    leading: Image.network(item.icon),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    trailing: IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => new AlertDialog(
                                    title: Text("Chat with Seller"),
                                    content:
                                        Text("This is where the chat would be"),
                                    actions: <Widget>[
                                      Container(
                                        height: 30.0,
                                        child: RaisedButton(
                                          child: const Text(
                                            'I Understand',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          splashColor: Colors.grey,
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.lightGreen,
                                            border: Border.all(
                                                color: Colors.black)),
                                      ),
                                    ],
                                  ));
                        })),
              );
            }
          }),
    );
  }
}
