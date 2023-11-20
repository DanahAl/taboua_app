// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
class recyclingcenter {

final String? name;
final String? description;
final String? imageURL;
final String? logoURL;
final GeoPoint? location;
final String? phoneNo;
final String? type;
final String? websiteURL;
//final String? weekdaysFrom;
//final String? weekdaysTo;
final Map<String, dynamic>? openingHours;


recyclingcenter({this.name , this.description, this.imageURL , this.logoURL , this.location  , this.phoneNo ,this.type , this.websiteURL , this.openingHours});

recyclingcenter.fromJson(Map<String, dynamic> parsedJSON)
      : name = parsedJSON['name'].toString(),
        description = parsedJSON['description'].toString(),
        imageURL = parsedJSON['imageURL'].toString(),
        logoURL = parsedJSON['logoURL'].toString(),
        websiteURL = parsedJSON['websiteURL'].toString(),
         phoneNo = parsedJSON['phoneNo'].toString(),
         type = parsedJSON['type'].toString(),
     location = GeoPoint(
          parsedJSON['location'].latitude,
          parsedJSON['location'].longitude,
        ),
     //   weekdaysFrom= parsedJSON['openingHours'].toString(),
      // weekdaysTo= parsedJSON['openingHours'].toString();
        openingHours = parsedJSON['openingHours'];

/*
final Map<String, dynamic> openingHoursMap = jsonDecode(openingHours);
weekdaysFrom = openingHoursMap['weekdays']['from'].toString();
weekdaysTo = openingHoursMap['weekdays']['to'].toString();*/



}
