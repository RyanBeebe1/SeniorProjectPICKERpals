import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'pickup_entry.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';

class BackendService {
  //Get a list of pickup listings from server.
  static Future<List<Listing>> fetchListing(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON

      List<Listing> newList = Listing.fromJsonList(json.decode(response.body));

      return newList;
    } else {
      // If that response was not OK, throw an error.

      throw Exception('Failed to load post');
    }
  }

  static Future<List<DesiredItem>> fetchDesiredItems(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<DesiredItem> desiredItem =
          DesiredItem.fromJsonList(json.decode(response.body));
      return desiredItem;
    } else {
      throw Exception('Failed to load desired item');
    }
  }

  static Future<void> deleteDesiredItem(String url) async {
         final response = await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON

    } else {
      // If that response was not OK, throw an error.

      throw Exception('Failed to load post');
    }
  }

  static Future<Listing> fetchListingById(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Listing item = Listing.fromJson(json.decode(response.body));
      return item;
    }
    else {
      throw Exception('Failed to load item by ID');
    }
  }

  static Future<void> deleteListing(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON

    } else {
      // If that response was not OK, throw an error.

      throw Exception('Failed to load post');
    }
  }

  //Create a listing in the database, return the new listing.

  static Future<Listing> createListing(
      UploadListing listing, File image) async {
    Listing listin;

    await http
        .post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/addlisting",
            headers: {"Content-Type": "application/json"},
            body: json.encode(UploadListing.toJson(listing)))
        .then((response) {
      listin = Listing.fromJson(json.decode(response.body));
      return listin;
    });

    _uploadImage(image, listin.listing_id);

    return listin;
  }

  //Add a user to the database if it doesn't already exist, return the user.

  static Future<User> addUser(User user) async {
    User myUser;

    DeviceInfoPlugin devicePlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await devicePlugin.androidInfo;
      user.setDeviceName(androidInfo.model.toString());
    } else {
      IosDeviceInfo iosInfo = await devicePlugin.iosInfo;
      user.setDeviceName(iosInfo.model.toString());
    }

    await http
        .post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/adduser",
            headers: {"Content-Type": "application/json"},
            body: json.encode(User.toJson(user)))
        .then((response) {
      Map<String, dynamic> jmap = json.decode(response.body);
      myUser = User.fromJson(jmap);
      myUser.setUserId(jmap['user_id']);
      return myUser;
    });

    return myUser;
  }

  static Future<User> fetchUserById(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      User myUser = User.fromJson(json.decode(response.body));
      return myUser;
    }
    else {
      throw Exception('Failed to load user by ID');
    }
  }

  static Future<Rating> addRating(Rating rating) async {
    Rating rat;

    await http
        .post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/addrating",
            headers: {"Content-Type": "application/json"},
            body: json.encode(Rating.toJson(rating)))
        .then((response) {
      rat = Rating.fromJson(json.decode(response.body));
      return rat;
    });
    return rat;
  }

  static Future<Rating> changeRating(Rating rating) async {
    Rating rat;

    await http
        .post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/changerating",
        headers: {"Content-Type": "application/json"},
        body: json.encode(Rating.toJson(rating)))
        .then((response) {
      rat = Rating.fromJson(json.decode(response.body));
      return rat;
    });
    return rat;
  }

  static Future<bool> inquireRating(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("inquireRating response.body: " + json.decode(response.body)["value"]);
     return json.decode(response.body)["value"] == "True";
    }
    else{
      throw Exception('Failed to inquire about rating');
    }
  }

  static Future<double> getOverall(String url) async {
    final response = await http.get(url);
    if(response.statusCode == 200) {
      return json.decode(response.body)["value"];
    }
    else{
      throw Exception('Failed to get overall rating');
    }
  }

  static Future<int> fetchRating(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body)["value"];
    }
    else{
      throw Exception('Failed to fetch single rating');
    }
  }

  //Upload an image for the given listing
  static _uploadImage(File imageFile, dynamic listingId) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse(
        "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/upload/" +
            listingId.toString());
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('photo', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));
    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  //Add a desired item to database.
  static Future<DesiredItem> addDesiredItem(DesiredItem item) async {
    DesiredItem newItem;
    await http
        .post(
            "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/adddesireditem",
            headers: {"Content-Type": "application/json"},
            body: json.encode(DesiredItem.toJson(item)))
        .then((response) {
      Map<String, dynamic> jmap = json.decode(response.body);
      newItem = DesiredItem.fromJson(jmap);
      return newItem;
    });

    return newItem;
  }
  static Future<void> addMessage(Message m, int sender, int receiver) async {
    
   await http
        .post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/sendmessage",
            headers: {"Content-Type": "application/json"},
            body: json.encode(Message.toJson(m,sender, receiver)))
        .then((response) {
    });

  }


  static Future<List<UserChat>> fetchChats(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<UserChat> uChat =
          UserChat.fromJsonList(json.decode(response.body));
      return uChat;
    } else {
      throw Exception('Failed to load desired item');
    }
  }

  static Future<List<Message>> fetchMessages(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<Message> messages =
          Message.fromJsonList(json.decode(response.body));
      return messages;
    } else {
      throw Exception('Failed to load desired item');
    }
  }

  static Future<Message> fetchLastMessage(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      Message item = Message.fromJson(json.decode(response.body));
      return item;
    }
    else {
      throw Exception('Failed to load item by ID');
    }
  }
}

  
