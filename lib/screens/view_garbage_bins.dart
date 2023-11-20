// ignore_for_file: unused_field, unnecessary_null_comparison, unused_local_variable, camel_case_types, prefer_final_fields, prefer_collection_literals, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, unnecessary_brace_in_string_interps, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import'dart:async';
import 'package:taboua_app/Services/garbage_database.dart';
import 'package:provider/provider.dart';
import 'package:taboua_app/Services/garbagebinRequestDB.dart';
import 'package:taboua_app/models/garbage_bin.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:taboua_app/screens/bottom_bar.dart';
import 'package:toastification/toastification.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Services/address_request.dart';
import 'dart:math';
import 'package:intl/intl.dart' hide TextDirection;

import '../messages/requestToaster.dart';
import '../messages/success.dart';


void main() {

runApp(const MyApp());

}
class MyApp extends StatelessWidget {

const MyApp({super.key});

@override


Widget build(BuildContext context) {

return MaterialApp(

theme: ThemeData.light(useMaterial3: true),

//home: viewGrabageBin(userId: ''),

);

}

}
enum garbageSizes { big ,  small }

class viewGrabageBin extends StatefulWidget {
final String userId;
const viewGrabageBin({Key? key , required this.userId}) : super(key: key);

@override

State<viewGrabageBin> createState() => _viewGrabageBinState();

}

class _viewGrabageBinState extends State<viewGrabageBin> {

Uint8List? markerIcon ;

Position? currentLocation;

garbageDatabase garbageDb = garbageDatabase(); // create instance from GarbageDatabase
 ToastManager toastManager = ToastManager();
Set<Marker> _markers = Set(); // markers list

late GoogleMapController _mapController;
LatLng? latlong;
Position? _currentLocation;
bool _isLoading = true;
Marker? draggedMarker; // Variable to hold the dragged marker
bool isButtonVisible = true;
bool isTapOnMap = false;
bool isMarkerDraggable = true;
bool requestWindow = false;
bool isToastVisible = false;
String? requestReasonError ;
  final _formKey = GlobalKey<FormState>();


  final Toastification toastification = Toastification();
  int tosateMessageAppear = 0;
  
    String dropdownValue = "الكل";

@override

void initState() {
super.initState();
_getLocation(); // get user current location
_fetchGarbageBins(); // fetach data from firebase

}

// function to get cuurent user location

Future<void> _getLocation() async {

final status = await Permission.location.request();

if (status.isGranted) {

try {

final position = await Geolocator.getCurrentPosition(

desiredAccuracy: LocationAccuracy.bestForNavigation,

);

setState(() {

_currentLocation = position;

_isLoading = false;

});

} catch (e) {

print('Error getting location: $e');

}

} else {

print('Location permission not granted');

}

}

// to resize icon marker

Future<Uint8List>getBytesFromAssets (String path , int width) async{
ByteData data = await rootBundle.load(path);
ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetHeight:width );
ui.FrameInfo fi = await codec.getNextFrame() ;
return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();

}
// fetach garbge info from firebase

void _fetchGarbageBins() {
  // Use data from garbageDatabase here
  final garbageDb = garbageDatabase();
  final garbageBinsStream = garbageDb.getGarbageBin();
  garbageBinsStream.listen((List<Garbage_Bin> garbageBins) async {
    // Clear existing markers
    _markers.clear();

    // Filter garbageBins based on the selected type
    
    final filteredGarbageBins = dropdownValue != "الكل"
        ? garbageBins.where((bin) => bin.size == dropdownValue).toList()
        : garbageBins;
  
    // Create markers from the filtered data
    for (final garbageBin in filteredGarbageBins) {
      final lat = garbageBin.location?.latitude; // Use the null-aware operator
      final long = garbageBin.location?.longitude; // Use the null-aware operator
      final Uint8List markerIcon = await getBytesFromAssets("images/trash.png", 100);

      if (lat != null && long != null) {
        final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(5, 5)),
          'images/recyclingcenter.png',
        );

        final marker = Marker(
          markerId: MarkerId(garbageBin.serialNumber!),
          position: LatLng(lat, long),
          icon: markerIcon != null ? BitmapDescriptor.fromBytes(markerIcon) : BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: "حجم الحاوية:",
            snippet: garbageBin.size, // Display the size in the info window
          ),
        );

        setState(() {
          _markers.add(marker);
        });
      }
    }
  });
}
// to show map controller

