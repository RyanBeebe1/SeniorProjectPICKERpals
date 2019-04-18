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

  static Future<List<DesiredItem>> fetchDesiredItem(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<DesiredItem> desiredItem =
          DesiredItem.fromJsonList(json.decode(response.body));
      return desiredItem;
    } else {
      throw Exception('Failed to load desired item');
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
      newItem.setId(jmap['desired_item_id']);
      return newItem;
    });

    return newItem;
  }
}
