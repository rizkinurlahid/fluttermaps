import 'package:date_util/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/view-models/addUserViewModel.dart';
import 'package:flutter_maps/views/widgets/backgroundField.dart';
import 'package:flutter_maps/views/widgets/dropdownMenuItemCustom.dart';
import 'package:flutter_maps/views/widgets/isError.dart';
import 'package:flutter_maps/views/widgets/photoProfile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stacked/stacked.dart';

class AddUser extends StatefulWidget {
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  AddUserViewModel homePageViewModel = AddUserViewModel();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ViewModelBuilder<AddUserViewModel>.reactive(
      viewModelBuilder: () => homePageViewModel,
      onModelReady: (model) => model.initial,
      builder: (context, model, child) {
        return SafeArea(
          child: Scaffold(
            key: model.scaffoldKey,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('Add User'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Please complete your Profile !',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 30),
                    IgnorePointer(
                      ignoring: model.isLoading,
                      child: PhotoProfile(
                        childClipRRect: (model.imageFile != null)
                            ? Image.file(model.imageFile,
                                fit: BoxFit.cover, height: 125, width: 125)
                            : Container(
                                color: Colors.grey[300],
                              ),
                        pilihGalery: model.pilihGallery,
                        icon: Icons.insert_photo,
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
                          BackgroundField(
                            child: TextField(
                              readOnly: model.isLoading,
                              controller: model.namaController,
                              onSubmitted: (value) => model.setNama(value),
                              onChanged: (value) => model.setNama(value),
                              decoration: InputDecoration(
                                hintText: "Nama Anda",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
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
                        IgnorePointer(
                          ignoring: model.isLoading,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    child: Text(f),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => model.setTahun(value));
                                  model.listDay.clear();
                                  model.setDay();
                                },
                                hint: Text('Tahun'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IsError(
                      height: (model.isNotValidate) ? model.height : 0,
                      text: 'Please fill in the above first',
                    ),
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
                          onTap: (!model.isLoading)
                              ? () => model.onValidateData
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
                                      initialCameraPosition: CameraPosition(
                                          target: model.currentLatLng,
                                          zoom: 14.4746),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        model.controller.complete(controller);
                                      },
                                      markers: Set.of((model.marker != null)
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
                        Align(
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
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.edit_location,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    IsError(
                      height: (model.isError) ? model.height : 0,
                      text: 'Failed to Add Data',
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.blue,
                        disabledColor: Colors.blue[300],
                        child: (!model.isLoading)
                            ? Text(
                                'Simpan',
                                style: TextStyle(color: Colors.white),
                              )
                            : Center(
                                child: Container(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                              )),
                        onPressed: (model.currentLatLng != null)
                            ? (!model.isLoading) ? () => model.saveToSQL : null
                            : null,
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
}
