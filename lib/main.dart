import 'package:flutter/material.dart';
import 'package:flutter_maps/views/pages/HomePage.dart';
import 'package:flutter_maps/views/pages/addUser.dart';
import 'package:flutter_maps/views/pages/detailUser.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DetailUser(),
    );
  }
}

class Splashscreen extends StatefulWidget {
  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    if (!isOpen)
      Future.delayed(Duration(seconds: 2))
          .then((_) => setState(() => isOpen = true))
          .then(
        (_) {
          Future.delayed(Duration(seconds: 1)).then(
            (_) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            ),
          );
        },
      );
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: mediaQuery.height,
            width: mediaQuery.width,
            color: Colors.blue,
          ),
          isOpen
              ? Center(
                  child: Text(
                    "Welcome !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
