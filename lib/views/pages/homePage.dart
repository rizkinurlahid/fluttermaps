import 'dart:io';
import 'package:date_util/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/view-models/homePageViewModel.dart';
import 'package:flutter_maps/views/pages/checkList.dart';
import 'package:flutter_maps/views/pages/maps.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class HomePage extends StatefulWidget {
  final LatLng currentLatLng;
  final File file;
  final String nama;
  final int tanggal, bulan, tahun;
  HomePage(
      {this.file,
      this.nama,
      this.tanggal,
      this.bulan,
      this.tahun,
      this.currentLatLng});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageViewModel homePageViewModel = HomePageViewModel();
  TextEditingController namaController;
  Marker marker;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    namaController =
        TextEditingController(text: widget.nama != null ? widget.nama : null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentLatLng != null) {
      marker = Marker(
          markerId: MarkerId('m2'),
          position: widget.currentLatLng,
          draggable: false,
          zIndex: 2,
          flat: true,
          icon: BitmapDescriptor.defaultMarker);
    }
    return ViewModelBuilder<HomePageViewModel>.reactive(
      viewModelBuilder: () => homePageViewModel,
      onModelReady: (model) => model.setDate,
      builder: (context, model, child) {
        if (widget.currentLatLng != null) {
          model.current = widget.currentLatLng;
          model.imageFile = widget.file;
        }
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Please complete your Profile !',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 30),
                    Container(
                      height: 125,
                      width: 125,
                      child: Stack(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(125),
                            child: (widget.file != null)
                                ? Image.file(
                                    widget.file,
                                    fit: BoxFit.cover,
                                  )
                                : (model.imageFile != null)
                                    ? Image.file(model.imageFile,
                                        fit: BoxFit.cover)
                                    : Container(
                                        color: Colors.grey[300],
                                      ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: InkWell(
                              onTap: model.pilihGallery,
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.insert_photo,
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
                                controller: namaController,
                                onSubmitted: (value) => model.nama = value,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  value: int.parse(f),
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
                                model.listDay.clear();
                                model.setDay();
                              },
                              hint: Text('Tahun'),
                            ),
                          ],
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
                    Stack(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Maps(
                                  file: model.imageFile,
                                  nama: model.nama,
                                  tanggal: model.tanggal,
                                  bulan: model.bulan,
                                  tahun: model.tahun,
                                  isView: false,
                                ),
                              ),
                            );
                          },
                          child: Container(
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
                              child: (widget.currentLatLng != null)
                                  ? GoogleMap(
                                      mapType: MapType.hybrid,
                                      initialCameraPosition: CameraPosition(
                                          target: widget.currentLatLng,
                                          zoom: 14.4746),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        model.controller.complete(controller);
                                      },
                                      markers: Set.of(
                                          (marker != null) ? [marker] : []),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.grey[300],
                                          size: 30.0,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Set Alamat",
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Maps(
                                    file: widget.file != null
                                        ? widget.file
                                        : model.imageFile,
                                    nama: widget.nama != null
                                        ? widget.nama
                                        : model.nama,
                                    tanggal: widget.tanggal != null
                                        ? widget.tanggal
                                        : model.tanggal,
                                    bulan: widget.bulan != null
                                        ? widget.bulan
                                        : model.bulan,
                                    tahun: widget.tahun != null
                                        ? widget.tahun
                                        : model.tahun,
                                    isView: false,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.edit_location,
                                    color: Colors.white,
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: <Widget>[
                        SizedBox(height: 30),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: Duration(milliseconds: 500),
                            width: double.infinity,
                            height: (isError) ? 20 : 0,
                            child: Center(
                              child: Text(
                                'Please Select Your Location !',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.blue,
                        child: Text(
                          'Simpan',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          // model.saveToSQL();
                          if (widget.currentLatLng != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckList(
                                  file: (widget.file != null)
                                      ? widget.file
                                      : model.imageFile,
                                  nama: (widget.nama != null)
                                      ? widget.nama
                                      : model.nama,
                                  tanggal: (widget.tanggal != null)
                                      ? widget.tanggal
                                      : model.tanggal,
                                  bulan: (widget.bulan != null)
                                      ? widget.bulan
                                      : model.bulan,
                                  tahun: (widget.tahun != null)
                                      ? widget.tahun
                                      : model.tahun,
                                  currentLatLng: widget.currentLatLng,
                                ),
                              ),
                            );
                          }
                          {
                            setState(() {
                              isError = true;
                            });
                          }
                        },
                      ),
                    )
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
