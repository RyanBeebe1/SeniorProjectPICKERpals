import 'package:flutter/material.dart';

class upload_item extends StatefulWidget {

  upload_item({Key key, this.tag}) : super(key: key);
  final String tag;
  @override
  _uploadItemState createState() => _uploadItemState();
}

class _uploadItemState extends State<upload_item> {
  String dropdownValue = null;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(onPressed: () {Navigator.of(context).pop();}, child: Icon(Icons.close)),
        title: Text("Upload Item"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(20.0)),
          Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(20.0)),
            Container(
              color: Colors.grey,
              height: 100,
              width: 100,
              child: Center(
                child: Icon(Icons.add),
              ),
            ),
            Padding(padding: EdgeInsets.all(20.0)),
              Flexible(
              child: TextField(
                maxLengthEnforced: false,
                decoration: InputDecoration(
                  hintText: 'Item Name Here'
                  )
                )
              ),
            Padding(padding: EdgeInsets.all(20.0)),
          ],
        ),
          Padding(padding: EdgeInsets.all(20.0)),
        Text("Enter Item Description: ",textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(20.0)),
            Flexible(
                child: TextField(
                  maxLengthEnforced: false,
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter Description Here'
                  ),
                )
            ),
            Padding(padding: EdgeInsets.all(20.0)),
          ],
        ),
          Padding(padding: EdgeInsets.all(20.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Tag: " + widget.tag, style: TextStyle(fontWeight: FontWeight.bold),),
              Padding(padding: EdgeInsets.all(20.0)),
              DropdownButton(
                onChanged: (value) {
                  setState(() {
                    dropdownValue = value;
                  });
                  },
                value: dropdownValue,
                items: <String>['Like New', 'Okay', 'Broken'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              hint: Text("Choose Condition"),)
            ],
          ),
          Padding(padding: EdgeInsets.all(20.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: Colors.lightGreen,
                onPressed: () {Navigator.of(context).pop();},
                child: Text("Submit"),)
            ],
          )
        ],
      ),
      ),);
  }
}