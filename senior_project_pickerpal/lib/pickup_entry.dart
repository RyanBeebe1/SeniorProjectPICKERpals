
class Listing {

  final String icon;
  final int id;
  final String name;
  final String description;
  final String icon_large;

  Listing(this.icon,this.id,this.name,this.description,this.icon_large);
  factory Listing.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map = json['item'];
    return Listing(
         map['icon'],
        map['id'],
       map['name'],
        map['description'],
      map['icon_large']
    );
  }

  static List<Listing> fromJsonList(jsonList) {
    return jsonList.map<Listing>((obj) => Listing.fromJson(obj)).toList();
  }

}