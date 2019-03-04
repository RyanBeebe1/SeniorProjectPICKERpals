import 'dart:convert';
import 'package:senior_project_pickerpal/pickup_entry.dart';
import 'package:http/http.dart' as http;
class BackendService {



  static Future<Listing> fetchListing(String url) async {
    final response =
    await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return Listing.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }


}