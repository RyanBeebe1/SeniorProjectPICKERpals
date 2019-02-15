class Items{
  String _item;
  String _description;
  String _id;

  Items(this._id, this._item, this._description);

  Items.map(dynamic obj) {
    this._id = obj['id'];
    this._item = obj['Item'];
    this._description = obj['description'];
  }

  String get id => _id;
  String get item => _item;
  String get description => _description;

  Map<String, dynamic> toMap(){
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['Item'] = _item;
    map['description'] = _description;

    return map;
  }
Items.fromMap(Map<String, dynamic> map){
  this._item = map['Item'];
  this._description = map['description'];
}

}