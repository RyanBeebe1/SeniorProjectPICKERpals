import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'backend_service.dart';
import 'pickup_entry.dart';
import 'personal_feed.dart';
import 'desired_items.dart';
import 'pickup_feed.dart';
import 'search_bar.dart';
import 'session.dart';
import 'fancy_fab.dart';
import 'splashScreen.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  MyHomePageState createState() => MyHomePageState();
}

enum HomePageState { feed, map, personalfeed }

class MyHomePageState extends State<MyHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  //Firebase messaging setup
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });
  }
  ListingFeed feed = new ListingFeed(
    endpoint: 'http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/listings',
    personalMode: false,
  );
  GoogleMapController mapController;
  HomePageState _state = HomePageState.feed;
  String drawerText = "Sign in with Google";
  String headerTxt = "Welcome Picker!";
  bool signedIn = false;
  
  //Firebase/Google signin, returns FirebaseUser object
  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
     FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
    String token =await _firebaseMessaging.getToken();
    User newUser = User(user.email,user.displayName,token,user.uid,0);
    SessionVariables.user = await BackendService.addUser(newUser);
    return user;
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
    } else {}
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  

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
              showSearch(context: context, delegate: SearchBar(feed.items));
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
                _handleSignIn()..whenComplete(() {
                  setState(() {
                    headerTxt =
                        "Hello, " + SessionVariables.user.displayName;
                        SessionVariables.loggedIn = true;
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
              if (SessionVariables.loggedIn) {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new MyFeed(
                            feedState: feed.state,
                          )),
                );
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(child: Text('Alert')),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Please login to view your items",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                      actions: <Widget>[
                        FlatButton(
                            child: Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })
                      ],
                    );
                  },
                );
              }
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
          new ListTile(
            title: new Text('User Page'),
            onTap: () {
              setState(() {
                if (_state == HomePageState.feed)
                  _state = HomePageState.map;
                else
                  _state = HomePageState.feed;
                Navigator.pop(context);
              });
              // trying to edit from here
              Navigator.push(
          context,
         MaterialPageRoute(builder: (context) => new DesiredItemTag(title: "Title Here")),
        );


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
      floatingActionButton: SessionVariables.loggedIn
          ? new FancyFab(
              page: this,
            )
          : null,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}

