// ignore_for_file: unused_local_variable, camel_case_types, unnecessary_string_interpolations

import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

//import 'package:geolocator/geolocator.dart';
class addressRequest {

  static Future<dynamic> getRequest(String url) async{
    http.Response response = await http.get(Uri.parse(url));

    try{
      if (response.statusCode == 200){
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);
        return decodeData;
      }
      else {
        return "failed";
      }
    }
    catch(e){
      return "failed";

    }
  }

  // serach coordinate address
  static Future<String> searchCoordinateAddress( LatLng position, context) async{
    String placeAddress = "";
    String localArea= "";
    String url = "https://maps.googleapis.com/maps/api/geocode/json?"
        "latlng=${position.latitude},${position.longitude}&language=ar&key=AIzaSyAg5Moce2vsJ85oYfgX6wekMYaf8GpGdTs";
//get the local area , street and postal code from 
    var response = await getRequest(url);

    localArea = response["plus_code"]["compound_code"];
    placeAddress = response["results"][0]["formatted_address"];

  List<String> area = localArea.split('،'); // Split the address by commas

// Access the results array
  List<dynamic> results = response["results"];
List<String> routes = [];
List<String> postalCode = [];
List<String> neighborhood = [];


for (Map<String, dynamic> result in results.cast<Map<String, dynamic>>()) {
  // Loop through address components for each result
  for (Map<String, dynamic> component
      in result["address_components"].cast<Map<String, dynamic>>()) {
    List<String> types = List<String>.from(component["types"]);

    // Check if the component type is "route"
    if (types.contains("route")) {
      String longName = component["long_name"];
      if(longName != "طريق بدون اسم") {
        routes.add(longName); // Add the long name to the list
      }
    }

if (types.contains("postal_code")) {
       String postCode  = component["long_name"];
       postalCode.add(postCode);
    }

if (types.contains("neighborhood") || types.contains("political")) {
       String neighborhoodName  = component["long_name"];
       neighborhood.add(neighborhoodName);
    }
  }
}

  List<String> words = localArea.split('،');
  String areafirstWord = words.length > 1 ? words[1] : '';
  

 List<String> addressParts = placeAddress.split('،'); // Split the address by commas


  String placeAddressfirstWord = addressParts.length > 1 ? addressParts[1]: '';

 String mergedAddress;
if(routes.isNotEmpty) {
 mergedAddress = '${neighborhood[0]},${routes[0]} , ${postalCode[0]}';
}

else if (area.isNotEmpty && placeAddressfirstWord.isNotEmpty && postalCode.isNotEmpty ){
   mergedAddress = '${postalCode[0]} , ${neighborhood[0]}';
}
 
 else {
   mergedAddress = '${area[0]}';
 }
    return mergedAddress;

  }
}