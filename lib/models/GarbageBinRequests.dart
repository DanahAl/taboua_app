// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';


class GarbageBinRequests {
  final String? id;
  final Timestamp? requestDate;
  final String? requestNo;
  final String? requesterId;
  final String? status;
  final GeoPoint? location;
  final Timestamp? responseDate;
  final String? rejectionComment;

  GarbageBinRequests({
    this.id,
    this.requestDate,
    this.requestNo,
    this.requesterId,
    this.status,
    this.location,
    this.responseDate,
    this.rejectionComment,
  });

  factory GarbageBinRequests.fromJson(DocumentSnapshot document) {
    String id = document.id;
    Map<String, dynamic> parsedJSON = document.data() as Map<String, dynamic>;

    return GarbageBinRequests(
      id: id,
      requestDate: parsedJSON['requestDate'] as Timestamp?,
      requestNo: parsedJSON['requestNo'].toString(),
      requesterId: parsedJSON['requesterId'].toString(),
      status: parsedJSON['status'].toString(),
      location: GeoPoint(
        parsedJSON['location'].latitude,
        parsedJSON['location'].longitude,
      ),
      responseDate: parsedJSON['responseDate'] as Timestamp?,
      rejectionComment: parsedJSON['rejectionComment']?.toString(),
    );
  }
}