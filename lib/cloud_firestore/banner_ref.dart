import 'package:barber_booking/models/image_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<ImageModel>> getBanners() async {
  List<ImageModel> result = List<ImageModel>.empty(growable: true);

  CollectionReference bannerRef =
      FirebaseFirestore.instance.collection('BANNER');
  QuerySnapshot snapshot = await bannerRef.get();
  snapshot.docs.forEach((element) {
    result.add(ImageModel.fromJson(element.data()));
  });

  return result;
}
