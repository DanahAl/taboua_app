import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  String? _emailErrorText;
  String? _passwordErrorText;
  String? _confirmPasswordErrorText;
  String? _firstNameErrorText;
  String? _lastNameErrorText;
  String? _signupErrorText;

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
        _emailErrorText = null;
      });
    }
  }

  void _validatePassword(String value) {
    if (value.isEmpty) {
      setState(() {
        _passwordErrorText = "كلمة السر مطلوبة";
      });
      return;
    }
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*_\-])[\w!@#\$%^&*_\-]{8,}$',
    );

    if (!passwordRegex.hasMatch(value)) {
      setState(() {
        _passwordErrorText = "كلمة السر يجب أن تحتوي على 8 أحرف على الأقل، حرف كبير و حرف صغير، رقم، رمز";
      });
    } else {
      setState(() {
        _passwordErrorText = null;
      });
    }
  }

  void _validateConfirmPassword(String value) {
    final password = _passwordController.text;
    if (value.isEmpty) {
      setState(() {
        _confirmPasswordErrorText = "يجب تأكيد كلمة السر";
      });
    } else if (value != password) {
      setState(() {
        _confirmPasswordErrorText = "كلمة السر غير متطابقة";
      });
    } else {
      setState(() {
        _confirmPasswordErrorText = null;
      });
    }
  }

  void _validateFirstName(String value) {
    if (value.isEmpty) {
      setState(() {
        _firstNameErrorText = "الاسم الأول مطلوب";
      });
    } else {
      setState(() {
        _firstNameErrorText = null;
      });
    }
  }

  void _validateLastName(String value) {
    if (value.isEmpty) {
      setState(() {
        _lastNameErrorText = "الاسم الأخير مطلوب";
      });
    } else {
      setState(() {
        _lastNameErrorText = null;
      });
    }
  }

Future signup() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

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

    if (firstName.isEmpty) {
      setState(() {
        _firstNameErrorText = "الاسم الأول مطلوب";
      });
    }

    if (lastName.isEmpty) {
      setState(() {
        _lastNameErrorText = "الاسم الأخير مطلوب";
      });
    }

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordErrorText = "يجب تأكيد كلمة السر";
      });
    } 

    try {
      // Check if the email is already in use
      final checkEmailExists =
          await _auth.fetchSignInMethodsForEmail(email);
      if (checkEmailExists.isNotEmpty) {
        setState(() {
          _signupErrorText = "البريد الإلكتروني مستخدم بالفعل";
        });
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a user in the "users" collection
      await usersCollection.doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': userCredential.user!.email,
        'userId': userCredential.user!.uid,
      });

      // Handle successful registration here
      print('User registered successfully.');

      User? user = userCredential.user;

      if (user != null) {
        String userId = user.uid;
      }

      Navigator.pushNamed(context, '/home_screen');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _signupErrorText = "البريد الإلكتروني مستخدم بالفعل";
        });
      }
      print('Error during registration: $e');
    } catch (e) {
      print('Error during registration: $e');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Image.asset(
                    'images/logo.png',
                    height: 160,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '! أنشئ حسابك الآن',
                    style: GoogleFonts.balooBhaijaan2(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 40),
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
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'الاسم الأول',
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                            onChanged: (value) {
                            _validateFirstName(value);
                          },
                          ),
                        ),
                      ),
                    ),
                  ),
                 Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      _firstNameErrorText ?? "",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),



                  
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
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'الاسم الأخير',
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                            onChanged: (value) {
                            _validateLastName(value);
                          },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      _lastNameErrorText ?? "",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),


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
                          child: TextFormField(
                            controller: _emailController,
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
                    _emailErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 10),




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
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'كلمة السر',
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
                    _passwordErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 10),
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
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'تأكيد كلمة السر',
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
                    _confirmPasswordErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                  ),
                  Text(
                    _signupErrorText ?? "",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GestureDetector(
                      onTap: signup,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF97B980),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            ' إنشاء حساب',
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
                          Navigator.pushNamed(context, '/login_screen');
                        },
                        child: Text(
                          'سجل دخولك الآن',
                          style: GoogleFonts.balooBhaijaan2(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        'هل أنت عضو بالفعل؟',
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
      ),
    );
  }
}