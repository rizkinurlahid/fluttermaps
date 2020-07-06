import 'package:flutter/material.dart';
import 'package:flutter_maps/views/pages/HomePage.dart';
import 'package:flutter_maps/views/pages/detailUser.dart';

class SuccessLoad extends StatelessWidget {
  final bool isDelete;
  SuccessLoad({@required this.isDelete});
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1500)).then((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                (!isDelete) ? DetailUser(isPrefs: false) : HomePage()),
        (Route<dynamic> route) => false,
      );
    });
    return Scaffold(
      body: Center(
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
