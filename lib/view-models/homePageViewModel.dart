import 'dart:convert';

import 'package:flutter_maps/models/userModel.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;

class HomePageViewModel extends BaseViewModel {
  bool _isLoadingScreen = true;
  bool get isLoadingScreen => _isLoadingScreen;

  final List<UserModel> _list = List<UserModel>();
  List<UserModel> get list => _list;

  String _location;
  String get location => _location;

  _getUsers() async {
    _list.clear();
    _isLoadingScreen = true;
    notifyListeners();

    final response = await http.get(StringApp().getUser);
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
        // _list.add(res);
        if (res.image != '05072020162817' &&
            res.image != '05072020164149' &&
            res.image != '05072020164548' &&
            res.image != '05072020174347' &&
            res.image != '05072020183029') {
          _list.add(res);
        }
        getPlacemark(
            latLng: LatLng(
                double.parse(res.latitude), double.parse(res.longitude)));
        _isLoadingScreen = false;
        notifyListeners();
      });
    } else {
      _isLoadingScreen = false;
      notifyListeners();
    }
  }

  get getUsers => _getUsers();

  getPlacemark({LatLng latLng}) async {
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    placemark.forEach((Placemark f) {
      _location =
          '${f.thoroughfare} ${f.subThoroughfare}, ${f.subLocality}, ${f.locality}, ${f.subAdministrativeArea} ${f.postalCode}, ${f.administrativeArea}, ${f.country}';
      // print(f.thoroughfare);
      // print(f.subThoroughfare);
      // print(f.subLocality);
      // print(f.locality);
      // print(f.subAdministrativeArea); // print(f.postalCode);
      // print(f.administrativeArea);
      // print(f.country);
      notifyListeners();
    });
  }
}
