// For using PlatformException
import 'package:agricultura_inteligente/pages/Login/login.dart';

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blueGrey,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark, primarySwatch: Colors.blueGrey),
      themeMode: ThemeMode.dark,
      home: const LoginPage(),
    );
  }
}
