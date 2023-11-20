// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/Services/garbagebinRequestDB.dart';
import 'package:taboua_app/messages/confirm.dart';
import 'package:taboua_app/messages/infoMessage.dart';
import 'package:taboua_app/messages/success.dart';
import 'package:taboua_app/models/GarbageBinRequests.dart';
import 'package:taboua_app/screens/bottom_bar.dart';

/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewRequests(),
    );
  }
}*/

class viewRequests extends StatefulWidget {
  
  //const viewRequests({Key? key}) : super(key: key);

  final String userId;

  const viewRequests({Key? key, required this.userId}) : super(key: key);

  @override
  State<viewRequests> createState() => _viewRequestsState();
}

class _viewRequestsState extends State<viewRequests> {
  final garbagebinRequestDB _db = garbagebinRequestDB();
  //final String userId = "qoG4I4oHQzYYOavD8kxtRhEK7jj1"; // Replace with your user ID

  String selectedFilter = 'الكل';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      body: Column(
        children: [

          SizedBox(height: 60),
            Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                "طلبات الحاويات",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildFilterDropdown(),
          ),
          Expanded(
            child: StreamBuilder<List<GarbageBinRequests>>(
              stream: _db.getGarbageBinRequests(widget.userId, selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Center(child:Text('حدثت مشكلة أثناء تحميل البيانات',   style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 20.0),));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد طلبات', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ),

          SizedBox(height: 20),

           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to ...
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                primary: Color(0xFF97B980),
                padding: EdgeInsets.all(10),
                minimumSize: Size(300, 10),
              ),
              child: Text(
                "طلب حاوية",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                   
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],

      ),
      

      bottomNavigationBar: BottomBar(),

    );
  }

  
  

  Widget _buildFilterDropdown() {
    return  Directionality(
          textDirection: TextDirection.rtl,
          
      child:   InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          onChanged: (String? newValue) {
            setState(() {
              selectedFilter = newValue ?? 'الكل';
            });
          },
          items: <String>['الكل', 'جديد', 'قيد التنفيذ', 'مقبول', 'مرفوض']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              alignment: AlignmentDirectional.centerEnd, // Align text to the right
              child: Text(
                value,
                style: TextStyle(fontSize: 20.0),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            );
          }).toList(),
        ),
      ),
           ),
    );
  }


  
  Widget _buildRequestCard(GarbageBinRequests request) {
    Color? statusColor = Colors.black;


    // Set color based on request status
    switch (request.status) {
      case 'جديد':
        statusColor = Colors.blue[300];
        break;
      case 'قيد التنفيذ':
        statusColor = Colors.orange[300];
        break;
      case 'مقبول':
        statusColor = const Color(0xFF97B980);
        break;
      case 'مرفوض':
        statusColor = Colors.red[400];
        break;
      default:
        statusColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: const EdgeInsets.all(8.0),
          color: const Color(0xFFE9E9E9),
          elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(19.0),
             ),
         child: Padding(
        padding: const EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(statusColor!),
                    ),
                    child: Text(
                      '${request.status}',
                      style: TextStyle(color: Colors.white, fontSize: 17.0,),
                    ),
                  ),
                  if (request.status == 'جديد')
                    IconButton.filledTonal(
                      onPressed: () {
                        _showDeleteConfirmationDialog(request);
                      },
                      iconSize: 30.0,
                      icon: Icon(Icons.delete, color: Colors.grey),
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
                      ),
                    ),


                  if (request.status == 'مرفوض')
                    FilledButton.icon(
                      onPressed: () {
                        _showRejectionCommentDialog(request);
                      },
                      icon: Icon(Icons.info, color: Colors.white),
                      label: Text('التعليق', style: TextStyle(color: Colors.white,fontSize: 17.0,)),
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.grey),
                      ),
                    ),

                ],
              ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'رقم الطلب: ${request.requestNo}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20.0,
                color: Color(0xFF363436),
                fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'تاريخ الطلب ${_formatDate(request.requestDate)}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 17.0,
                fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
              ),
            ),
            if (request.status == 'مقبول' || request.status == 'مرفوض')
              Text(
                'تاريخ الرد: ${_formatDate(request.responseDate)}',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 17.0,
                  fontFamily: GoogleFonts.balooBhaijaan2().fontFamily,
                ),
              ),
          ],
        )
      ],
    ),
  ),
      ),
    );

    
  }



  void _showDeleteConfirmationDialog(GarbageBinRequests request) {

    ConfirmationDialog.show(
        context,
        "حذف الطلب",
        "هل أنت متأكد أنك تريد حذف هذا الطلب؟",
            () async {
          // Call the delete function from your database service
          await _db.deleteGarbageBinRequest(request);
          if (mounted) {
            SuccessMessageDialog.show(
              context,
              "تم حذف الطلب بنجاح",
              '.',
            );
          }

        },  );
  }


    void _showRejectionCommentDialog(GarbageBinRequests request) {
      InfoMessageDialog.show( context,
        'سبب الرفض',
        "${request.rejectionComment}",);
    
  }


  String _formatDate(Timestamp? date) {
    return date != null
        ? '${date.toDate().year}-${date.toDate().month}-${date.toDate().day}'
        : '';
  }

}