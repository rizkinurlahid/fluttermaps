import 'package:flutter/material.dart';

class DropdownMenuItemCustom extends StatefulWidget {
  final value;
  final items;
  final onChanged;
  final hint;

  DropdownMenuItemCustom(
      {@required this.value,
      @required this.items,
      @required this.onChanged,
      @required this.hint});
  @override
  _DropdownMenuItemCustomState createState() => _DropdownMenuItemCustomState();
}

class _DropdownMenuItemCustomState extends State<DropdownMenuItemCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: DropdownButton(
          value: widget.value,
          items: widget.items,
          onChanged: widget.onChanged,
          hint: widget.hint,
          underline: Container(),
        ),
      ),
    );
  }
}
