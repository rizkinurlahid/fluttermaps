import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/utils/string.dart';
import 'package:flutter_maps/view-models/detailUserViewModel.dart';
import 'package:flutter_maps/views/pages/HomePage.dart';
import 'package:flutter_maps/views/widgets/backgroundField.dart';
import 'package:flutter_maps/views/widgets/buildCachedImage.dart';
import 'package:flutter_maps/views/widgets/dropdownMenuItemCustom.dart';
import 'package:flutter_maps/views/widgets/isError.dart';
import 'package:flutter_maps/views/widgets/maps.dart';
import 'package:flutter_maps/views/widgets/photoProfile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class DetailUser extends StatefulWidget {
  final String id;
  final bool isPrefs;
  DetailUser({this.id, @required this.isPrefs});
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
        if (!widget.isPrefs) {
          (widget.id != null)
              ? model.getUserById(id: widget.id)
              : model.getUserByLastAdded;
        } else {
          model.getPrefs;
          model.setIsEditable(true);
        }
      },
      builder: (context, model, child) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            );
            return false;
          },
          child: Scaffold(
            key: model.scaffoldKey,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('Detail User'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                ),
              ),
              actions: !model.isEditable && !widget.isPrefs
                  ? [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: (!model.isLoading)
                            ? () => model.setIsEditable(true)
                            : null,
                      ),
                      IconButton(
                        icon: (!model.isLoading)
                            ? Icon(Icons.delete, color: Colors.red)
                            : Center(
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white)),
                                ),
                              ),
                        onPressed:
                            (!model.isLoading) ? () => model.deleteData : null,
                      )
                    ]
                  : [
                      IconButton(
                        icon: (!model.isLoading)
                            ? Icon(Icons.save, color: Colors.white)
                            : Center(
                                child: Container(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white)),
                                ),
                              ),
                        onPressed:
                            (!model.isLoading) ? () => model.updateData : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: (!model.isLoading)
                            ? () {
                                model.setIsEditable(false);
                                model.getUserById(id: model.id);
                              }
                            : null,
                      )
                    ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: (!model.isLoadingScreen)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IsError(
                            height: (model.isError) ? model.height : 0,
                            text: 'Failed to Update Data',
                          ),
                          PhotoProfile(
                            imgUrl: (model.imgUrl != null)
                                ? StringApp().getPhoto + model.imgUrl
                                : StringApp().getPhoto + model.userModel.image,
                            icon: Icons.add_photo_alternate,
                            isEditable: model.isEditable && !model.isLoading,
                            pilihGalery: model.pilihGallery,
                            childClipRRect: (model.imageFile != null)
                                ? Image.file(model.imageFile,
                                    fit: BoxFit.cover, height: 125, width: 125)
                                : Container(
                                    height: 125,
                                    width: 125,
                                    child: BuildCachedImage(
                                      imgUrl: (model.imgUrl != null)
                                          ? StringApp().getPhoto + model.imgUrl
                                          : StringApp().getPhoto +
                                              model.userModel.image,
                                    ),
                                  ),
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
                                    readOnly:
                                        !model.isEditable || model.isLoading,
                                    onSubmitted: (value) =>
                                        model.setNama(value),
                                    autofocus: true,
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
                                ignoring: !model.isEditable || model.isLoading,
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
                                      onChanged: (value) => setState(
                                          () => model.setTanggal(value)),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text("Kecamatan, Kota, Provinsi"),
                                ),
                              ),
                              Stack(
                                children: <Widget>[
                                  InkWell(
                                    onTap: model.isEditable
                                        ? (!model.isLoading)
                                            ? () => model.onValidateData
                                            : null
                                        : null,
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
                                                // onMapCreated:
                                                //     (GoogleMapController
                                                //         controller) {
                                                //   model.controller
                                                //       .complete(controller);
                                                // },

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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                            onTap: (!model.isLoading)
                                                ? () => model.onValidateData
                                                : null,
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
                              (!model.isEditable)
                                  ? Container(
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
                                                current: model.currentLatLng,
                                                isFromUpdate: true,
                                              ),
                                            ),
                                          );
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
          ),
        );
      },
    );
  }
}
