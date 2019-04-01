import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:senior_project_pickerpal/pickup_entry.dart';
import 'package:http/http.dart' as http;
class BackendService {



  static Future<List<Listing>> fetchListing(String url) async {

    final response =
    await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      List<Listing> newList = Listing.fromJsonList(json.decode(response.body));
      return newList;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<Listing> createListing(UploadListing listing,File image) async {
    Listing listin;
    await http.post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/addlisting",headers: {"Content-Type": "application/json"}, body: json.encode(UploadListing.toJson(listing))).then((response) {

      listin = Listing.fromJson(json.decode(response.body));


    });
    _uploadImage(image,listin.listing_id);
    return listin;
  }

  static Future<User> addUser(User user) async {
      User user;

      await http.post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/adduser", headers: {"Content-Type": "application/json"}, body: json.encode(User.toJson(user))).then(
          (response) {
           user = User.fromJson(json.decode(response.body));
      }
      );
      return user;
  }

  static Future<Rating> addRating(Rating rating) async {
    Rating rat;

    await http.post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/addrating", headers: {"Content-Type": "application/json"}, body: json.encode(Rating.toJson(rating))).then((response) {
      rat = Rating.fromJson(json.decode(response.body));
    });
    return rat;
  }

  static _uploadImage(File imageFile, dynamic listingId) async {
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/upload/"+listingId.toString());

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

}