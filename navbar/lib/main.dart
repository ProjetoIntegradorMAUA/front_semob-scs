import 'package:flutter/material.dart';
import 'navbar.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Align(
          alignment: Alignment.centerLeft,
          child: SideNavbar(),
        ),
      ),
    );
  }
}
