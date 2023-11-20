import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  final Color personIconColor;
  final Color scanIconBackgroundColor;
  final Color scanIconColor;
  final Color homeIconColor;
  final Color backgroundColor;

  BottomBar({
    this.personIconColor = const Color(0xFF616264),
    this.scanIconBackgroundColor = const Color(0xFF97B980),
    this.scanIconColor = Colors.white, // Default color of the circle
    this.homeIconColor = const Color(0xFF616264),
    this.backgroundColor = Colors.white, // Default background color
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: backgroundColor, // Set the background color
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            color: personIconColor,
            onPressed: () {
              Navigator.pushNamed(context, '/profile_page');
            },
          ),
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scanIconBackgroundColor,
            ),
            child: Center(
              child: IconButton(
                icon: Image.asset(
                  'images/scan2.png', // Replace with the actual path to your icon
                  width: 60.0, // Adjust the width as needed
                  height: 60.0, // Adjust the height as needed
                  color: scanIconColor, // Customize the color if needed
                ),
                onPressed: () {
                  // Add path here
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            color: homeIconColor,
            onPressed: () {
              Navigator.pushNamed(context, '/home_screen');
            },
          ),
        ],
      ),
    );
  }
}
