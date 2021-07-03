import 'package:barber_booking/screens/booking_screen.dart';
import 'package:barber_booking/screens/home_screen.dart';
import 'package:barber_booking/state/state_management.dart';
import 'package:barber_booking/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_ui/firebase_auth_ui.dart';
import 'package:firebase_auth_ui/providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Barber Booking',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/home':
              return PageTransition(
                child: HomeScreen(),
                type: PageTransitionType.fade,
                settings: settings,
              );
              break;
            case '/booking':
              return PageTransition(
                child: BookingScreen(),
                type: PageTransitionType.fade,
                settings: settings,
              );
              break;
            default:
              return null;
          }
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage());
  }
}

class HomePage extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

  processLogin(BuildContext context) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      //user not login, show login
      FirebaseAuthUi.instance()
          .launchAuth([AuthProvider.phone()]).then((firebaseUser) async {
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        await checkLoginState(context, true, scaffoldState);
      }).catchError((e) {
        if (e is PlatformException) if (e.code ==
            FirebaseAuthUi.kUserCancelledError)
          ScaffoldMessenger.of(scaffoldState.currentContext)
              .showSnackBar(SnackBar(content: Text("${e.message}")));
        else
          ScaffoldMessenger.of(scaffoldState.currentContext)
              .showSnackBar(SnackBar(content: Text("Unknown error")));
      });
    } else {
      // user already login, start home page

    }
  }

  @override
  Widget build(BuildContext context, watch) {
    // GlobalKey<ScaffoldState> scaffoldState = new GlobalKey();

    return Scaffold(
      key: scaffoldState,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/my_bg.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder(
                  future: checkLoginState(context, false, scaffoldState),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    else {
                      var userState = snapshot.data as LOGIN_STATE;
                      if (userState == LOGIN_STATE.LOGGED) {
                        //when user logged in
                        return Container();
                      } else {
                        //when user not logged in
                        return ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.black)),
                            onPressed: () => processLogin(context),
                            icon: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Login With Phone",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin,
      GlobalKey<ScaffoldState> scaffoldState) async {
    if (!context.read(forceReload).state) {
      await Future.delayed(Duration(seconds: fromLogin == true ? 0 : 3))
          .then((value) => {
                FirebaseAuth.instance.currentUser
                    .getIdToken()
                    .then((token) async {
                  print('$token');
                  context.read(userToken).state = token;
                  //check user in firestore
                  CollectionReference userRef =
                      FirebaseFirestore.instance.collection("User");
                  DocumentSnapshot snapshotUser = await userRef
                      .doc(FirebaseAuth.instance.currentUser.phoneNumber)
                      .get();
                  //Form reload state
                  context.read(forceReload).state = true;
                  if (snapshotUser.exists) {
                    // if user already logged in then we will redirect to home screen
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  } else {
                    var nameController = TextEditingController();
                    var addressController = TextEditingController();
                    Alert(
                        context: context,
                        title: "Update Profiles",
                        content: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.account_circle),
                                  labelText: "Name"),
                            ),
                            TextField(
                              controller: addressController,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.home), labelText: "Address"),
                            ),
                          ],
                        ),
                        buttons: [
                          DialogButton(
                              child: Text('CANCEL'),
                              onPressed: () => Navigator.pop(context)),
                          DialogButton(
                              child: Text('UPDATE'),
                              onPressed: () {
                                //update to server
                                userRef
                                    .doc(FirebaseAuth
                                        .instance.currentUser.phoneNumber)
                                    .set({
                                  'name': nameController.text,
                                  'address': addressController.text,
                                }).then((value) async {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(
                                          scaffoldState.currentContext)
                                      .showSnackBar(SnackBar(
                                          content: Text(
                                              "UPADTED PROFILE DETAILS SUCCESSFULLY!")));
                                  await Future.delayed(Duration(seconds: 1),
                                      () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/home', (route) => false);
                                  });
                                }).catchError((e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(
                                          scaffoldState.currentContext)
                                      .showSnackBar(
                                          SnackBar(content: Text("$e")));
                                });
                              }),
                        ]).show();
                  }
                })
              });
    }

    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGGED;
  }
}
