/*
The following classes are used to encapsulate and decode the JSON objects returned by backend calls. They are also used to be converted into JSONs
which can be sent to the backend and stored appropriately.
*/

class Listing {
  final String description;
  final int user_id;
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
        user_id: json['userid'],
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

class User {
  int userId;
  final String emailAddress;
  final String displayName;
  final String tokenId;
  final String fbId;
  double overallRating;
  String deviceName;

  User(
      {this.emailAddress,
      this.displayName,
      this.tokenId,
      this.fbId,
      this.overallRating,
      this.userId});

  User.firebase(this.emailAddress, this.displayName, this.tokenId, this.fbId,
      this.overallRating);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        emailAddress: json['email_address'],
        displayName: json['display_name'],
        tokenId: json['token_id'],
        fbId: json['fb_uid'],
        overallRating: json['overall_rating'],
        userId: json['user_id']);
  }

  setUserId(int id) {
    this.userId = id;
  }

  setDeviceName(String name) {
    this.deviceName = name;
  }

  static Map<String, dynamic> toJson(User user) => {
        'email_address': user.emailAddress,
        'display_name': user.displayName,
        'token_id': user.tokenId,
        'fb_uid': user.fbId,
        'overall_rating': user.overallRating,
        'device_name': user.deviceName
      };
}

class DesiredItem {
  final int desiredItemId;
  final int userId;
  final String keyword;

  DesiredItem({this.userId, this.keyword, this.desiredItemId});
  factory DesiredItem.fromJson(Map<String, dynamic> json) {
    return DesiredItem(
        userId: json['user_id'],
        keyword: json['keyword'],
        desiredItemId: json['desired_item_id']);
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
  final String rating;
  final String listing_id;
  final String sender_id;
  final String reciever_id;

  Rating(this.rating, this.listing_id, this.sender_id, this.reciever_id);
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(json['rating'], json['listing_id'], json['sender_id'],
        json['reciever_id']);
  }

  static Map<String, dynamic> toJson(Rating rat) => {
        'rating': rat.rating,
        'listing_id': rat.listing_id,
        'sender_id': rat.sender_id,
        'reciever_id': rat.reciever_id
      };
}

class UserChat {
  final int chat_id;
  final User sender;
  final User recipient;

  UserChat({this.chat_id, this.sender, this.recipient});

  static List<UserChat> fromJsonList(jsonList) {
    return jsonList.map<UserChat>((obj) => UserChat.fromJson(obj)).toList();
  }

  factory UserChat.fromJson(Map<String, dynamic> json) {
    return UserChat(
      chat_id: json['chat_id'],
      sender: User.fromJson(json['sentuser']),
      recipient: User.fromJson(json['receiveduser']),
    );
  }
}

class Message {
  final String body;
  final String date;
  final UserChat chat;
  final User user;
  final int messageId;
  Message({this.body, this.date, this.chat, this.user, this.messageId});

  static List<Message> fromJsonList(jsonList) {
    return jsonList.map<Message>((obj) => Message.fromJson(obj)).toList();
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        body: json['body'],
        date: json['date'],
        chat: UserChat.fromJson(json['chat']),
        user: User.fromJson(json['user']),
        messageId: json['message_id']);
  }

  static Map<String, dynamic> toJson(Message m, int sender, int receiver) => {
        'body': m.body,
        'date': m.date,
        'sender': sender,
        'recipient': receiver,
        'user_id': m.user.userId
      };
}
