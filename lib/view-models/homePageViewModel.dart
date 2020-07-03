import 'dart:async';
import 'dart:io';
import 'package:date_util/date_util.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

class HomePageViewModel extends BaseViewModel {
  File imageFile;

  String nama;
  int tanggal, bulan, tahun;
  LatLng current;

  DateTime now = DateTime.now();

  List<String> listDay = List();
  List<String> listMonth = List();
  List<String> listYear = List();

  Completer<GoogleMapController> _controller = Completer();
  Completer<GoogleMapController> get controller => _controller;

  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1920, maxWidth: 1080);

    imageFile = image;
    notifyListeners();
  }

  get pilihGallery => () => _pilihGallery();

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

  saveToSQL() async {
    try {
      var uri = Uri.parse(StringApp().addUser);
      var request = http.MultipartRequest("POST", uri);

      request.fields['nama'] = nama;
      request.fields['tanggal'] = tanggal.toString();
      request.fields['bulan'] = bulan.toString();
      request.fields['tahun'] = tahun.toString();
      request.fields['longitudinal'] = current.longitude.toString();
      request.fields['latitude'] = current.latitude.toString();

      if (imageFile != null) {
        var stream =
            http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();

        request.files.add(http.MultipartFile("image", stream, length,
            filename: path.basename(imageFile.path)));

        var response = await request.send();

        if (response.statusCode > 2) {
          print("image Upload");
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CheckList(),
          //   ),
          // );
        } else {
          print("image failed");
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
