import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taboua_app/auth.dart';
import 'package:taboua_app/screens/home_screen.dart';
import 'package:taboua_app/screens/login_screen.dart';
import 'package:taboua_app/screens/profile_page.dart';
import 'package:taboua_app/screens/signup_screen.dart';
import 'package:taboua_app/screens/view_garbage_bins.dart';
import 'package:taboua_app/screens/view_recycling_centers.dart';
import 'package:taboua_app/screens/profile_page.dart';
import 'package:taboua_app/screens/change_password.dart';
import 'package:taboua_app/Services/garbagebinRequestDB.dart';
import 'package:google_fonts/google_fonts.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
       useMaterial3: true,
       fontFamily: 'BalooBhaijaan2',
    ),
    home: Auth(),
  );
}

}


/*class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      
      routes: {
        '/': (context) => const HomeScreen(),
        '/view_garbage_bins': (context) => const viewGrabageBin(),
        '/view_recycling_centers':(context) => const viewRecyclingCenters(),
        '/home_screen':(context) => const HomeScreen(),
        '/login_screen':(context) => const LoginScreen(),
        '/signup_screen':(context) => const SignupScreen(),
        '/profile_page': (context) => ProfilePage(user: FirebaseAuth.instance.currentUser!),
        '/password_change': (context) => PasswordChange(),
        '/viewRequests': (context) => viewRequests(),
        // Add other routes here 
      },
    );
  }
}*/

