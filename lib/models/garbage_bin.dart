// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
class Garbage_Bin {

final String? serialNumber;
final String? size;
final GeoPoint? location;

Garbage_Bin({this.serialNumber , this.size , this.location });

Garbage_Bin.fromJson(Map<String, dynamic> parsedJSON)
      : serialNumber = parsedJSON['serialNumber'].toString(),
        size = parsedJSON['size'].toString(),
     location = GeoPoint(
          parsedJSON['location'].latitude,
          parsedJSON['location'].longitude,
        );
}

