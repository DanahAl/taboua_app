// ignore_for_file: camel_case_types, prefer_final_fields, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, prefer_collection_literals, unnecessary_null_comparison, unused_field, avoid_unnecessary_containers, non_constant_identifier_names, unused_import

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'hide TextDirection;
import 'package:permission_handler/permission_handler.dart';
import'dart:async';
import 'package:taboua_app/Services/garbage_database.dart';
import 'package:provider/provider.dart';
import 'package:taboua_app/Services/recycling_center.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:taboua_app/models/recycling_center.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:taboua_app/screens/bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewRecyclingCenters(),
    );
  }
}

class viewRecyclingCenters extends StatefulWidget {
  const viewRecyclingCenters({Key? key}) : super(key: key);

  @override
  State<viewRecyclingCenters> createState() => _viewRecyclingCenters();
}




class _viewRecyclingCenters extends State<viewRecyclingCenters> {
 
 recyclingCentersDatabase recyclingCenterDB = recyclingCentersDatabase(); // instance recyclingCentersDatabase class

  Uint8List? markerIcon ; // convert marker icon to bytes
  Position? currentLocation; 
  garbageDatabase garbageDb = garbageDatabase(); // create instance from GarbageDatabase 
  Set<Marker> _markers = Set(); // markers list 
  late GoogleMapController _mapController; 
  LatLng? latlong;
  Position? _currentLocation;
  bool _isLoading = true; // loding map
  String dropdownValue = "الكل";
  

  @override
 void initState() {
    super.initState();
    _getLocation(); // get user current location
    _fetchRecyclingCenter(); // fetach data from firebase

  }

  

// get user current location
Future<void> _getLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        );

        setState(() {
          _currentLocation = position;
          _isLoading = false; //map load
        });
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      print('Location permission not granted');
    }
  }

// to resize marker icon by convert itto byte
Future<Uint8List>getBytesFromAssets (String path , int width) async{
ByteData data = await rootBundle.load(path);
ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetHeight:width );
ui.FrameInfo fi = await codec.getNextFrame() ;
return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();

}

// widget to show images as animating slider 
Widget buildCarousel(List<String> imageURLs) {
  return CarouselSlider(
    options: CarouselOptions(
      aspectRatio: 16 / 9,
      enlargeCenterPage: true,
      enableInfiniteScroll: true,
      autoPlay: true,
    ),
    items: imageURLs.map((imageURL) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
          width: double.infinity,
           height: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: NetworkImage(imageURL),
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      );
    }).toList(),
  );
}

// function when user click on link open it on browser
 Future<void> _launch(Uri url) async {
   await canLaunchUrl(url)
    ? await launchUrl(url)
    : print('could_not_launch_this_app');
}

// fromating center opening hours for weekdays
String _formatHour(int? hour , String range) {
  if (hour == null) {
    return 'مغلق'; // Handle the case when the center is close
  }

  String period = 'ص';

  if(hour<12) {
    hour+=3;
  }
  if (hour >= 12) {
    period = 'م';
    if (hour > 12) {
      hour -= 9;
    }
  }
  if(range =='من') {
    return '$hour:00 $period';
  }
else {
  range = "إلى";
    return '$range $hour:00 $period';

}
}
// fromating center opening hours for weekends

String _formatHourWeekend(int? hour , String range) {
  if (hour == null) {
    return 'مغلق'; 
  }
  String period = 'ص';

  if(hour<12) {
    hour+=3;
  }
  if (hour >= 12) {
    period = 'م';
    if (hour > 12) {
      hour -= 9;
    }
  }
  if(range =='من') {
    return '$hour:00 $period';
  }
else {
  range = "إلى";
    return '$range $hour:00 $period';

}
}