void _onMapCreated(GoogleMapController controller) {
_mapController = controller;

}

// display tosate info to guide user to request garbage bin
void displayToast(BuildContext context) async {
       if (toastManager.isToastVisible && tosateMessageAppear>0) {
         toastManager.showCustomToast(context);
       } else {
        tosateMessageAppear =0;
         toastManager.dismiss(); // Dismiss the toast if it's visible
       }
     }

//to show the area, postal code, and street at the selected location.
Future<void> showBottomSheetwithButtonRequest(BuildContext context, LatLng position) async {
  String address = await addressRequest.searchCoordinateAddress(position, context); // get address from address_request class
showModalBottomSheet(
backgroundColor: Colors.transparent,
isScrollControlled: true,
context: context,
builder: (BuildContext bc) {
return DraggableScrollableSheet(
initialChildSize: 0.2,
maxChildSize: 0.2,
minChildSize: 0.2,
expand: false,
builder: (context, scrollController) {
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.only(
topLeft: Radius.circular(16),
topRight: Radius.circular(16),
    ),
),
child: Column(
children: [


Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'الرياض',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.right,
          ),
          SizedBox(width: 8), // Adjust the space between the icon and text
         
          Icon(
            Icons.location_on,
            size: 30,
            color: Color(0xe63B3B3B),
          ),
        ],
      ),
    ),
  ],
),

Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 33), // Padding to the right of the text
        child: Text(
          address,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.right,
        ),
      ),
    ),
  ],
),

ElevatedButton(
style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: Color(0xFF97B980),
                padding: EdgeInsets.all(10),
                minimumSize: Size(300, 10),
              ),
              child: Text(
                "طلب حاوية للموقع الحالي",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),

onPressed: () {
showRequestDialog(context , position , address); // Function to show the dialog
   Navigator.pop(context); // Close the modal bottom sheet
isToastVisible = false;
toastManager.isToastVisible = false;
},
),

],
),
);
},

);

},

);

}

// validition grabge bin request reason 
 void _validateRequestReason(String value) {
    if (value.isEmpty) {
      setState(() {
        requestReasonError = "الرجاء إدخال سبب الطلب";
      });
    } else {
      setState(() {
        requestReasonError = null;
      });
    }
  }


