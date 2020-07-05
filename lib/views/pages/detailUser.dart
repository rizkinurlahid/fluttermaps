import 'dart:async';

import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:flutter_maps/view-models/detailUserViewModel.dart';
import 'package:flutter_maps/views/widgets/backgroundField.dart';
import 'package:flutter_maps/views/widgets/dropdownMenuItemCustom.dart';
import 'package:flutter_maps/views/widgets/isError.dart';
import 'package:flutter_maps/views/widgets/maps.dart';
import 'package:flutter_maps/views/widgets/photoProfile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class DetailUser extends StatefulWidget {
  final String id;
  DetailUser({this.id});
  @override
  _DetailUserState createState() => _DetailUserState();
}

class _DetailUserState extends State<DetailUser> {
  DetailUserViewModel detailUserViewModel = DetailUserViewModel();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DetailUserViewModel>.reactive(
      viewModelBuilder: () => DetailUserViewModel(),
      onModelReady: (model) {
        model.setDate;
        (widget.id != null)
            ? model.getUserById(id: widget.id)
            : model.getUserByLastAdded;
      },
      builder: (context, model, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Detail User'),
            actions: !model.isEditable
                ? [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () => model.setIsEditable(true),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {},
                    )
                  ]
                : [
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => model.setIsEditable(false),
                    )
                  ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: (!model.isLoading)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        PhotoProfile(
                          imgUrl: StringApp().getPhoto + model.userModel.image,
                          icon: Icons.add_photo_alternate,
                          isEditable: model.isEditable,
                          pilihGalery: model.pilihGallery,
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Nama'),
                              BackgroundField(
                                child: TextField(
                                  controller: model.namaController,
                                  readOnly: !model.isEditable,
                                  onSubmitted: (value) => model.setNama(value),
                                  onChanged: (value) => model.setNama(value),
                                  decoration: InputDecoration(
                                    hintText: "Nama Anda",
                                    border: InputBorder.none,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text('Tanggal Lahir'),
                            ),
                            IgnorePointer(
                              ignoring: !model.isEditable,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  DropdownMenuItemCustom(
                                    value: model.tanggal,
                                    items: model.listDay.map((f) {
                                      return DropdownMenuItem(
                                        value: int.parse(f),
                                        child: Text(f),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        setState(() => model.setTanggal(value)),
                                    hint: Text('Tanggal'),
                                  ),
                                  DropdownMenuItemCustom(
                                    value: model.bulan,
                                    items: model.listMonth.map((f) {
                                      return DropdownMenuItem(
                                        value: int.parse(f),
                                        child: Text(
                                            '${DateUtil().month(int.parse(f))}'),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => model.setBulan(value));
                                      model.listDay.clear();
                                      model.setDay();
                                    },
                                    hint: Text('Bulan'),
                                  ),
                                  DropdownMenuItemCustom(
                                    value: model.tahun,
                                    items: model.listYear.map((f) {
                                      return DropdownMenuItem(
                                        value: int.parse(f),
                                        child: Center(child: Text(f)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => model.setTahun(value));
                                    },
                                    hint: Text('Tahun'),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text("Kecamatan, Kota, Provinsi"),
                              ),
                            ),
                            Stack(
                              children: <Widget>[
                                InkWell(
                                  onTap: model.isEditable ? () {} : null
                                  //  (!model.isLoading)
                                  //     ? () => () {}
                                  //     model.onValidateData
                                  //     : null
                                  ,
                                  child: Container(
                                    height: 225,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey[300],
                                        style: BorderStyle.solid,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: (model.currentLatLng != null)
                                          ? GoogleMap(
                                              mapType: MapType.hybrid,
                                              initialCameraPosition:
                                                  CameraPosition(
                                                      target:
                                                          model.currentLatLng,
                                                      zoom: 14.4746),
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                model.controller
                                                    .complete(controller);
                                              },
                                              markers: Set.of(
                                                  (model.marker != null)
                                                      ? [model.marker]
                                                      : []),
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
                                model.isEditable
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () {}
                                          // (!model.isLoading)
                                          //     ? () => () {}
                                          //     model.onValidateData
                                          //     : null
                                          ,
                                          child: Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.edit_location,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            IsError(
                              height: 0,
                              //(model.isError) ? model.height : 0,
                              text: 'Failed to Update Data',
                            ),
                            !model.isEditable
                                ? Container(
                                    width: double.infinity,
                                    child: RaisedButton(
                                      color: Colors.blue,
                                      child: Text(
                                        'Cek Jarak ke Kantor',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) => Maps(
                                        //       isView: true,
                                        //       current: widget.currentLatLng,
                                        //     ),
                                        //   ),
                                        // );
                                      },
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
