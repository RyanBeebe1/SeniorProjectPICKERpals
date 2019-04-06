import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Push {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  var setState;
  BuildContext c;
  String token;
  Push(this.setState, this.c);

  var data = {'0': 'Push button to send notifcation to this device'};

  void initState() {

    _firebaseMessaging.configure(

      // Fires when notification is received while app is in the foreground
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        _neverSatisfied();

      },
      // Fires when notification is received while app is in the background
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },

      // Fires when notificatino is received while app is terminated.
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print("Token: ");
      print(token);
    });
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: c,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Curb Alert!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('New Listings are here'),
                Text('Pick what you like'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<http.Response> _sendPushNotification() async {
    // Google fcm url. Stays the same.
    var url = 'https://fcm.googleapis.com/fcm/send';

    // value of 'to' is the device message token you wish to send the message to.
    Map data = {
      'to': 'dfdtfouLPug:APA91bG49KsARkBRg9wGEl_StPFEv_dLbsgjS4BQLl3950UMn9Yz8DaYTeBK5kYUHc4niBTUFkIift7b4i0DuHdrYT_DnLllK6CqEk1PbjLBkHIgyMZm-jrXfSKGj5KKt9kVrVIlZB9-',
      'data': {'message': 'Pushed from app!'}
    };

    var body = json.encode(data);

    // Content-Type is alsways appliaction/json. Authorization is the server key from the cloud messaging console settings.
    var response = await http.post(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "key=AIzaSyCZGFNFkYQmrH-mGkvU0L1gHZSxVWAuMgY"
    }, body: body);

    print("${response.statusCode}");
    print("${response.body}");
    return response;
  }


}