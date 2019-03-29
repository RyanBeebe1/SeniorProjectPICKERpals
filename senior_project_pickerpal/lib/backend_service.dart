import 'dart:async';
import 'dart:convert';
import 'package:senior_project_pickerpal/pickup_entry.dart';
import 'package:http/http.dart' as http;
class BackendService {



  static Future<List<Listing>> fetchListing(String url) async {
    
    final response =
    await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      List<dynamic> myList = json.decode(response.body);
      List<Listing> newList = [];
      for (Map<String,dynamic> d in myList) {
        Listing l = Listing.fromJson(d);
    
        newList.add(l);
      }
      return newList;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<void> createListing(Listing listing) async {
  await http.post("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/addlisting",headers: {"Content-Type": "application/json"}, body: json.encode(Listing.toJson(listing))).then((response) {
    print(response.statusCode);
  });

  }


}