import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jebril_app/screens/home.dart';
class SplashScreen extends StatefulWidget {
  static const String routeName = "splash_screen";
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHomePage();
  }
  void _navigateToHomePage() {
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context,HomeScreen.routeName);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration:const BoxDecoration(
                image:DecorationImage(
                  image: AssetImage('assets/images/Layer 1.png'),
                  fit: BoxFit.cover,
                )
            ),
          ),
          Center(child: Image.asset("assets/images/logo.png"))
        ],
      )
    );
  }
}