void showRequestDialog(BuildContext context , LatLng position , String address) {
String title = "طلب حاوية";
String message = "بيانات طلب الحاوية";
String dropdownValue = 'حاوية صغيرة';
String userInputText = '';
List<String> sizes = [ 'حاوية صغيرة', 'حاوية كبيرة']; // Updated dropdown list
String? bigGarbage = sizes[0];
String? smallGarbage = sizes[1];
garbageSizes? selectedSize = garbageSizes.big;

showDialog(
context: context,
builder: (context) {
return Dialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
child: Container(
padding: EdgeInsets.all(16),
child: Column(
mainAxisSize: MainAxisSize.min,

children: [
Text(
title,
style: GoogleFonts.balooBhaijaan2(
fontSize: 18,
fontWeight: FontWeight.bold,
),

),

SizedBox(height: 20),
Text(
message,
style: GoogleFonts.balooBhaijaan2(
fontSize: 16,
),
textAlign: TextAlign.center,
),

SizedBox(height: 20),

SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'حجم الحاوية',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Container(
                  child: DropdownMenu<String>(
                    width: 250,
                    initialSelection: dropdownValue,
                    onSelected: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    dropdownMenuEntries: sizes
                        .where((value) => value != 'حجم الحاوية')
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(value: value, label: value);
                    }).toList(),
                  ),
                ),
              ],
        
            ),

// add request reason text  fileds 
            Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // Text field for request reason
      Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          textAlign: TextAlign.right,
          maxLines: 1,
          decoration: InputDecoration(
            labelText: "سبب طلب الحاوية",
            labelStyle: TextStyle(color: Color(0xff07512d)),
      
            hintText: "سبب طلب الحاوية",
            alignLabelWithHint: true,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _formKey.currentState?.validate() == false ? Colors.red : Color(0xff07512d)),
            ),
          ),
          onChanged: (value) {
            setState(() {
              userInputText = value;
              _validateRequestReason(value);
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال سبب الطلب';
            }
            return null;
          },
        ),
      ),

      // Error message for request reason
      Text(
        _formKey.currentState?.validate() == false ? 'الرجاء إدخال سبب الطلب' : '',
        style: TextStyle(color: Colors.red),
      ),

      SizedBox(height: 20),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           ElevatedButton(
      onPressed: () {
        setState(() {
          isButtonVisible = true;
          isTapOnMap = false;
          isMarkerDraggable = false;
          draggedMarker = null;
          _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude), zoom: 11.5)));
          // Reset the error message when cancelling
          requestReasonError = "";
        });
        Navigator.of(context).pop(); // Close the dialog
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        "الغاء",
        style: GoogleFonts.balooBhaijaan2(
          color: Colors.white,
        ),
      ),
    ),

        SizedBox(width: 20), // Adjust the width as needed

          ElevatedButton(
            onPressed: () {
              setState(() {
                if(_formKey.currentState?.validate() == true){
                   isButtonVisible = true;
                isTapOnMap = false;
                isMarkerDraggable = false;
                draggedMarker = null;
                _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                 zoom: 14.5)));
                   addRequest(dropdownValue, userInputText, position , address);
                Navigator.of(context).pop(); // Close the dialog
                // show success message after request garbage bin
                 SuccessMessageDialog.show(
              context,
              "تم طلب الحاوية بنجاح",
              '.',
            );
                }

    
                
              });
              // Validate the request reason
              if (_formKey.currentState?.validate() == true) {
                // Request reason is valid, add to the database
                addRequest(dropdownValue, userInputText, position , address);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF97B980),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "تأكيد",
              style: GoogleFonts.balooBhaijaan2(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      
    ],
  ),
)


],

),

),

);

},

);

}

int generateUniqueNumber() {
final random = Random();
return random.nextInt(10000); // Generates a random number between 0 and 9999
}
// genrate unique requestNo
String generateRequestNumber() {
// Get the current date and time
final now = DateTime.now();
final date = DateFormat('yyMMdd');
// Format the current date as a string
final formattedDate = date.format(now);
// Generate a unique 4-digit number
final uniqueNumber = generateUniqueNumber().toString().padLeft(4, '0');
// Combine the formatted date with the unique number
final requestNumber = formattedDate + uniqueNumber;
return requestNumber;
}

void addRequest(String garbgeSize , String requestReason , LatLng position , String address) async {
  // Function to generate a request number
final requestNumber = generateRequestNumber();
//  Create instnace of garbagebinRequestDB class
garbagebinRequestDB requestDB = garbagebinRequestDB();
// Request data
final requestData = {
'location': GeoPoint(position.latitude, position.longitude), // Replace with the actual coordinates
'requestNo': requestNumber,
'requestDate': Timestamp.fromDate(DateTime.now()),
'requesterId': widget.userId, // user ID
'status': 'جديد', 
'garbageSize':garbgeSize,
'requestReason':requestReason,
'localArea': address,

};

requestDB.add(requestData); // add to firebase
  
}
// filter grabage bin based on type
Widget filterMarkers(BuildContext context) {
  const List<String> list = <String>[ "الكل", "حاوية كبيرة", "حاوية صغيرة"];

  return Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
      padding:EdgeInsets.all(8.0),
      child: Container(
        child: DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
            });
            _fetchGarbageBins();
          },
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              alignment: AlignmentDirectional.centerEnd, // Align text to the right
              child: Text(value,
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              ),
              
            );
          }).toList(),
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
          ),
          iconSize: 30.0,
          elevation: 16,
          underline:SizedBox(),
        ),
      ),
    ),
  );
}


