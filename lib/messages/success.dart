// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taboua_app/auth.dart';

class SuccessMessageDialog {
  static void show(BuildContext context, String successMessage, String destinationPage) {
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
                  "تم بنجاح",
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  successMessage,
                  style: GoogleFonts.balooBhaijaan2(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    navigatorKey.currentState?.pushReplacementNamed(destinationPage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF97B980),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "استمرار",
                    style: GoogleFonts.balooBhaijaan2(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
