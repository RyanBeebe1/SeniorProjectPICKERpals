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
  final User user;
  final dynamic listing_id;

  Listing(
      {this.description,
      this.user_id,
      this.item_title,
      this.location,
      this.tag,
      this.zipcode,
      this.cond,
      this.listing_date,
      this.listing_id,
      this.user});

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
        description: json['description'],
        user_id: json['userid'].toString(),
        item_title: json['title'],
        location: json['location'],
        tag: json['tag'],
        zipcode: json['zipcode'],
        cond: json['condition'],
        listing_date: json['date'],
        listing_id: json['listingid'],
        user: User.fromJson(json['user']));
  }

  static List<Listing> fromJsonList(jsonList) {
    return jsonList.map<Listing>((obj) => Listing.fromJson(obj)).toList();
  }

  static Map<String, dynamic> toJson(Listing l) => {
        "description": l.description,
        "title": l.item_title,
        "userid": l.user_id,
        "location": l.location,
        "tag": l.tag,
        "zipcode": l.zipcode,
        "date": l.listing_date,
        "condition": l.cond,
        "listingid": l.listing_id,
        "user": l.user,
      };
}

class UploadListing {
  final String description;
  final int user_id;
  final String item_title;
  final String location;
  final String tag;
  final String zipcode;
  final String cond;
  final String listing_date;

  UploadListing(this.description, this.user_id, this.item_title, this.location,
      this.tag, this.zipcode, this.cond, this.listing_date);

  factory UploadListing.fromJson(Map<String, dynamic> json) {
    return UploadListing(
        json['description'],
        json['userid'],
        json['title'],
        json['location'],
        json['tag'],
        json['zipcode'],
        json['condition'],
        json['date']);
  }

  static List<UploadListing> fromJsonList(jsonList) {
    return jsonList
        .map<UploadListing>((obj) => UploadListing.fromJson(obj))
        .toList();
  }

  static Map<String, dynamic> toJson(UploadListing l) => {
        "description": l.description,
        "title": l.item_title,
        "userid": l.user_id,
        "location": l.location,
        "tag": l.tag,
        "zipcode": l.zipcode,
        "date": l.listing_date,
        "condition": l.cond
      };
}

class User {
  int userId;
  final String emailAddress;
  final String displayName;
  final String tokenId;
  final String fbId;
  final int overallRating;

  User(
      {this.emailAddress,
      this.displayName,
      this.tokenId,
      this.fbId,
      this.overallRating});

  User.firebase(this.emailAddress, this.displayName, this.tokenId, this.fbId,
      this.overallRating);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        emailAddress: json['email_address'],
        displayName: json['display_name'],
        tokenId: json['token_id'],
        fbId: json['fb_uid'],
        overallRating: json['overall_rating']);
  }

  setUserId(int id) {
    this.userId = id;
  }

  static Map<String, dynamic> toJson(User user) => {
        'email_address': user.emailAddress,
        'display_name': user.displayName,
        'token_id': user.tokenId,
        'fb_uid': user.fbId,
        'overall_rating': user.overallRating
      };
}

class DesiredItem {
  dynamic desiredItemId;
  final dynamic userId;
  final String keyword;

  DesiredItem(this.userId, this.keyword);
  factory DesiredItem.fromJson(Map<String, dynamic> json) {
    return DesiredItem(json['user_id'], json['keyword']);
  }

  void setId(int itemId) {
    this.desiredItemId = itemId;
  }

  static List<DesiredItem> fromJsonList(jsonList) {
    return jsonList
        .map<DesiredItem>((obj) => DesiredItem.fromJson(obj))
        .toList();
  }

  static Map<String, dynamic> toJson(DesiredItem item) =>
      {'user_id': item.userId, 'keyword': item.keyword};
}

class Images {
  final String imageName;
  final String listingId;
  final String imageIndex;

  Images(this.imageName, this.listingId, this.imageIndex);
  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(json['image_name'], json['listing_id'], json['image_index']);
  }

  static Map<String, dynamic> toJson(Images i) => {
        'image_name': i.imageName,
        'listing_id': i.listingId,
        'image_index': i.imageIndex
      };
}

class Rating {
  //final String ratingId;
  final String rating;
  final String listingId;
  final String userId;

  Rating(this.rating, this.listingId, this.userId);
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(json['rating'], json['listing_id'], json['user_id']);
  }

  static List<Rating> fromJsonList(jsonList) {
    return jsonList.map<Rating>((obj) => Rating.fromJson(obj)).toList();
  }

  static Map<String, dynamic> toJson(Rating r) =>
      {'rating': r.rating, 'listing_id': r.listingId, 'user_id': r.userId};
}

class UserChat {
  final int chat_id;
  final User sender;
  final User recipient;

  UserChat({
    this.chat_id,
    this.sender,
    this.recipient
  });

  static List<UserChat> fromJsonList(jsonList) {
    return jsonList.map<UserChat>((obj) =>UserChat.fromJson(obj)).toList();
  }

  factory UserChat.fromJson(Map<String, dynamic> json) {
    return UserChat(
      chat_id: json['chat_id'],
      sender: User.fromJson(json['sender']),
      recipient: User.fromJson(json['recipient']),
    );
  }

}

class Message {
  final String body;
  final String date;
  final int chat_id;

  Message({
    this.body,
    this.chat_id,
    this.date,

  });

  static List<Message> fromJsonList(jsonList) {
    return jsonList.map<Message>((obj) => Message.fromJson(obj)).toList();
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      body: json['body'],
      date: json['date'],
    );
  }
}
