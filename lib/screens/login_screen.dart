import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/login_screen',
    routes: {
      '/login_screen': (context) => LoginScreen(),
      '/home_screen': (context) => HomeScreen(),
    },
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _emailErrorText = "";
  String _passwordErrorText = "";
  String _loginErrorText = "";

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني غير صحيح";
      });
    } else {
      setState(() {
        _emailErrorText = "";
      });
    }
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
    } else {
      setState(() {
        _passwordErrorText = "";
      });
    }
  }

  Future signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    } 

  if (password.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
    } 



    if (_emailErrorText.isEmpty && _passwordErrorText.isEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushNamed(context, '/home_screen');
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
            // Display the login error message when email or password is incorrect
            setState(() {
              _loginErrorText = "كلمة السر أو البريد الإلكتروني غير صحيحة";
               print(e);
            });
          } 
          else {
            // Handle other errors
            print(e);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 160,
                ),
                SizedBox(height: 20),
                Text(
                  '! سجل دخولك الآن',
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 70),

                // Email input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Add a gray border
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email), // Add an email icon
                          ),
                          onChanged: (value) {
                            _validateEmail(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  _emailErrorText,
                  style: TextStyle(color: Colors.red),
                  //textAlign: TextAlign.right, 
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 20),

                // Password input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey), // Add a gray border
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'كلمة السر',
                            prefixIcon: Icon(
                              Icons.lock,
                              ), // Add a lock icon
                          ),
                          onChanged: (value) {
                            _validatePassword(value);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  _passwordErrorText,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.right, 
                   textDirection: TextDirection.rtl,
                ),

                 // Forgot Password link
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/forgot_password');
        },
        child: Text(
          'نسيت كلمة السر؟',
          style: GoogleFonts.balooBhaijaan2(
            fontSize: 18,
            color: Colors.blue,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl, 
        ),
      ),


                SizedBox(height: 20),

                // Login Error Message
                Text(
                  _loginErrorText,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.right, 
                   textDirection: TextDirection.rtl,
                ),




                SizedBox(height: 65),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF97B980),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          'تسجيل دخول',
                          style: GoogleFonts.balooBhaijaan2(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup_screen');
                      },
                      child: Text(
                        'سجل الآن',
                        style: GoogleFonts.balooBhaijaan2(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      ' ليس لديك حساب؟ ',
                      style: GoogleFonts.balooBhaijaan2(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
