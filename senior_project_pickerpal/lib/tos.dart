import 'package:flutter/material.dart';

class TOS extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          leading: FlatButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: Icon(Icons.close)),
          title: Text("Terms of Service"),
        ),
        body: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: new SingleChildScrollView(
          child: const Text.rich(TextSpan(text:
            "\nThe PICKERpal development team does not assume any responsibility " +
            "for users' individual experience while conducting meet-ups or item pick-ups " +
            "while using the app. All users perform these actions at their own risk.\n\n" +
            "All assets and code used to design this app, excluding pre-existing Dart and " +
            "Flutter code libraries, are property of the PICKERpal development team.\n\n" +
            "Harrassment of other users via chat, or the uploading of vulgar or deceitful " +
            "item information may result in a temporary or permanent ban from the chat and " +
            "item upload functions. The PICKERpal development team reserves the right to ban " +
            "and/or terminate accounts at their own discretion.\n\n" +
            "The PICKERpal app and the PICKERpal development team will not " +
            "give away, sell, or otherwise reveal personal information to any individual or entity " +
            "not directly affiliated with the development team. \"Personal information\" refers " +
            "to emails, usernames, passwords, user locations, chat messages, and item upload information.\n\n" +
            "By using the PICKERpal app, you agree that you are of at least 18 years of age.\n\n" +
            "The PICKERpal development team reserves the right to change these Terms of Service " +
            "whenever and however they see fit.\n\n", style: TextStyle(fontSize: 20.0),
            children: <TextSpan>[TextSpan(text:
            "Use of this app constitutes agreement to these Terms of Service.\n", style:
            TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          )
          )
        )
    );
  }
}