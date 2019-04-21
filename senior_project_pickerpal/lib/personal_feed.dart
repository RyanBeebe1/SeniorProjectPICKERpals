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
        body: new ListingFeed(endpoint: 'http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/listingbyuser/'+SessionVariables.user.emailAddress.toString(),personalMode: true,));
  }
}

class NotificationAlert extends StatelessWidget{
  NotificationAlert({this.text});
  final String text;
  @override
  Widget build (BuildContext context){
    return new SimpleDialog(
      contentPadding: EdgeInsets.all(10.0),
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0),
          textAlign: TextAlign.center,
        ),
        Padding(padding: EdgeInsets.all(20.0)),
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Container(
            height: 30.0,
            width: 10.0,
            child: Text(
              "View",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              border: Border.all(color: Colors.black),
            ),
          ),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Container(
            height: 30.0,
            width: 10.0,
            child: Text(
              "No thanks",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            decoration: BoxDecoration(
              color: Colors.grey,
              border: Border.all(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}