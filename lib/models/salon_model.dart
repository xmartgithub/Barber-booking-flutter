import 'package:cloud_firestore/cloud_firestore.dart';

class SalonModel {
  String name, address, docId;
  DocumentReference reference;

  SalonModel({this.name, this.address});

  SalonModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['name'] = this.name;
    return data;
  }
}
