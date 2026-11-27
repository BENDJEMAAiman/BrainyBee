
import 'package:flutter/material.dart';
import 'package:memory_card_game/menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Memory Master',

      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF3F6FF),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),

      // Display the Memory Master menu when the app starts
      home: MenuScreen(),
    );
  }
}
