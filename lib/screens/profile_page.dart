import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/messages/success.dart';
import 'package:taboua_app/screens/bottom_bar.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  

  ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String lastName = '';
  String userEmail = '';
  bool isEditingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = widget.user;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'];
          lastName = userDoc['lastName'];
          userEmail = user.email!;
        });
      }
    }
  }

 
  Widget _buildProfileItem(String title, String value) {
    return ListTile(
      title: Row(
        children: [
          Spacer(), // Add Spacer to push the title to the right
          Text(
            title,
            style: GoogleFonts.balooBhaijaan2(
              textStyle: const TextStyle(
                fontSize: 24,
              ),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Spacer(), // Add Spacer to push the value to the right
          Text(
            value,
            style: GoogleFonts.balooBhaijaan2(
              textStyle: const TextStyle(
                fontSize: 18,
              ),
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 50),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                " المعلومات الشخصية",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40),

          if (firstName.isEmpty) // Display a loading indicator
            CircularProgressIndicator()
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProfileItem("الاسم الأول", firstName),
                  SizedBox(height: 10),
                  _buildProfileItem("الاسم الأخير", lastName),
                  SizedBox(height: 10),
                 ListTile(
      title: Row(
    mainAxisAlignment: MainAxisAlignment.end, // Align to the right
    children: [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          Navigator.pushNamed(context, '/change_email');
        },
      ),
      Text(
        "البريد الإلكتروني",
        style: GoogleFonts.balooBhaijaan2(
          textStyle: const TextStyle(
            fontSize: 24,
          ),
        ),
        textAlign: TextAlign.right,
      ),
    ],
  ),
  subtitle: Row(
    mainAxisAlignment: MainAxisAlignment.end, // Align to the right
    children: [
      Spacer(), // Add Spacer to align the subtitle to the right
      Text(
        userEmail,
        style: GoogleFonts.balooBhaijaan2(
          textStyle: const TextStyle(
            fontSize: 18,
          ),
        ),
        textAlign: TextAlign.right,
      ),
    ],
  ),
),
                ],
              ),
            ),
          SizedBox(height: 70),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the "Change Password" page
                Navigator.pushNamed(context, '/password_change');
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
                "تغيير كلمة المرور",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                // Handle sign out
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, '/login_screen');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                primary: Colors.red,
                padding: EdgeInsets.all(10),
                minimumSize: Size(300, 10),
              ),
              child: Text(
                "تسجيل الخروج",
                style: GoogleFonts.balooBhaijaan2(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomBar(),
    );
  }
}
