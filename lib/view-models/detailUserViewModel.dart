import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_maps/models/userModel.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:http/http.dart' as http;
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';

class DetailUserViewModel extends BaseViewModel {
  File _imageFile;
  get imageFile => _imageFile;
  TextEditingController _namaController;
  get namaController => _namaController;
  String _nama;
  get nama => _nama;
  setNama(value) {
    _nama = value;
  }

  int _tanggal, _bulan, _tahun;
  get tanggal => _tanggal;
  get bulan => _bulan;
  get tahun => _tahun;
  setTanggal(value) {
    _tanggal = value;
  }

  setBulan(value) {
    _bulan = value;
  }

  setTahun(value) {
    _tahun = value;
  }

  LatLng _currentLatLng;
  get currentLatLng => _currentLatLng;

  List<String> listDay = List();
  List<String> listMonth = List();
  List<String> listYear = List();
  DateTime now = DateTime.now();

  UserModel _userModel;
  UserModel get userModel => _userModel;

  Completer<GoogleMapController> _controller = Completer();
  get controller => _controller;

  bool _isLoading = true;
  get isLoading => _isLoading;

  bool _isEditable = false;
  get isEditable => _isEditable;
  setIsEditable(value) {
    _isEditable = value;
    notifyListeners();
  }

  Marker _marker;
  get marker => _marker;

  _pilihGallery() async {
    if (_isEditable) {
      var image = await ImagePicker.pickImage(
          source: ImageSource.gallery, maxHeight: 1920, maxWidth: 1080);

      _imageFile = image;
      notifyListeners();
    }
  }

  get pilihGallery => () => _pilihGallery();

  setDay() {
    var res = DateUtil().daysInMonth((_bulan != null) ? _bulan : now.month,
        (_tahun != null) ? _tahun : now.year);
    if (_tanggal != null && _tanggal > res) _tanggal = null;
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

  getUserById({String id}) async {
    final response = await http.post(StringApp().detailUser, body: {'id': '8'});

    if (response.statusCode != 404 && response.contentLength != 2) {
      final data = jsonDecode(response.body);
      data.forEach((f) {
        final res = UserModel(
            id: f['id'],
            image: f['image'],
            nama: f['nama'],
            tanggalLahir: f['tanggalLahir'],
            latitude: f['latitude'],
            longitude: f['longitude']);
        _userModel = res;
        _isLoading = false;
        if (_userModel != null) _afterLoading();
        notifyListeners();
      });
    }
  }

  _getUserByLastAdded() async {
    final response = await http.get(StringApp().detailUser);

    if (response.statusCode != 404 && response.contentLength != 2) {
      final data = jsonDecode(response.body);
      data.forEach((f) {
        final res = UserModel(
            id: f['id'],
            image: f['image'],
            nama: f['nama'],
            tanggalLahir: f['tanggal_lahir'],
            latitude: f['latitude'],
            longitude: f['longitude']);
        _userModel = res;
        _isLoading = false;
        if (_userModel != null) _afterLoading();
        notifyListeners();
      });
    }
  }

  get getUserByLastAdded => _getUserByLastAdded();

  _afterLoading() {
    _namaController = TextEditingController(text: _userModel.nama);
    _tanggal = int.parse(_userModel.tanggalLahir.substring(0, 2));
    _bulan = int.parse(_userModel.tanggalLahir.substring(3, 5));
    _tahun = int.parse(_userModel.tanggalLahir.substring(6));
    _currentLatLng = LatLng(
        double.parse(_userModel.latitude), double.parse(_userModel.longitude));
    _marker = Marker(
        markerId: MarkerId('m3'),
        position: _currentLatLng,
        draggable: false,
        flat: true,
        icon: BitmapDescriptor.defaultMarker);
  }
}
