// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taboua_app/models/recycling_center.dart';


class recyclingCentersDatabase{

//collection refrence 
final CollectionReference recyclingCenters = FirebaseFirestore.instance.collection("recyclingCenters");


Stream<List<recyclingcenter>> getRecyclingCenters() {
    return recyclingCenters
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => recyclingcenter.fromJson(document.data() as Map<String, dynamic>))
        .toList());
  }

}