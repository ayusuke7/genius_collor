import 'package:flutter/material.dart';
import 'game.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Genius Color',
      theme: ThemeData(
        primaryColor: Color(0xFF424242),
      ),
      home: GamePage(),
    );
  }
}
