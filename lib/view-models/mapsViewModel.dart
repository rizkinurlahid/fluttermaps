import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:stacked/stacked.dart';

class MapsViewModel extends BaseViewModel {
  Completer<GoogleMapController> _controller = Completer();
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Set<Marker> markers = HashSet<Marker>();
  Marker marker;
  Circle circle;

  LatLng currentLatLng;

  StreamSubscription get locationSubscription => _locationSubscription;
  Completer<GoogleMapController> get controller => _controller;

  static final CameraPosition _initial = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  CameraPosition get initialCameraPosition => _initial;

  static const LatLng center = const LatLng(45.521563, -122.677433);
  LatLng _lastMapPosition = center;

  onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onAddMarkerButtonPressed() {
    if (markers != null) {
      markers.clear();
      marker = null;
      disposeSubscription();
    }
    markers.add(Marker(
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        icon: BitmapDescriptor.defaultMarker));
    currentLatLng = _lastMapPosition;
    notifyListeners();
  }

  get onAddMarkerButtonPressed => _onAddMarkerButtonPressed();

  updateMarkerAndCircle(LocationData newLocalData) {
    _lastMapPosition = LatLng(newLocalData.latitude, newLocalData.longitude);
    currentLatLng = LatLng(newLocalData.latitude, newLocalData.longitude);
    notifyListeners();
    LatLng latLng = LatLng(newLocalData.latitude, newLocalData.longitude);
    marker = Marker(
        markerId: MarkerId('m1'),
        position: latLng,
        rotation: newLocalData.heading,
        draggable: false,
        zIndex: 2,
        flat: true,
        icon: BitmapDescriptor.defaultMarker);
    circle = Circle(
        circleId: CircleId('c1'),
        radius: newLocalData.accuracy,
        zIndex: 1,
        strokeColor: Colors.blue,
        center: latLng,
        fillColor: Colors.blue.withAlpha(70));
    notifyListeners();
  }

  _getCurrentLocation() async {
    try {
      var location = await _locationTracker.getLocation();
      final GoogleMapController controller = await _controller.future;

      updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          controller
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(newLocalData.latitude, newLocalData.longitude),
            zoom: 19.151926040649414,
          )));
          updateMarkerAndCircle(location);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint('Permission Denied');
      }
    }
  }

  get getCurrentLocation => _getCurrentLocation();

  disposeSubscription() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
  }
}
