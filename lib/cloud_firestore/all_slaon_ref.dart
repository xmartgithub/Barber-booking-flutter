import 'package:barber_booking/models/barber_model.dart';
import 'package:barber_booking/models/city_model.dart';
import 'package:barber_booking/models/salon_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<CityModel>> getCities() async {
  var cities = List<CityModel>.empty(growable: true);
  var cityRef = FirebaseFirestore.instance.collection('AllSalon');
  var snapshot = await cityRef.get();

  snapshot.docs.forEach((element) {
    cities.add(CityModel.fromJson(element.data()));
  });
  return cities;
}

Future<List<SalonModel>> getSalonByCity(String cityName) async {
  var salons = List<SalonModel>.empty(growable: true);
  var salonRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(cityName.replaceAll(" ", ""))
      .collection("Branch").orderBy('name');;
  var snapshot = await salonRef.get();

  snapshot.docs.forEach((element) {
    var salon = SalonModel.fromJson(element.data());
    salon.docId = element.id;
    salon.reference = element.reference;
    salons.add(salon);
  });
  return salons;
}


Future<List<BarberModel>> getBarberBySalon(SalonModel salon) async {
  var barbers = List<BarberModel>.empty(growable: true);
  var barberRef = salon.reference.collection('Barber');
  var snapshot = await barberRef.get();

  snapshot.docs.forEach((element) {
    var barber = BarberModel.fromJson(element.data());
    barber.docId = element.id;
    barber.reference = element.reference;
    barbers.add(barber);
  });
  return barbers;
}