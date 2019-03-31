import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:senior_project_pickerpal/personal_feed.dart';
import 'package:senior_project_pickerpal/pickup_feed.dart';
import 'package:senior_project_pickerpal/search_bar.dart';
import 'package:senior_project_pickerpal/session.dart';
import 'fancy_fab.dart';
import 'splashScreen.dart';

void main() => runApp(MyApp());
int item = 0;
bool clicked = false;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:
          ThemeData(primaryColor: Colors.lightGreen, accentColor: Colors.green),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum HomePageState { feed, map,personalfeed }

class _MyHomePageState extends State<MyHomePage> {
  ListingFeed feed = new ListingFeed(endpoint: 'http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/listings');
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
      return feed;
    } else {
      return MyFeed();

    }
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  List<String> items = new List();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SearchBar());
            },
          )
        ],
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
            visible: SessionVariables.loggedIn ? false : true,
            child: new ListTile(
              title: new Text(drawerText),
              onTap: () {
                _handleSignIn().whenComplete(() {
                  setState(() {
                    headerTxt =
                        "Hello, " + _googleSignIn.currentUser.displayName;
                    SessionVariables.loggedIn = true;
                    SessionVariables.loggedInEmail = _googleSignIn.currentUser.email;
                  });
                });
              },
            ),
          ),
          new Divider(),
          new ListTile(
            title: new Text('Item Feed'),
            onTap: () {
              setState(() {
                _state = HomePageState.feed;
                Navigator.pop(context);
              });
            },
          ),
          new Divider(),
          new ListTile(
            title: new Text('My Items'),
            onTap: () {
              feed = null;
              Navigator.push(context, new MaterialPageRoute(builder: (context) => new MyFeed()),
              );
            },
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
            visible: SessionVariables.loggedIn ? true : false,
            child: new ListTile(
              title: new Text('Sign Out'),
              onTap: () {
                _handleSignOut().whenComplete(() {
                  setState(() {
                    headerTxt = "Not signed in";
                    SessionVariables.loggedIn = false;
                    SessionVariables.loggedInEmail = null;
                  });
                });
              },
            ),
          ),
        ],
      )),
      body: Center(
        child: _getHomeView(),
      ),
      floatingActionButton: SessionVariables.loggedIn ? new FancyFab() : null,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
