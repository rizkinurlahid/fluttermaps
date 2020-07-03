import 'dart:io';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/view-models/biodataViewModel.dart';
import 'package:flutter_maps/views/pages/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class BioData extends StatefulWidget {
  final LatLng currentLatLng;
  final File file;
  final String nama;
  final int tanggal, bulan, tahun;
  BioData(
      {this.file,
      this.nama,
      this.tanggal,
      this.bulan,
      this.tahun,
      this.currentLatLng});
  @override
  _BioDataState createState() => _BioDataState();
}

class _BioDataState extends State<BioData> {
  Marker marker;
  @override
  Widget build(BuildContext context) {
    if (widget.currentLatLng != null) {
      marker = Marker(
          markerId: MarkerId('m3'),
          position: widget.currentLatLng,
          draggable: false,
          zIndex: 2,
          flat: true,
          icon: BitmapDescriptor.defaultMarker);
    }
    return ViewModelBuilder<BiodataViewModel>.reactive(
      viewModelBuilder: () => BiodataViewModel(),
      onModelReady: (model) => model.setDate,
      builder: (context, model, child) {
        if (widget.file != null) model.imageFile = widget.file;
        model.namaController.text = widget.nama;
        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 125,
                      width: 125,
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(125),
                            child: (model.imageFile != null)
                                ? Image.file(model.imageFile, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[300],
                                  ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: () {
                                model.pilihGallery();
                                setState(() {});
                              },
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.add_photo_alternate,
                                        color: Colors.white),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Nama'),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextField(
                                controller: model.namaController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Nama Anda",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text('Tanggal Lahir'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            dropdownMenuItem(
                              value: (widget.tanggal != null)
                                  ? widget.tanggal
                                  : model.tanggal,
                              items: model.listDay?.map((f) {
                                return DropdownMenuItem(
                                  value: int.parse(f) ?? 0,
                                  child: Text(f ?? ""),
                                );
                              })?.toList(),
                              onChanged: (value) =>
                                  setState(() => model.tanggal = value),
                              hint: Text('Tanggal'),
                            ),
                            dropdownMenuItem(
                              value: (widget.bulan != null)
                                  ? widget.bulan
                                  : model.bulan,
                              items: model.listMonth.map((f) {
                                return DropdownMenuItem(
                                  value: int.parse(f) ?? 0,
                                  child:
                                      Text('${DateUtil().month(int.parse(f))}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => model.bulan = value);
                                model.listDay.clear();
                                model.setDay();
                              },
                              hint: Text('Bulan'),
                            ),
                            dropdownMenuItem(
                              value: (widget.tahun != null)
                                  ? widget.tahun
                                  : model.tahun,
                              items: model.listYear.map((f) {
                                return DropdownMenuItem(
                                  value: int.parse(f),
                                  child: Text('$f'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => model.tahun = value);
                              },
                              hint: Text('Tahun'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Kecamatan, Kota, Provinsi"),
                          ),
                        ),
                        Container(
                          height: 225,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[300],
                                style: BorderStyle.solid,
                                width: 1,
                              )),
                          child: Center(
                            child: GoogleMap(
                              mapType: MapType.hybrid,
                              initialCameraPosition: CameraPosition(
                                  target: widget.currentLatLng, zoom: 14.4746),
                              onMapCreated: (GoogleMapController controller) {
                                model.controller.complete(controller);
                              },
                              markers: Set.of((marker != null) ? [marker] : []),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),
                        Container(
                          width: double.infinity,
                          child: RaisedButton(
                            color: Colors.blue,
                            child: Text(
                              'Cek Jarak ke Kantor',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Maps(
                                    isView: true,
                                    current: widget.currentLatLng,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget dropdownMenuItem({value, items, onChanged, hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: DropdownButton(
          disabledHint: Text('$value'),
          value: value,
          items: items,
          onChanged: onChanged,
          hint: hint,
          underline: Container(),
        ),
      ),
    );
  }
}
