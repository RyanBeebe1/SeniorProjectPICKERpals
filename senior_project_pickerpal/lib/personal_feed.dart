import 'package:flutter/material.dart';
import 'pickup_feed.dart';
import 'session.dart';


class MyFeed extends StatefulWidget {
  MyFeed({Key key, this.feedState}) : super(key: key);
  final ListingFeedState feedState;
  @override
  MyFeedState createState() => MyFeedState();
}

class MyFeedState extends State<MyFeed> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          leading: FlatButton(onPressed: () {
            setState(() {
              widget.feedState.setState(() {
                widget.feedState.getItems().clear();
                widget.feedState.onLoad();
              });
            });
            Navigator.of(context).pop();
          }, child: Icon(Icons.close)),
          title: Text("My items"),
        ),
        body: new ListingFeed(endpoint:
        'http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/listingbyuser/'+
            SessionVariables.user.emailAddress.toString(),personalMode: true,));
  }
}