import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: 'PickerPAL Feed'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum HomePageState {feed, map}
class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController mapController;
  HomePageState _state = HomePageState.feed;
  String drawerText = "Sign in with Google";
  String headerTxt = "Welcome Picker!";
  bool signedIn = false;
  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }
  Future<void> _handleSignOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print(error);
    }
  }

  Widget _getHomeView() {
    if (_state == HomePageState.feed) {
      return ListView(
        children: items.map((String string) {
          return Container(
              decoration:
              new BoxDecoration(border: Border.all(color: Colors.black)),
              child: ListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => new SimpleDialog(
                        contentPadding: EdgeInsets.all(10.0),
                        children: <Widget>[
                          Text(
                            "Item Name",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0),
                          ),
                          Padding(padding: EdgeInsets.all(20.0)),
                          Icon(
                            Icons.delete,
                            size: 100.0,
                          ),
                          Padding(padding: EdgeInsets.all(20.0)),
                          Text(
                            "Item Description: Lorem ipsum dolor sit amet, "
                                "consectetur adipiscing elit, sed do eiusmod tempor incididunt "
                                "ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis "
                                "nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo "
                                "consequat. Duis aute irure dolor in reprehenderit in voluptate velit "
                                "esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat "
                                "cupidatat non proident, sunt in culpa qui officia deserunt mollit anim "
                                "id est laborum",
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
                  leading: Icon(Icons.delete),
                  title: Text("Item Name"),
                  subtitle: Text("Item Description"),
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
                      })));
        }).toList(),
      );
    }
    else {
      return Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 300.0,
                height: 200.0,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: LatLng(51.5160895, -0.1294527)),
                  onMapCreated: _onMapCreated,
                ),
              ),
            ),
            RaisedButton(
              child: const Text('Go to London'),
              onPressed: mapController == null ? null : () {
                mapController.animateCamera(CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    bearing: 270.0,
                    target: LatLng(51.5160895, -0.1294527),
                    tilt: 30.0,
                    zoom: 17.0,
                  ),
                ));
              },
            ),
          ],
        ),
      );
    }
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
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
            children: <Widget>[
              new DrawerHeader(
                child: new Text(
                  headerTxt,
                  style: TextStyle(fontSize: 30.0),
                ),
                decoration: BoxDecoration(color: Colors.lightGreen),
              ),
              Visibility(
                visible: signedIn?false:true,
              child: new ListTile(
                title: new Text(drawerText),
                onTap: () {
                  _handleSignIn().whenComplete(() {
                    setState(() {
                      headerTxt = "Hello, " + _googleSignIn.currentUser.displayName;
                      signedIn = true;
                    });
                  });
                },
              ),),
              new Divider(),
              new ListTile(
                title: new Text('Item Feed'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              new Divider(),
              new ListTile(
                title: new Text('My Items'),
                onTap: () {},
              ),
              new Divider(),
              new ListTile(
                title: new Text('Settings'),
                onTap: () {
                  setState(() {
                    if (_state == HomePageState.feed)
                      _state = HomePageState.map;
                    else
                      _state = HomePageState.feed;
                    Navigator.pop(context);
                  });
                },
              ),
              new Divider(),
              Visibility(
                visible: signedIn?true:false,
              child: new ListTile(
                title: new Text('Sign Out'),
                onTap: () {
                  _handleSignOut().whenComplete(() {
                    setState(() {
                      headerTxt = "Not signed in";
                      signedIn = false;
                    });
                  });
                },
              ),),
            ],
          )),
      body: Center(
        child: _getHomeView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addItem();
          print(_googleSignIn.currentUser.email);
          print(_googleSignIn.currentUser.displayName);
        },
        tooltip: 'Add new item to feed',
        child: new Icon(Icons.add),
      ),
    );
  }
  void _onMapCreated(GoogleMapController controller) {
    setState(() { mapController = controller; });
  }
}
