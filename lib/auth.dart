import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taboua_app/screens/change_email.dart';
import 'package:taboua_app/screens/change_password.dart';
import 'package:taboua_app/screens/forgot_password.dart';
import 'package:taboua_app/screens/home_screen.dart';
import 'package:taboua_app/screens/login_screen.dart';
import 'package:taboua_app/screens/profile_page.dart';
import 'package:taboua_app/screens/signup_screen.dart';
import 'package:taboua_app/screens/view_garbage_bins.dart'; 
import 'package:taboua_app/screens/view_recycling_centers.dart';
import 'package:taboua_app/screens/view_requests.dart';



class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  _AuthState createState() => _AuthState();
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/view_garbage_bins': (context) => viewGrabageBin(userId:FirebaseAuth.instance.currentUser!.uid ,),
        '/view_recycling_centers': (context) => viewRecyclingCenters(),
        '/home_screen': (context) => HomeScreen(),
        '/login_screen' :(context) => LoginScreen(),
        '/signup_screen' :(context) => SignupScreen(),
         '/profile_page': (context) => ProfilePage(user: FirebaseAuth.instance.currentUser!),
         '/password_change': (context) => PasswordChange(),
         '/change_email': (context) => EmailChange(),
         '/forgot_password': (context) => ForgetPassword(),
         '/view_requests': (context) => viewRequests(userId: FirebaseAuth.instance.currentUser!.uid),
        // Add other routes here 
      },
    );
  }
}

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
