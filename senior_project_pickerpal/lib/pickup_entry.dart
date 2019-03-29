import 'dart:convert';
class Listing {

  final String description;
  final String user_id;
  final String item_title;
  final String location;
  final String tag;
  final String zipcode;
  final String cond;
  final String listing_date;



  Listing(this.description,this.user_id,this.item_title,this.location,this.tag, this.zipcode, this.cond, this.listing_date);
  
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      json['description'],
      json['userid'],
      json['title'],
      json['location'],
      json['tag'],
      json['zipcode'],
      json['condition'],
      json['date']
    );
  }

  static List<Listing> fromJsonList(jsonList) {
    return jsonList.map<Listing>((obj) => Listing.fromJson(obj)).toList();
  }

  static Map<String, dynamic> toJson(Listing l) => {
    "description" : l.description,
    "title":l.item_title,
    "userid":l.user_id,
    "location":l.location,
    "tag":l.tag,
    "zipcode":l.zipcode,
    "date":l.listing_date,
    "condition":l.cond
};
}