@override

Widget build(BuildContext context) {

//stream to fetach new data wehn upadted from firebase

return StreamProvider<List<Garbage_Bin>>.value(

initialData: [],

value:garbageDb.getGarbageBin(),

child: Scaffold(
  appBar: AppBar(
        
        title: Text(
      'حاويات النفايات', // Add a comma here
      style: TextStyle(
        color: Colors.black,
      ),
    ),
        backgroundColor: Colors.white,
        actions: [
          filterMarkers(context), // Add the filter dropdown to the app bar
        ],
      ),
body: _isLoading ?

const Center(child:CircularProgressIndicator()) :

GestureDetector(
   onVerticalDragStart: (start) {},
  child: GoogleMap(
  zoomControlsEnabled: true,
  zoomGesturesEnabled: true,
  myLocationButtonEnabled: true,
  scrollGesturesEnabled: true,
  rotateGesturesEnabled:false,
  tiltGesturesEnabled: true,
  myLocationEnabled: true,
  onMapCreated: _onMapCreated,
  initialCameraPosition: CameraPosition(
  target: LatLng(
  _currentLocation?.latitude ?? 0.0,
  _currentLocation?.longitude ?? 0.0,
  ),
  zoom: 14.5,
  ),
  
  //     markers: _markers, // Set of markers
  gestureRecognizers: Set()
          ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
          ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
          ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
          ..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer())),
  
  onTap:!isButtonVisible&& isTapOnMap ?
  
  (LatLng position) {
  
  setState(() {
  draggedMarker = Marker(
  markerId: const MarkerId('dragged_marker'),
  position: position,
  icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  draggable: true,
  );
  
  if(isMarkerDraggable) {
  showBottomSheetwithButtonRequest(context , position ); // if marker drag the should new address
  }
  
  });
  
  }
  :null,
  markers: draggedMarker != null ? Set.of([draggedMarker!]) : _markers, // if click on reuqest buttton teh will show only the dragble button if not click will show all markers
  
  ),
),

// request button
floatingActionButton:isButtonVisible?

FloatingActionButton.extended(
onPressed: () {
_mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude), zoom: 18)));
toastManager.isToastVisible = true;
tosateMessageAppear+=1; // to not dipaly tosate message more the one time
  displayToast(context); // Display the toast message

//show selected location when request garbage
showBottomSheetwithButtonRequest(context ,  LatLng(
_currentLocation!.latitude,
_currentLocation!.longitude,
), );

setState(() {
draggedMarker = Marker(
markerId: MarkerId('dragged_marker'),
position: LatLng(_currentLocation?.latitude ?? 0.0,
_currentLocation?.longitude ?? 0.0,),
icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
 // Set your desired coordinates
draggable: true, // Make the marker draggable
);

isButtonVisible = false; // Hide the button on click
isTapOnMap = true;
isMarkerDraggable= true;
});
},
backgroundColor:Color(0xff07512d),
tooltip: 'طلب حاوية',
label: Row(
    children: [
      Image.asset(
        'images/bin1.png', // Path to your PNG icon
        width: 24, // Define the width of the icon
        height: 24, // Define the height of the icon
        color: Colors.white, // Define the color of the icon
      ),
      SizedBox(width: 8), // Adjust the space between the icon and text
      Text(
        'طلب حاوية',
        style: TextStyle(fontSize: 18),
      ),
    ],
  ),

) :null,

floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat, 

//bottomNavigationBar: BottomBar(),
bottomNavigationBar:BottomBar(),
   

),

);

}

}