// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

class UserModel {
  UserModel({
    this.id,
    this.image,
    this.nama,
    this.tanggalLahir,
    this.latitude,
    this.longitude,
  });

  String id;
  String image;
  String nama;
  String tanggalLahir;
  String latitude;
  String longitude;

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"] == null ? null : json["id"],
        image: json["image"] == null ? null : json["image"],
        nama: json["nama"] == null ? null : json["nama"],
        tanggalLahir:
            json["tanggal_lahir"] == null ? null : json["tanggal_lahir"],
        latitude: json["latitude"] == null ? null : json["latitude"],
        longitude: json["longitude"] == null ? null : json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "image": image == null ? null : image,
        "nama": nama == null ? null : nama,
        "tanggal_lahir": tanggalLahir == null ? null : tanggalLahir,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
      };
}
