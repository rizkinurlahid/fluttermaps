import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_maps/models/userModel.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:flutter_maps/views/widgets/maps.dart';
import 'package:flutter_maps/views/widgets/successLoad.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:async/async.dart';

class DetailUserViewModel extends BaseViewModel {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  get scaffoldKey => _scaffoldKey;
  File _imageFile;
  get imageFile => _imageFile;
  TextEditingController _namaController;
  TextEditingController get namaController => _namaController;
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

  String _id;
  String get id => _id;

  String _imgUrl;
  get imgUrl => _imgUrl;

  String _currentLocation;
  get currentLocation => _currentLocation;

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

  bool _isLoading = false;
  get isLoading => _isLoading;

  bool _isLoadingScreen = true;
  get isLoadingScreen => _isLoadingScreen;

  bool _isEditable = false;
  get isEditable => _isEditable;
  setIsEditable(value) {
    _isEditable = value;
    notifyListeners();
  }

  bool _isError = false;
  get isError => _isError;

  Marker _marker;
  get marker => _marker;

  double _height = 0;
  get height => _height;

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

  _updateData() async {
    try {
      _isLoading = true;
      notifyListeners();
      var uri = Uri.parse(StringApp().editUser);
      var request = http.MultipartRequest("POST", uri);

      String resTanggal = _tanggal < 10 ? '0$_tanggal' : '$_tanggal';
      String resbulan = _bulan < 10 ? '0$_bulan' : '$_bulan';
      request.fields['id'] = _id;
      request.fields['nama'] = nama;
      request.fields['tanggal_lahir'] = '$resTanggal-$resbulan-$_tahun';
      request.fields['latitude'] = '${_currentLatLng.latitude}';
      request.fields['longitude'] = '${_currentLatLng.longitude}';

      if (_imageFile != null) {
        var stream =
            http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();

        request.files.add(http.MultipartFile("image", stream, length,
            filename: path.basename(imageFile.path)));

        var response = await request.send();

        if (response.statusCode > 2) {
          _isLoading = false;
          _isError = false;
          _isLoadingScreen = true;
          _isEditable = false;
          notifyListeners();
          print("Success to Update User");

          getUserById(id: _id);
        } else {
          _isLoading = false;
          _isError = true;
          _height = 30;
          _isLoadingScreen = true;
          _isEditable = false;
          _imageFile = null;
          Future.delayed(Duration(seconds: 3)).then((_) {
            _height = 0;
            _isError = false;
            notifyListeners();
          });
          notifyListeners();
          print("Failed to Add User");
          getUserById(id: _id);
        }
      } else {
        request.fields['image'] = _imgUrl;
        var response = await request.send();

        if (response.statusCode > 2) {
          _isLoading = false;
          _isError = false;
          _isLoadingScreen = true;
          _isEditable = false;
          notifyListeners();
          print("Success to Update User");

          getUserById(id: _id);
        } else {
          _isLoading = false;
          _isError = true;
          _height = 30;
          _isLoadingScreen = true;
          _isEditable = false;
          _imageFile = null;
          Future.delayed(Duration(seconds: 3)).then((_) {
            _height = 0;
            _isError = false;
            notifyListeners();
          });
          notifyListeners();
          print("Failed to Update User");
          getUserById(id: _id);
        }
      }
    } catch (e) {
      _isLoading = false;
      _isError = true;
      _height = 30;
      _isLoadingScreen = true;
      _isEditable = false;
      _imageFile = null;
      Future.delayed(Duration(seconds: 3)).then((_) {
        _height = 0;
        _isError = false;
        notifyListeners();
      });
      notifyListeners();
      debugPrint('Error: $e');
      getUserById(id: _id);
    }
    notifyListeners();
  }

  get updateData => _updateData();

  _deleteData() async {
    try {
      _isLoading = true;
      notifyListeners();
      var uri = Uri.parse(StringApp().deleteUser);
      var request = http.MultipartRequest("POST", uri);

      request.fields['id'] = _userModel.id;

      var response = await request.send();

      if (response.statusCode > 2) {
        _isLoading = false;
        _isError = false;
        notifyListeners();
        print("Success to Delete User");
        Navigator.push(
            _scaffoldKey.currentContext,
            MaterialPageRoute(
                builder: (context) => SuccessLoad(
                      isDelete: true,
                    )));
      } else {
        _isLoading = false;
        _isError = true;
        _height = 30;
        _isLoadingScreen = true;
        Future.delayed(Duration(seconds: 3)).then((_) {
          _height = 0;
          _isError = false;
          notifyListeners();
        });
        notifyListeners();
        print("Failed to Delete User");
        getUserById(id: _userModel.id);
      }
    } catch (e) {
      _isLoading = false;
      _isError = true;
      _height = 30;
      _isLoadingScreen = true;
      Future.delayed(Duration(seconds: 3)).then((_) {
        _height = 0;
        _isError = false;
        notifyListeners();
      });
      notifyListeners();
      print("Failed to Delete User");
      getUserById(id: _userModel.id);
    }
  }

