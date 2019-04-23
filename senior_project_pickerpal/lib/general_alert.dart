import 'package:flutter/material.dart';

class GeneralAlert extends StatelessWidget{
  GeneralAlert({this.text, this.positive, this.negative});
  final String text;
  final String positive;
  final String negative;
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
              positive,
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
              negative,
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