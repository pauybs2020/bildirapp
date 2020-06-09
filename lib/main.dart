import 'package:bildirapp/services/auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bildir',
      theme: ThemeData(
          primaryColor: Color(0xFF2daedc),
          primaryColorBrightness: Brightness.dark,
          brightness: Brightness.light),
      home: AuthService().handleAuth(),
    );
  }
}
