import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_maps/views/pages/bioData.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckList extends StatefulWidget {
  final LatLng currentLatLng;
  final File file;
  final String nama;
  final int tanggal, bulan, tahun;
  CheckList(
      {this.file,
      this.nama,
      this.tanggal,
      this.bulan,
      this.tahun,
      this.currentLatLng});
  @override
  _CheckListState createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => BioData(
                  file: widget.file,
                  nama: widget.nama,
                  tanggal: widget.tanggal,
                  bulan: widget.bulan,
                  tahun: widget.tahun,
                  currentLatLng: widget.currentLatLng,
                )),
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
    ));
  }
}
