// ignore_for_file: camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taboua_app/models/garbage_bin.dart';


class garbageDatabase{

//collection refrence 
final CollectionReference garbageColleaction = FirebaseFirestore.instance.collection("garbageBins");


// get all `garbageBins` collection's documents
/*
  Stream<GarbageBin>get getGarbageBin {
    return garbageColleaction.snapshots();
  }
*/

/*
List<GarbageBin> garbageBinsSnaphot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      //print(doc.data);
      return Garbage_Bin (
          name: doc.data['name'] ?? '',
          strength: doc.data['strength'] ?? 0,
          sugars: doc.data['sugars'] ?? '0');
    }).toList();
  }
}
*/

Stream<List<Garbage_Bin>> getGarbageBin() {
    return garbageColleaction
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((document) => Garbage_Bin.fromJson(document.data() as Map<String, dynamic>))
        .toList());
  }

}