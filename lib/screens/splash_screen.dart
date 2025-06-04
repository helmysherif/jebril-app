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
          Positioned.fill(
            child: Image.asset(
              'assets/images/Layer 1.png',
              fit: BoxFit.fill,
            ),
          ),
          Center(child: Image.asset(
           "assets/images/logo.png",
            width:MediaQuery.of(context).size.width * 0.8,
          ))
        ],
      )
    );
  }
}
