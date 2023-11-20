import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/auth.dart';
import 'package:taboua_app/messages/success.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _emailController = TextEditingController();
  String _emailErrorText = "";

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    } else if (!_isEmailValid(value)) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني غير صحيح";
      });
    } else {
      setState(() {
        _emailErrorText = "";
      });
    }
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _sendResetPasswordEmail() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _emailErrorText = "البريد الإلكتروني مطلوب";
      });
    } 

    if (_emailErrorText.isEmpty) {
      try {
        // Check if the email exists in Firestore
        QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (query.docs.isEmpty) {
          setState(() {
            _emailErrorText = "البريد الإلكتروني غير مسجل";
          });
          return;
        }

        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        // Display success message
        SuccessMessageDialog.show(
          context,
          "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني",
          '/login_page',
        );

        setState(() {
          _emailErrorText = "";
        });
      } catch (e) {
        print(e);
        // Handle email sending failure if needed
      }
    }
  }

  void _goToLoginPage() {
    // Navigator.of(context).pushNamed('/login_page');
    navigatorKey.currentState?.pushReplacementNamed('/login_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "نسيت كلمة المرور",
                  style: GoogleFonts.balooBhaijaan2(
                    textStyle: const TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'البريد الإلكتروني',
                          prefixIcon: Icon(
                            Icons.email,
                          ),
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
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _sendResetPasswordEmail,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF97B980),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'إرسال رابط إعادة تعيين كلمة المرور',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _goToLoginPage,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xff07512d),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'العودة إلى صفحة تسجيل الدخول',
                        style: GoogleFonts.balooBhaijaan2(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
