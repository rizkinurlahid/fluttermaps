import 'dart:async';
import 'dart:io';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:flutter_maps/views/widgets/maps.dart';
import 'package:flutter_maps/views/widgets/successLoad.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

class AddUserViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  get scaffoldKey => _scaffoldKey;

  File _imageFile;
  get imageFile => _imageFile;

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

  bool _isLoading = false;
  get isLoading => _isLoading;

  bool _isError = false;
  get isError => _isError;

  double _height = 0;
  get height => _height;

  LatLng _current;
  get currentLatLng => _current;

  String _currentLocation;
  String get currentLocation => _currentLocation;

  Marker _marker;
  get marker => _marker;

  DateTime now = DateTime.now();
  List<String> listDay = List();
  List<String> listMonth = List();
  List<String> listYear = List();

  Completer<GoogleMapController> _controller = Completer();
  Completer<GoogleMapController> get controller => _controller;

  TextEditingController _namaController;
  get namaController => _namaController;

  _initial() {
    _setDate();
    _getPrefs();
  }

  get initial => _initial();

  _pilihGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1920, maxWidth: 1080);

    _imageFile = image;
    notifyListeners();
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

  _saveToSQL() async {
    try {
      if (imageFile != null) {
        _isLoading = true;
        notifyListeners();
        String resTanggal = _tanggal < 10 ? '0$_tanggal' : '$_tanggal';
        String resbulan = _bulan < 10 ? '0$_bulan' : '$_bulan';

        var uri = Uri.parse(StringApp().addUser);
        var request = http.MultipartRequest("POST", uri);
        var stream =
            http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();

        request.fields['nama'] = nama;
        request.fields['tanggal_lahir'] = '$resTanggal-$resbulan-$_tahun';
        request.fields['latitude'] = '${_current.latitude}';
        request.fields['longitude'] = '${_current.longitude}';

        request.files.add(http.MultipartFile("image", stream, length,
            filename: path.basename(imageFile.path)));

        var response = await request.send();

        if (response.statusCode > 2) {
          _isLoading = false;
          _isError = false;
          notifyListeners();
          print("Success to Add User");

          Navigator.push(
              _scaffoldKey.currentContext,
              MaterialPageRoute(
                  builder: (context) => SuccessLoad(
                        isDelete: false,
                      )));
        } else {
          _isLoading = false;
          _isError = true;
          _height = 30;
          Future.delayed(Duration(seconds: 3)).then((_) {
            _height = 0;
            _isError = false;
            notifyListeners();
          });
          notifyListeners();
          print("Failed to Add User");
        }
      }
    } catch (e) {
      _isLoading = false;
      _isError = true;
      _height = 30;
      Future.delayed(Duration(seconds: 3)).then((_) {
        _height = 0;
        _isError = false;
        notifyListeners();
      });
      notifyListeners();
      debugPrint('Error: $e');
    }
    notifyListeners();
  }

  get saveToSQL => _saveToSQL();

  _savePrefs() async {
    String resTanggal = _tanggal < 10 ? '0$_tanggal' : '$_tanggal';
    String resbulan = _bulan < 10 ? '0$_bulan' : '$_bulan';

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("image", _imageFile.path);
    preferences.setString("nama", _nama);
    preferences.setString("tanggal_lahir", '$resTanggal-$resbulan-$_tahun');
    notifyListeners();
  }

  _getPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (pref.getString('image') != null && pref.getString('latitude') != null) {
      int getTanggal =
          int.parse(pref.getString('tanggal_lahir').substring(0, 2));
      int getBulan = int.parse(pref.getString('tanggal_lahir').substring(3, 5));
      int getTahun = int.parse(pref.getString('tanggal_lahir').substring(6));
      double getLatitude = double.parse(pref.getString('latitude'));
      double getLongitude = double.parse(pref.getString('longitude'));

      _imageFile = File(pref.getString('image'));
      _nama = pref.getString('nama');
      _tanggal = getTanggal;
      _bulan = getBulan;
      _tahun = getTahun;
      _current = LatLng(getLatitude, getLongitude);

      getPlacemark(latLng: LatLng(getLatitude, getLongitude));
      Future.delayed(Duration(seconds: 3)).then((_) => _makeMarker());

      _namaController = TextEditingController(text: _nama);
      pref.clear();
    }
    notifyListeners();
  }

  _makeMarker() {
    _marker = Marker(
        markerId: MarkerId('m2'),
        position: _current,
        draggable: false,
        infoWindow: InfoWindow(title: _currentLocation),
        zIndex: 2,
        flat: true,
        icon: BitmapDescriptor.defaultMarker);
    notifyListeners();
  }

  _onValidateData() {
    if (_imageFile != null &&
        _nama != null &&
        _tanggal != null &&
        _bulan != null &&
        _tahun != null) {
      _savePrefs();
      Navigator.push(
        _scaffoldKey.currentContext,
        MaterialPageRoute(
          builder: (context) => Maps(
            isView: false,
            isFromUpdate: false,
          ),
        ),
      );
    } else {
      _height = 30;
      notifyListeners();
      Future.delayed(Duration(seconds: 3)).then((_) {
        _height = 0;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  get onValidateData => _onValidateData();

  getPlacemark({LatLng latLng}) async {
    List<Placemark> placemarkCurrent = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    placemarkCurrent.forEach((Placemark f) {
      _currentLocation =
          '${f.thoroughfare} ${f.subThoroughfare}, ${f.subLocality}, ${f.locality}, ${f.subAdministrativeArea} ${f.postalCode}, ${f.administrativeArea}, ${f.country}';
      notifyListeners();
    });
  }
}
