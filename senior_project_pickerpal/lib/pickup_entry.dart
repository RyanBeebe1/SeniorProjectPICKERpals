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
  final dynamic listing_id;



  Listing(this.description,this.user_id,this.item_title,this.location,this.tag, this.zipcode, this.cond, this.listing_date,this.listing_id);

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
        json['description'],
        json['userid'],
        json['title'],
        json['location'],
        json['tag'],
        json['zipcode'],
        json['condition'],
        json['date'],
        json['listingid']
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
    "condition":l.cond,
    "listingid" :l.listing_id
  };
}
class UploadListing {

  final String description;
  final String user_id;
  final String item_title;
  final String location;
  final String tag;
  final String zipcode;
  final String cond;
  final String listing_date;




  UploadListing(this.description,this.user_id,this.item_title,this.location,this.tag, this.zipcode, this.cond, this.listing_date);

  factory UploadListing.fromJson(Map<String, dynamic> json) {
    return UploadListing(
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

  static List<UploadListing> fromJsonList(jsonList) {
    return jsonList.map<UploadListing>((obj) => UploadListing.fromJson(obj)).toList();
  }

  static Map<String, dynamic> toJson(UploadListing l) => {
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

class User {
  final String usersId;
  final String overallRating;
  final String emailAddress;

  User(this.usersId,this.overallRating,this.emailAddress);
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        json['users_id'],
        json['overall_rating'],
        json['email_address']
    );
  }

  static Map<String,dynamic> toJson(User user) => {
    'users_id' : user.usersId,
    'overall_rating':user.overallRating,
    'email_address':user.emailAddress
  };

}


class DesiredItem {
  final String desiredItemId;
  final String userId;
  final String keyword;

  DesiredItem(this.desiredItemId,this.userId,this.keyword);
  factory DesiredItem.fromJson(Map<String, dynamic> json) {
    return DesiredItem(
        json['desired_item_id'],
        json['user_id'],
        json['keyword']
    );
  }

  static List<DesiredItem> fromJsonList(jsonList) {
    return jsonList.map<DesiredItem>((obj) => DesiredItem.fromJson(obj)).toList();
  }

  static Map<String,dynamic> toJson(DesiredItem item) => {
    'desired_item_id' : item.desiredItemId,
    'user_id':item.userId,
    'keyword':item.keyword
  };


}

class Images {
  final String imageName;
  final String listingId;
  final String imageIndex;


  Images(this.imageName,this.listingId,this.imageIndex);
  factory Images.fromJson(Map<String,dynamic> json) {
    return Images (
        json['image_name'],
        json['listing_id'],
        json['image_index']
    );
  }


  static Map<String,dynamic> toJson(Images i) => {
    'image_name':i.imageName,
    'listing_id':i.listingId,
    'image_index':i.imageIndex
  };


}


class Rating {
  //final String ratingId;
  final String rating;
  final String listingId;
  final String userId;

  Rating(this.rating,this.listingId,this.userId);
  factory Rating.fromJson(Map<String,dynamic> json) {
    return Rating(
        json['rating'],
        json['listing_id'],
        json['user_id']
    );
  }

  static List<Rating> fromJsonList(jsonList) {
    return jsonList.map<Rating>((obj) => Rating.fromJson(obj)).toList();
  }

  static Map<String,dynamic> toJson(Rating r) => {
    'rating':r.rating,
    'listing_id':r.listingId,
    'user_id':r.userId
  };
}