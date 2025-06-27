import 'package:flutter/material.dart';
import 'package:rabea2/home.dart';
import 'package:rabea2/splash_screen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(cameras: []),
    );
  }
}
