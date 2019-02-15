import 'package:flutter/material.dart';
import 'package:senior_project_pickerpal/model/Items.dart';
import 'package:senior_project_pickerpal/service/firebase_firestore_service.dart';

class ItemsScreen extends StatefulWidget {
  final Items item;
  ItemsScreen(this.item);

  @override
  State<StatefulWidget> createState() => new _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  FirebaseFirestoreService db = new FirebaseFirestoreService();

  TextEditingController _titleController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _titleController = new TextEditingController(text: widget.item.item);
    _descriptionController = new TextEditingController(text: widget.item.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Items')),
      body: Container(
        margin: EdgeInsets.all(15.0),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            Padding(padding: new EdgeInsets.all(5.0)),
            RaisedButton(
              child: (widget.item.id != null) ? Text('Update') : Text('Add'),
              onPressed: () {
                if (widget.item.id != null) {
                  db
                      .updateItems(
                          Items(widget.item.id, _titleController.text, _descriptionController.text))
                      .then((_) {
                    Navigator.pop(context);
                  });
                } else {
                  db.createItems(_titleController.text, _descriptionController.text).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}