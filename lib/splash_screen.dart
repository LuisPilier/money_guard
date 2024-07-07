import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_one.dart'; // Importa tu pantalla de onboarding

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 2 seconds before navigating to OnboardingOne
    Timer(
      Duration(seconds: 2),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingOne()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate sizes based on screen dimensions
    final fontSize = screenWidth * 0.08; // 8% of screen width
    final iconSize = screenWidth * 0.08; // 8% of screen width
    final horizontalPadding = screenWidth * 0.1; // 10% of screen width

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF5AB2FF),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'MoneyGuard',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10), // Add space between text and icon
                    Icon(
                      Icons.shield,
                      size: iconSize, // Adjust size based on screen width
                      color: Colors.white,
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
