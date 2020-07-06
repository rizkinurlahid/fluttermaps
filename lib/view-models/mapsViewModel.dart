import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class MapsViewModel extends BaseViewModel {
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Set<Marker> _markers = HashSet<Marker>();
  Marker _marker;
  Circle _circle;
  LatLng _selectedLatLng;
  // Set<Polyline> _polylines = HashSet<Polyline>();
  // PolylinePoints _polylinePoints = PolylinePoints();
  List<LatLng> _listLatLng = List<LatLng>();
  Map<PolylineId, Polyline> _polylines = {};
  Map<PolylineId, Polyline> get getPolylines => _polylines;
  double _distance;

  String _currentLocation;
  String _destinationLocation;
  get currentLocation => _currentLocation;
  get destinationLocation => _destinationLocation;

  StreamSubscription get locationSubscription => _locationSubscription;
  Completer<GoogleMapController> get controller => _controller;
  get markers => _markers;
  get marker => _marker;
  get circle => _circle;
  get selectedLatLng => _selectedLatLng;
  get polylines => _polylines;
  get listLatLng => _listLatLng;
  get distance => _distance;

  static const LatLng _initialLatLng =
      const LatLng(37.42796133580664, -122.085749655962);
  static const LatLng _destination = const LatLng(-7.559950, 110.811402);
  LatLng get destination => _destination;

  static final CameraPosition _initial = CameraPosition(
    target: _initialLatLng,
    zoom: 14.4746,
  );
  CameraPosition get initialCameraPosition => _initial;

  onCameraMove(CameraPosition position) {
    _selectedLatLng = position.target;
  }

  _onAddMarkerButtonPressed() {
    if (_markers != null) {
      _markers.clear();
      _marker = null;
      _disposeSubscription();
    }
    markers.add(Marker(
        markerId: MarkerId(_selectedLatLng.toString()),
        position: _selectedLatLng,
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  get onAddMarkerButtonPressed => _onAddMarkerButtonPressed();

  _updateMarkerAndCircle(LocationData newLocalData) {
    _selectedLatLng = LatLng(newLocalData.latitude, newLocalData.longitude);
    notifyListeners();
    _marker = Marker(
        markerId: MarkerId('m1'),
        position: _selectedLatLng,
        rotation: newLocalData.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        icon: BitmapDescriptor.defaultMarker);
    _circle = Circle(
        circleId: CircleId('c1'),
        radius: newLocalData.accuracy,
        zIndex: 1,
        strokeColor: Colors.blue,
        center: _selectedLatLng,
        fillColor: Colors.blue.withAlpha(70));
    notifyListeners();
  }

  _getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      final GoogleMapController controller = await _controller.future;

      _updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(newLocalData.latitude, newLocalData.longitude),
                zoom: 19.151926040649414,
              ),
            ),
          );
          _updateMarkerAndCircle(location);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint('Permission Denied');
      }
    }
  }

  get getCurrentLocation => _getCurrentLocation();

  _savePrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("latitude", '${_selectedLatLng.latitude}');
    preferences.setString("longitude", '${_selectedLatLng.longitude}');
  }

  get savePrefs => _savePrefs();

  _disposeSubscription() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
  }

  get disposeSubscription => _disposeSubscription();

  getPolylinesAndDistance({@required LatLng current}) async {
    // PointLatLng currentLocation =
    //     PointLatLng(current.latitude, current.longitude);
    // PointLatLng destinationLocation =
    //     PointLatLng(destination.latitude, destination.longitude);

    // PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
    //     StringApp().apiKey, currentLocation, destinationLocation,
    //     travelMode: TravelMode.driving);
    // result.points.forEach((PointLatLng point) {
    //   _listLatLng.add(LatLng(point.latitude, point.longitude));
    // });

    // PolylineId id = PolylineId('p1');
    // Polyline polyline = Polyline(polylineId: id, points: _listLatLng);
    // _polylines[id] = polyline;
    // notifyListeners();

    // in km
    _distance = await Geolocator().distanceBetween(current.latitude,
            current.longitude, destination.latitude, destination.longitude) /
        1000;
    notifyListeners();
  }

  getPlacemark({LatLng latLng}) async {
    List<Placemark> placemarkCurrent = await Geolocator()
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    List<Placemark> placemarkDestination = await Geolocator()
        .placemarkFromCoordinates(
            _destination.latitude, _destination.longitude);
    placemarkCurrent.forEach((Placemark f) {
      _currentLocation =
          '${f.thoroughfare} ${f.subThoroughfare}, ${f.subLocality}, ${f.locality}, ${f.subAdministrativeArea} ${f.postalCode}, ${f.administrativeArea}, ${f.country}';
      notifyListeners();
    });
    placemarkDestination.forEach((Placemark f) {
      _destinationLocation =
          '${f.thoroughfare} ${f.subThoroughfare}, ${f.subLocality}, ${f.locality}, ${f.subAdministrativeArea} ${f.postalCode}, ${f.administrativeArea}, ${f.country}';
      notifyListeners();
    });
  }
}
