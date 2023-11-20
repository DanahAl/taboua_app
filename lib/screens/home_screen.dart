import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_bar.dart';
import 'package:taboua_app/screens/bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc['firstName'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),

        appBar: AppBar(
          backgroundColor: Color(0xFFE9E9E9),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          toolbarHeight: 140, // Adjust the toolbar height
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "مرحبا $userName",
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 35.0,
                    color: Color(0xFF363436),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.asset(
                  'images/logo.png', 
                  width: 90,
                  height: 90,
                ),
              ),
            ],
          ),

          leading: GestureDetector(
          onTap: () {
            // Handle sign out
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/login_screen');
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(
              Icons.logout, // You can use any logout icon from the Icons class
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
        ),


     
     body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      ServiceButton(
        title: "حاويات النفايات",
        iconPath: "images/bin.png",
        routeName: '/view_garbage_bins',
      ),
      ServiceButton(
        title: "طلبات الحاويات",
        iconPath: "images/bin1.png",
        routeName: '/view_requests',

      ),
      ServiceButton(
        title: "مراكز اعاده التدوير",
        iconPath: "images/recyling.png",
        routeName: '/view_recycling_centers',
      ),
      ServiceButton(
        title: "تصنيف النفايات",
        iconPath: "images/scan1.png",
        routeName: '/',
      ),
      ServiceButton(
        title: "البلاغات",
        iconPath: "images/complaints.png",
        routeName: '/',
      ),
    ],
  ),
),

     /* bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Color(0xFF97B980),
        //notchMargin: 5.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white ),
              onPressed: () {
                Navigator.pushNamed(context, '/profile_page');
              },
            ),
            Container(
              width: 60.0,
              height: 60.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white ,
              ),
              child: Center(
          child: IconButton(
            icon: Image.asset(
              'images/scan.png', 
              width: 70.0, 
              height: 70.0, 
              color: Color(0xFF97B980),
            ),
            onPressed: () {
              // Add path here
            },
          ),
        ),
      ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white ),
              onPressed: () {
                Navigator.pushNamed(context, '/home_screen');
              },
            ),
          ],
        ),
      ), */

   bottomNavigationBar: BottomBar(
    scanIconColor: Color(0xFF97B980),
    scanIconBackgroundColor : Colors.white,
    personIconColor : Colors.white,
    homeIconColor : Colors.white,
    backgroundColor : Color(0xFF97B980),
   ),

    );
  }
}



  @override
  class ServiceButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final String routeName;

  const ServiceButton({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320, // Adjust the width as per your preference
      height: 80, // Reduce the height of the buttons
      margin: const EdgeInsets.only(bottom: 20), // Add margin between the buttons
      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(19),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Row(
          
          mainAxisAlignment: MainAxisAlignment.end, // Align the text and icon to the right
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5), // Adjust the space between text and icon
              child: Text(
                title,
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF363436),
                  ),
                ),
                textAlign: TextAlign.right,
              ),
            ),

          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                iconPath,
                width: 45, // Adjust the icon size
                height: 45, // Adjust the icon size
                //color: const Color(0xFF97B980),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

