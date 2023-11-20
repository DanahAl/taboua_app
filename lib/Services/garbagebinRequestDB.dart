// ignore_for_file: file_names, camel_case_types, avoid_print, use_rethrow_when_possible

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taboua_app/models/GarbageBinRequests.dart';

class garbagebinRequestDB {
  final CollectionReference garbageRequestColleaction =
  FirebaseFirestore.instance.collection("requestedGarbageBin");

  Stream<List<GarbageBinRequests>> getGarbageBinRequests(String userId, String? selectedFilter) {
    Query query = garbageRequestColleaction.where('requesterId', isEqualTo: userId);

    if (selectedFilter != null && selectedFilter != 'الكل') {
      // If a specific status is selected, add a filter for that status
      query = query.where('status', isEqualTo: selectedFilter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((DocumentSnapshot document) {
        return GarbageBinRequests.fromJson(document);
      }).toList();
    });
  }


  Future<void> deleteGarbageBinRequest(GarbageBinRequests request) async {
    try {
      await garbageRequestColleaction.doc(request.id).delete();

    } catch (e) {
      // Handle error (print or throw an exception)
      print("Error deleting request: $e");
      throw e;
    }
  }

   Future<void> add(Map<String, dynamic> data) async {
    // Add a new document with a generated ID
    try{
   await garbageRequestColleaction.add(data);

    }
    catch(e){
            print("Error adding request: $e");

    }
  }

  
}