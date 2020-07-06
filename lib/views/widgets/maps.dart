import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/view-models/mapsViewModel.dart';
import 'package:flutter_maps/views/pages/addUser.dart';
import 'package:flutter_maps/views/pages/detailUser.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class Maps extends StatefulWidget {
  final bool isView;
  final LatLng current;
  final bool isFromUpdate;
  Maps({@required this.isView, this.current, @required this.isFromUpdate});
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  MapsViewModel mapsViewModel = MapsViewModel();

  @override
  void initState() {
    super.initState();
    if (widget.isView) {
      mapsViewModel.getPolylinesAndDistance(current: widget.current);
      mapsViewModel.getPlacemark(latLng: widget.current);
    }
  }

  @override
  void dispose() {
    mapsViewModel.disposeSubscription;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SpeedDialChild button({Function function, Widget widget, String label}) {
      return SpeedDialChild(
        onTap: function,
        child: widget,
        backgroundColor: Colors.blue,
        label: label,
      );
    }

    return ViewModelBuilder<MapsViewModel>.reactive(
      viewModelBuilder: () => mapsViewModel,
      onModelReady: (model) =>
          (!widget.isView) ? model.getCurrentLocation : null,
      builder: (context, model, child) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                height: size.height,
                width: size.width,
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: (widget.isView)
                      ? CameraPosition(
                          target: widget.current,
                          zoom: 14.4746,
                        )
                      : model.initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    model.controller.complete(controller);
                  },
                  onCameraMove: (!widget.isView) ? model.onCameraMove : null,
                  markers: (!widget.isView)
                      ? model.markers != null
                          ? model.markers
                          : Set.of((model.marker != null) ? [model.marker] : [])
                      : Set.of([
                          Marker(
                              markerId: MarkerId('m2'),
                              position: widget.current,
                              draggable: false,
                              infoWindow:
                                  InfoWindow(title: model?.currentLocation),
                              icon: BitmapDescriptor.defaultMarker),
                          Marker(
                            markerId: MarkerId('m3'),
                            position: model.destination,
                            draggable: false,
                            infoWindow:
                                InfoWindow(title: model?.destinationLocation),
                            icon: BitmapDescriptor.defaultMarkerWithHue(50),
                          ),
                        ]),
                  circles: (!widget.isView)
                      ? Set.of((model.circle != null) ? [model.circle] : [])
                      : null,
                  polylines: (widget.isView)
                      ? Set<Polyline>.of(model.getPolylines.values)
                      : null,
                ),
              ),
              (widget.isView)
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1,
                              blurRadius: .5,
                              offset: Offset(.2, .2),
                            )
                          ],
                        ),
                        height: 100,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Dari :',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400),
                                      ),
                                      AutoSizeText(
                                        '${model.currentLocation}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Ke :',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400),
                                      ),
                                      AutoSizeText(
                                        '${model.destinationLocation}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3),
                                      Center(
                                        child: Text(
                                          '${model?.distance?.toStringAsFixed(2)} Km',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              RaisedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Exit',
                                    style: TextStyle(color: Colors.white)),
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          floatingActionButton: (!widget.isView)
              ? SpeedDial(
                  marginRight: 50,
                  animatedIcon: AnimatedIcons.menu_close,
                  children: [
                    button(
                        function: () => model.onAddMarkerButtonPressed,
                        widget: Icon(Icons.location_on),
                        label: 'Add Marker'),
                    button(
                        function: () => model.getCurrentLocation,
                        widget: Icon(Icons.my_location),
                        label: 'Current Location'),
                    (model.marker != null || model.markers != null)
                        ? button(
                            function: () {
                              model.savePrefs;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => (!widget.isFromUpdate)
                                        ? AddUser()
                                        : DetailUser(
                                            isPrefs: true,
                                          )),
                                (Route<dynamic> route) => false,
                              );
                            },
                            widget: Icon(Icons.save),
                            label: 'Save')
                        : null,
                  ],
                )
              : null,
        );
      },
    );
  }
}
