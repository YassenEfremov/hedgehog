import 'package:flutter/material.dart';

import 'main_page.dart';


void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue.shade900),
      ),
      home: MainPage(),
    );
  }
}