// show center info 
Future<void> _showMarkerDetails(BuildContext context, recyclingcenter recyclingCenter) {

final Map<String, dynamic>? openingHours = recyclingCenter.openingHours; // to get map openinghours from firebase
 String WeekdaysFormattedFromHour = '' ;
  String WeekdaysFormattedToHour = '';
  String FriFormattedFromHour = '';
   String FriFormattedToHour = '';
  String SatFormattedFromHour = '';
   String SatFormattedToHour = '';
 if (openingHours != null) {
    String weekdaysFrom = (openingHours['weekdays']['from']) ?? '';
    String weekdaysTo = (openingHours['weekdays']['to']) ?? '';

    String FriFrom = (openingHours['fri']['from']) ?? '';
     String FriTo = (openingHours['fri']['to']) ?? '';

    String SatFrom = (openingHours['sat']['from']) ?? '';
    String SatTo = (openingHours['sat']['to']) ?? '';

int? WeedaysFromHour;
int? WeekdaysToHour;
int?FrifromHour;
int?FriToHour;
int?SatfromHour;
int?SatToHour;

if (weekdaysFrom.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(weekdaysFrom); // parse time from string to DateTime
  WeedaysFromHour = toDateTime.hour; // get Hour 
}

if (weekdaysTo.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(weekdaysTo);// parse time from string to DateTime
  WeekdaysToHour = toDateTime.hour; // get hour
}

if (FriFrom.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(FriFrom);// parse time from string to DateTime
  FrifromHour = toDateTime.hour; // get hour
}

if (FriTo.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(FriTo);// parse time from string to DateTime
  FriToHour = toDateTime.hour; // get Hour
}

if (SatFrom.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(SatFrom); // parse time from string to DateTime
  SatfromHour = toDateTime.hour; // get Hour
}

if (SatTo.isNotEmpty) {
  DateTime toDateTime = DateTime.parse(SatTo);// parse time from string to DateTime
  SatToHour = toDateTime.hour; // get Hour
}

   // fromating oprning hour time 
   WeekdaysFormattedFromHour = _formatHour(WeedaysFromHour , "من");
   WeekdaysFormattedToHour = _formatHour(WeekdaysToHour , "إلى");
   FriFormattedFromHour = _formatHourWeekend( FrifromHour, "من");
   FriFormattedToHour = _formatHourWeekend( FriToHour, "إلى");
   SatFormattedFromHour = _formatHourWeekend( SatfromHour, "من");
   SatFormattedToHour = _formatHourWeekend( SatToHour, "إلى");

} else {
  print("openingHours empty");
}
// return cenetr infomation window
  return showModalBottomSheet(
    
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    context: context,
    builder: (BuildContext bc) {
      return DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        minChildSize: 0.32,
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
            child: ListView.builder(
              controller: scrollController,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Divider(
                          thickness: 5,
                          color: Colors.grey,
                        ),
                      ),
                      ListTile(
                        title: Text('${recyclingCenter.name}',
                          style: TextStyle(
                          fontWeight: FontWeight.bold,
                           )  ,
                        ),
                      ),
                  
                   ListTile(
           title: RichText(
          text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
          TextSpan(
          text: 'وصف: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '${recyclingCenter.description}',
          style: TextStyle(
            fontWeight: FontWeight.normal, // Regular font weight
          ),
        ),
      ],
      ),
      ),
   ),

                ListTile(
  title: RichText(
    text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: [
        TextSpan(
          text: 'رقم الهاتف: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '${recyclingCenter.phoneNo}',
          style: TextStyle(
            fontWeight: FontWeight.normal, // Regular font weight
          ),
        ),
      ],
    ),
  ),
),
     
                ListTile(
  title: RichText(
    text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: [
        TextSpan(
          text: 'النفايات المستقبلة: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '${recyclingCenter.type}',
          style: TextStyle(
            fontWeight: FontWeight.normal, // Regular font weight
          ),
        ),
      ],
    ),
  ),
),

                         ListTile(
                        title: Text(
                          'أوقات العمل:',
                          style: TextStyle(
            fontWeight: FontWeight.bold, // Regular font weight
          ),   
                          
     ),
                        
                           subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أيام الأسبوع : $WeekdaysFormattedFromHour $WeekdaysFormattedToHour',
            style: TextStyle(color: Colors.black),
          ),
    (FriFormattedFromHour == "مغلق" ||FriFormattedToHour == "مغلق") // if center close then show close
    ? Text(
        'الجمعة: $FriFormattedFromHour',
        style: TextStyle(color: Colors.black),
      )
    : Text(
        'الجمعة: $FriFormattedFromHour $FriFormattedToHour',
        style: TextStyle(color: Colors.black),
      ),
          
          (SatFormattedFromHour == "مغلق" ||SatFormattedToHour == "مغلق")
    ? Text(
        'السبت: $SatFormattedFromHour',
        style: TextStyle(color: Colors.black),
      )
    : Text(
        'السبت: $SatFormattedFromHour $SatFormattedToHour',
        style: TextStyle(color: Colors.black),
      ),
         
        ],
      ),
                      ),
                      ListTile(
                    // leading: Icon(Icons.info),
                    title: GestureDetector(
                     onTap: () {
                     final String? websiteUrl = recyclingCenter.websiteURL;
                   if (websiteUrl != null) {
                  final Uri websiteUri = Uri.parse(websiteUrl);
                 _launch(websiteUri);
               } else {
                 print('Website URL is null or invalid.');
              }
                 },
                child: RichText(
                 text: TextSpan(
                children: [
               TextSpan(
                text: 'موقع المركز: ',
               style: TextStyle(
                color: Colors.black, 
            fontWeight: FontWeight.bold, // Regular font weight
            ),
          ),
              TextSpan(
               text: 'اضغط هنا',
              style: TextStyle(
               color: Colors.blue,
            ),
          ),
        ],
      ),
    ),
  ),
),
       buildCarousel([recyclingCenter.logoURL ?? '', recyclingCenter.imageURL ?? '']), // to call widget for image slider

                    ],
                  ),
                );
              },
            ),

          );
        },
      );
    },
  );
}


