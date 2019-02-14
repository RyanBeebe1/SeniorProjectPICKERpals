import 'package:flutter/material.dart';

void main() => runApp(MyApp());
int item = 0;
bool clicked = false;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PickerPAL',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: 'PickerPAL Feed'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<String> items = new List();

  void _addItem() {
    String itemnum = item.toString();
    setState(() {
      items.add(itemnum);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: new Drawer(
          child: new ListView(
            children: <Widget> [
              new DrawerHeader(
                child: new Text('Header', style: TextStyle(fontSize: 30.0),),
                decoration: BoxDecoration(color: Colors.lightGreen),),
              new ListTile(
                title: new Text('Item Feed'),
                onTap: () {},
              ),
              new ListTile(
                title: new Text('My Items'),
                onTap: () {},
              ),
              new Divider(),
              new ListTile(
                title: new Text('Settings'),
                onTap: () {},
              ),
            ],
          )
      ),
      body: Center(
      child: new ListView(
        children: items.map((String string) {
          return Container(
              decoration: new BoxDecoration(
                  border: Border.all(color: Colors.black)),
              child: ListTile(
                onTap: () {
                  showDialog(context: context,
                  builder: (_) => new SimpleDialog(
                    contentPadding: EdgeInsets.all(10.0),
                    children: <Widget>[
                      Text("Item Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),),
                      Padding(padding: EdgeInsets.all(20.0)),
                      Icon(Icons.delete, size: 100.0,),
                      Padding(padding: EdgeInsets.all(20.0)),
                      Text("Item Description: Lorem ipsum dolor sit amet, "
                          "consectetur adipiscing elit, sed do eiusmod tempor incididunt "
                          "ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis "
                          "nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo "
                          "consequat. Duis aute irure dolor in reprehenderit in voluptate velit "
                          "esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat "
                          "cupidatat non proident, sunt in culpa qui officia deserunt mollit anim "
                          "id est laborum",
                          style: TextStyle(fontSize: 15.0),),
                      SimpleDialogOption(
                        onPressed: () {Navigator.of(context).pop();},
                        child: Container(
                          height: 30.0,
                          width: 10.0,
                          child: Text("Ok",
                          style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                          textAlign: TextAlign.center,),
                          decoration: BoxDecoration(color: Colors.lightGreen,
                          border: Border.all(color: Colors.black),
                          ),
                      ),
                      )],
                  ),
                  );
                },
                leading: Icon(Icons.delete),
                title: Text("Item Name"),
                subtitle: Text("Item Description"),
                trailing: IconButton(icon: Icon(Icons.chat), onPressed: () {
                  showDialog(context: context,
                  builder: (_) => new AlertDialog(
                    title: Text("Chat with Seller"),
                    content: Text("This is where the chat would be"),
                    actions: <Widget>[
                      Container(
                        height: 30.0,
                        child: RaisedButton(
                          child: const Text('I Understand', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                          onPressed: () {Navigator.of(context).pop();},
                          splashColor: Colors.grey,

                        ),
                        decoration: BoxDecoration(color: Colors.lightGreen, border: Border.all(color: Colors.black)),
                      ),
                    ],
                  ));
                }))
          );
         }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addItem,
      tooltip: 'Add new item to feed',
      child: new Icon(Icons.add),
      ),
    );
  }
}
