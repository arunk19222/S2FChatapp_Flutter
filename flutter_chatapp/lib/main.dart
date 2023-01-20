import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Chat_user_list.dart';
import 'package:flutter_chatapp/User_info_details.dart';
import 'package:flutter_chatapp/sign&login_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MaterialApp(
    home: Home_page(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home_page extends StatefulWidget {
  const Home_page({Key? key}) : super(key: key);

  @override
  State<Home_page> createState() => _Home_pageState();
}

class _Home_pageState extends State<Home_page> with WidgetsBindingObserver {
  bool isdeviceConnected = false;
  void check_internet() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result) {
      isdeviceConnected = true;
    } else {
      isdeviceConnected = false;
    }
    Connectivity().onConnectivityChanged.listen((event) async {
      bool result = await InternetConnectionChecker().hasConnection;
      if (result) {
        setState(() {
          isdeviceConnected = true;
        });
      } else {
        setState(() {
          isdeviceConnected = false;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    check_internet();
    if (isdeviceConnected) {
      if (FirebaseAuth.instance.currentUser != null) {
        return StreamBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.snapshot.value.toString() != '') {
                return ShowCaseWidget(
                  builder: Builder(
                    builder: (_) => chat_user_list(),
                  ),
                );
              } else {
                return ShowCaseWidget(
                  builder: Builder(
                    builder: (_) => user_info(),
                  ),
                );
              }
            } else {
              return Container();
            }
          },
          stream: FirebaseDatabase.instance
              .ref('Users')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child('name')
              .onValue,
        );
      } else {
        return sign_login();
      }
    } else {
      return Container(
        color: Colors.purple[300],
        child: Lottie.asset('assets/offline.json'),
      );
    }
  }
}
