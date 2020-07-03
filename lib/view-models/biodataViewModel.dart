import 'dart:async';
import 'dart:io';

import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

class BiodataViewModel extends BaseViewModel {
  File imageFile;
  TextEditingController namaController = TextEditingController();
  int tanggal, bulan, tahun;
  List<String> listDay = List();
  List<String> listMonth = List();
  List<String> listYear = List();
  DateTime now = DateTime.now();

  Completer<GoogleMapController> _controller = Completer();
  get controller => _controller;

  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1920, maxWidth: 1080);

    imageFile = image;
    notifyListeners();
  }

  get pilihGallery => _pilihGallery();

  setDay() {
    var res = DateUtil().daysInMonth(
        bulan != null ? bulan : now.month, tahun != null ? tahun : now.year);
    if (tanggal != null) if (tanggal > res) tanggal = null;
    for (int i = 1; i <= res; i++) {
      listDay.add(i.toString());
    }
  }

  _setDate() {
    setDay();

    //Month
    for (int i = 1; i <= 12; i++) {
      listMonth.add(i.toString());
    }

    //Year
    for (int i = 1950; i <= DateTime.now().year; i++) {
      listYear.add(i.toString());
    }
  }

  get setDate => _setDate();
}
