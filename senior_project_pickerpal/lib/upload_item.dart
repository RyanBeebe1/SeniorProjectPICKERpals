import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:senior_project_pickerpal/backend_service.dart';
import 'package:senior_project_pickerpal/pickup_entry.dart';
class upload_item extends StatefulWidget {
  upload_item({Key key, this.tag}) : super(key: key);
  final String tag;
  @override
  _uploadItemState createState() => _uploadItemState();
}

class _uploadItemState extends State<upload_item> {
  File _image;
  String dropdownValue = null;
  String _longLat, _date;
  TextEditingController _titleController, _descController;


  String _getDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  @override
  void initState() {
    super.initState();
    _titleController = new TextEditingController();
    _descController = new TextEditingController();

  }

  Future getImage() async {
    var image;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Choose image"),
          children: <Widget>[
            SimpleDialogOption(onPressed: () async {
              image = await ImagePicker.pickImage(source: ImageSource.camera);
              setState(() {
                _image = image;
                Navigator.of(context).pop();
              });
            },
              child: Text("Take Photo"),),
            SimpleDialogOption(onPressed: () async {
              image = await ImagePicker.pickImage(source: ImageSource.gallery);
              setState(() {
                _image = image;
                Navigator.of(context).pop();
              });
            },
              child: Text("Choose Photo"),)
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(onPressed: () {Navigator.of(context).pop();}, child: Icon(Icons.close)),
        title: Text("Upload Item"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add_a_photo), onPressed: (){getImage();})
        ],
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
                    color: _image == null?Colors.grey:Colors.transparent,
                    height: 100,
                    width: 100,
                    child: Center(
                      child: _image == null?Text("No Image Selected", textAlign: TextAlign.center,):Image.file(_image),
                    )
                ),
                Padding(padding: EdgeInsets.all(20.0)),
                Flexible(
                    child: TextField(
                        controller: _titleController,
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
                      controller: _descController,
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
                  onPressed: () {

                    Listing l = new Listing(_descController.text, "myemail@email.com", _titleController.text, "10.0,10.0", widget.tag, "08080", dropdownValue, _getDate());
                    BackendService.createListing(l);


                    Navigator.of(context).pop();
                  },
                  child: Text("Submit"),)
              ],
            )
          ],
        ),
      ),);
  }
}