  get deleteData => _deleteData();

  getUserById({String id}) async {
    final response = await http.post(StringApp().detailUser, body: {'id': id});

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
        _id = res.id;
        _imgUrl = res.image;
        _isLoadingScreen = false;

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
        _id = res.id;
        _imgUrl = res.image;
        _isLoadingScreen = false;
        if (_userModel != null) _afterLoading();
        notifyListeners();
      });
    }
  }

  get getUserByLastAdded => _getUserByLastAdded();

  _afterLoading() {
    getPlacemark(
        latLng: LatLng(double.parse(_userModel.latitude),
            double.parse(_userModel.longitude)));
    _namaController = TextEditingController(text: _userModel.nama);
    _tanggal = int.parse(_userModel.tanggalLahir.substring(0, 2));
    _bulan = int.parse(_userModel.tanggalLahir.substring(3, 5));
    _tahun = int.parse(_userModel.tanggalLahir.substring(6));
    _currentLatLng = LatLng(
        double.parse(_userModel.latitude), double.parse(_userModel.longitude));
    Future.delayed((Duration(seconds: 3))).then((_) {
      _marker = Marker(
          markerId: MarkerId('m3'),
          position: _currentLatLng,
          draggable: false,
          infoWindow: InfoWindow(title: _currentLocation),
          flat: true,
          icon: BitmapDescriptor.defaultMarker);
      notifyListeners();
    });
  }

  _savePrefs() async {
    String resTanggal = _tanggal < 10 ? '0$_tanggal' : '$_tanggal';
    String resbulan = _bulan < 10 ? '0$_bulan' : '$_bulan';

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("id", _id);
    preferences.setString("image", _imageFile?.path ?? null);
    preferences.setString("imageUrl", _userModel.image ?? null);
    preferences.setString("nama", _namaController.text);
    preferences.setString("tanggal_lahir", '$resTanggal-$resbulan-$_tahun');
    notifyListeners();
  }

  _getPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    int getTanggal = int.parse(pref.getString('tanggal_lahir').substring(0, 2));
    int getBulan = int.parse(pref.getString('tanggal_lahir').substring(3, 5));
    int getTahun = int.parse(pref.getString('tanggal_lahir').substring(6));
    double getLatitude = double.parse(pref.getString('latitude'));
    double getLongitude = double.parse(pref.getString('longitude'));

    getPlacemark(latLng: LatLng(getLatitude, getLongitude));

    _id = pref.getString('id');
    _imageFile =
        pref.getString('image') != null ? File(pref.getString('image')) : null;
    _imgUrl = pref.getString('imageUrl');
    _nama = pref.getString('nama');
    _tanggal = getTanggal;
    _bulan = getBulan;
    _tahun = getTahun;
    _currentLatLng = LatLng(getLatitude, getLongitude);
    notifyListeners();
    Future.delayed((Duration(seconds: 3))).then((_) {
      _makeMarker();
    });
    _namaController = TextEditingController(text: _nama);
    pref.clear();
    _isLoadingScreen = false;
    notifyListeners();
  }

  get getPrefs => _getPrefs();

  _makeMarker() {
    _marker = Marker(
        markerId: MarkerId('m2'),
        position: _currentLatLng,
        draggable: false,
        zIndex: 2,
        infoWindow: InfoWindow(title: _currentLocation),
        flat: true,
        icon: BitmapDescriptor.defaultMarker);
    notifyListeners();
  }

  _onValidateData() {
    if (_nama != null && _tanggal != null && _bulan != null && _tahun != null) {
      _savePrefs();
      Navigator.push(
        _scaffoldKey.currentContext,
        MaterialPageRoute(
          builder: (context) => Maps(
            isView: false,
            isFromUpdate: true,
          ),
        ),
      );
      notifyListeners();
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
