import 'package:barber_booking/cloud_firestore/banner_ref.dart';
import 'package:barber_booking/cloud_firestore/lookbook_ref.dart';
import 'package:barber_booking/cloud_firestore/user_ref.dart';
import 'package:barber_booking/models/image_model.dart';
import 'package:barber_booking/models/user_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xffDFDFDF),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //user profile
              FutureBuilder(
                future: getUserProfiles( context,
                    FirebaseAuth.instance.currentUser.phoneNumber),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var userModel = snapshot.data as UserModel;
                    return Container(
                      decoration: BoxDecoration(
                        color: Color(0xff383838),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                            maxRadius: 30,
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userModel.name}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${userModel.address}',
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),

              //Menu
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/booking'),
                        child: Container(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.book_online,
                                    size: 50,
                                  ),
                                  Text(
                                    "Booking",
                                    style: GoogleFonts.robotoMono(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 50,
                                ),
                                Text(
                                  "Cart",
                                  style: GoogleFonts.robotoMono(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 50,
                                ),
                                Text(
                                  "History",
                                  style: GoogleFonts.robotoMono(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //Banner
              FutureBuilder(
                future: getBanners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var banners = snapshot.data as List<ImageModel>;
                    return CarouselSlider(
                        items: banners
                            .map(
                              (e) => Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(e.image),
                                ),
                              ),
                            )
                            .toList(),
                        options: CarouselOptions(
                          aspectRatio: 3.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                        ));
                  }
                },
              ),

              //LookBook
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      "LOOKBOOK",
                      style: GoogleFonts.robotoMono(
                        fontSize: 24.0,
                      ),
                    )
                  ],
                ),
              ),
              FutureBuilder(
                  future: getLookbook(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var lookbook = snapshot.data as List<ImageModel>;
                      return Column(
                        children: lookbook
                            .map((e) => Container(
                                  padding: const EdgeInsets.all(8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(e.image),
                                  ),
                                ))
                            .toList(),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
