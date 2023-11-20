import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/auth.dart';
import 'package:taboua_app/messages/confirm.dart';
import 'package:taboua_app/messages/success.dart';

class PasswordChange extends StatefulWidget {
  const PasswordChange({Key? key});

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _passwordErrorText = "";
  String _confirmPasswordErrorText = "";
  String _confirmationMessage = "";

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
    } else if (!_isPasswordValid(value)) {
      setState(() {
        _passwordErrorText =
            "كلمة السر يجب أن تحتوي على 8 أحرف على الأقل مع حرف كبير وحرف صغير ورقم وحرف خاص";
      });
    } else {
      setState(() {
        _passwordErrorText = "";
      });
    }
  }

  bool _isPasswordValid(String password) {
    final passwordPattern = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$!%^&*?])[A-Za-z\d@#$!%^&*?]{8,}$');
    return passwordPattern.hasMatch(password);
  }

  void _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _confirmPasswordErrorText = "يرجى تأكيد كلمة السر";
      });
    } else if (value != _passwordController.text) {
      setState(() {
        _confirmPasswordErrorText = "كلمة السر غير متطابقة";
      });
    } else {
      setState(() {
        _confirmPasswordErrorText = "";
      });
    }
  }

  void _showConfirmationDialog() {
  final newPassword = _passwordController.text;
  final newPassword2 = _confirmPasswordController.text;

  if (newPassword.isEmpty) {
    setState(() {
      _passwordErrorText = "كلمة السر مطلوبة";
    });
  }

  if (newPassword2.isEmpty) {
    setState(() {
      _confirmPasswordErrorText = "تأكيد كلمة السر مطلوب";
    });
  }
  else {
    ConfirmationDialog.show(
      context,
      "تأكيد تغيير كلمة السر",
      "هل أنت متأكد أنك ترغب في تغيير كلمة السر؟",
      _changePassword,
    );

  }
    
  }

  




 void _changePassword() async {
  final newPassword = _passwordController.text;

  // Additional validation logic for password strength can be added here

  if (_passwordErrorText.isEmpty && _confirmPasswordErrorText.isEmpty) {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.updatePassword(newPassword);
      SuccessMessageDialog.show(
        context,
        "تم تغيير كلمة السر بنجاح!",
        '/profile_page', 
      );
      setState(() {
        _passwordErrorText = ""; // Clear error messages
        _confirmPasswordErrorText = ""; // Clear error messages
      });
    } catch (e) {
      print(e);
      // Handle password change failure if needed
    }
  } else {
    // Clear confirmation message if there are validation errors
    setState(() {
      _confirmationMessage = "";
    });
  }
}


  void _goToProfilePage() {
    //Navigator.of(context).pushNamed('/profile_page');
     navigatorKey.currentState?.pushReplacementNamed('/profile_page');
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
                  "تغيير كلمة السر",
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
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'كلمة السر الجديدة',
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'تأكيد كلمة السر الجديدة',
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
                        ),
                        onChanged: (value) {
                          _validateConfirmPassword(value);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                _confirmPasswordErrorText,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              Text(
                _confirmationMessage,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _showConfirmationDialog,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF97B980),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'تغيير كلمة السر',
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
                  onTap: _goToProfilePage,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xff07512d),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        'العودة إلى الصفحة الشخصية',
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
