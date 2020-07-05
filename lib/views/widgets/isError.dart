import 'package:flutter/material.dart';

class IsError extends StatefulWidget {
  final double height;
  final String text;
  IsError({@required this.height, @required this.text});
  @override
  _IsErrorState createState() => _IsErrorState();
}

class _IsErrorState extends State<IsError> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red,
            ),
            child: Center(
              child: Text(
                widget.text,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