// featch center data from firebase
void _fetchRecyclingCenter(){
  // Use data from garbageDatabase here
  final recyclingCenterDB = recyclingCentersDatabase();
  final recyclingCenterStream = recyclingCenterDB.getRecyclingCenters();

  recyclingCenterStream.listen((List<recyclingcenter> recyclingcenters) async{

_markers.clear();
  // Filter recyclingcenters based on the selected item in the dropdown

    final filteredRecyclingCenters = dropdownValue != "الكل"
    ? recyclingcenters.where((center) => center.type!.contains(dropdownValue)).toList()
    : recyclingcenters;

    for (final recyclingcenter in filteredRecyclingCenters) {
    final lat = recyclingcenter.location?.latitude; // Use the null-aware operator
     final long = recyclingcenter.location?.longitude; // Use the null-aware operator
     final Uint8List markerIcon =  await getBytesFromAssets("images/recyclingcenter.png", 100);
      if (lat != null && long != null) {
              
        
        final marker = Marker(
          markerId: MarkerId("${recyclingcenter.name}"),
          position: LatLng(lat, long),
          icon:markerIcon != null ? BitmapDescriptor.fromBytes(markerIcon) : BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
        title: "اسم المركز",
        snippet:recyclingcenter.name , // Display the size in the info window
      ),
      onTap: () {
     
    _showMarkerDetails(context, recyclingcenter); // Show details when the marker is tapped
          },
        );

        setState(() {
          _markers.add(marker);
        }); 
     }

    }
  });
}
// show map controller
void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
// filtering cenetr baed on waste type
Widget filterMarkers(BuildContext context) {
  const List<String> list = <String>[ "الكل", 'بلاستيك' , "ورق" , "زجاج" , "كرتون" , "معدن" , "إلكترونيات" , "أخرى"];
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
            });
            _fetchRecyclingCenter(); 
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
    return StreamProvider<List<recyclingcenter>>.value(
      initialData: [],
      value:recyclingCenterDB.getRecyclingCenters(),
      
      child: Scaffold(
        appBar: AppBar(
        
        title: Text(
      'مراكز إعادة التدوير', // Add a comma here
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
          child: GoogleMap(
           zoomGesturesEnabled: true,
           myLocationButtonEnabled: true,
           scrollGesturesEnabled: true,
           rotateGesturesEnabled:false,
           tiltGesturesEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
        
           onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentLocation?.latitude ?? 0.0,
                      _currentLocation?.longitude ?? 0.0,
                    ),
                    zoom: 11.5,
                  ),
                  markers: _markers, // Set of markers
                  

                  gestureRecognizers: Set()
          ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
          ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
          ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
          ..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer())),
          ),
           
        ),
    
      bottomNavigationBar: BottomBar(),
      ),
    );
  }
}

