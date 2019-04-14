import 'pickup_entry.dart';
import 'package:flutter/material.dart';
class SessionVariables {


  static String loggedInEmail;
  static bool loggedIn = false;
  static User user;

 static void loggedInDialogue(BuildContext context,String msg) {
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
                              msg,
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
  
}