import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ App logo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:     Image.asset(
                "assets/applogo.png",
                height: 180,
                width: 180,
              ),
            ),

            const SizedBox(height: 30),

            // ✅ App title
            const Text(
              "Bet Tv Plus",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Loading animation
            const CircularProgressIndicator(
              color: Color(0xFF2D73D5),
              strokeWidth: 4,
            ),
          ],
        ),
      ),
    );
  }
}
