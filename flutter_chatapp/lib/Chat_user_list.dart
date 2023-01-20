import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/FirebaseServices/collect_user_info.dart';
import 'package:flutter_chatapp/chats.dart';
import 'package:flutter_chatapp/sign&login_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class chat_user_list extends StatefulWidget {
  const chat_user_list({Key? key}) : super(key: key);
  @override
  State<chat_user_list> createState() => _chat_user_listState();
}

class _chat_user_listState extends State<chat_user_list>
    with WidgetsBindingObserver {
  final drawer_key = GlobalKey();
  final users_key = GlobalKey();
  final scaffold_key = GlobalKey<ScaffoldState>();
  var name = TextEditingController();
  var about = TextEditingController();
  var user_lists = [];
  dynamic profile_pic_path;
  dynamic uploaded_image;
  var name_already_exists = false;
  var current_user_name = '';
  User? user;
  dynamic progress = 0;
  List<GlobalKey> show_case_list = <GlobalKey>[];
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

  Future selectFile() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Edit About YourSelf"),
            elevation: 60,
            icon: Icon(
              Icons.info,
              color: Colors.black87,
            ),
            iconPadding: EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            actions: [
              Center(
                child: Column(
                  children: [
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: isdeviceConnected
                            ? () {
                                FirebaseDatabase.instance
                                    .ref('Users')
                                    .child(
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .child('profile_pic')
                                    .set('');
                                setState(() {
                                  uploaded_image = GestureDetector(
                                    onTap: selectFile,
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  );
                                });
                                Navigator.pop(context);
                              }
                            : () {},
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        )),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: isdeviceConnected
                            ? () async {
                                final select_file = await FilePicker.platform
                                    .pickFiles(type: FileType.image);
                                PlatformFile? platformFile;
                                if (select_file != null) {
                                  platformFile = select_file.files.first;
                                } else {
                                  return null;
                                }
                                if (platformFile != null) {
                                  upload_profile_image(
                                      'profile_pics/$current_user_name',
                                      File(platformFile!.path!));
                                }
                                Navigator.pop(context);
                              }
                            : () {},
                        child: Text("Change",
                            style: TextStyle(color: Colors.white)))
                  ],
                ),
              )
            ],
          );
        });
  }

  void upload_profile_image(String destination, File file) async {
    final ref = await FirebaseStorage.instance.ref(destination);
    ref.putFile(file).snapshotEvents.listen((event) async {
      switch (event.state) {
        case TaskState.running:
          setState(() {
            progress = event.bytesTransferred / event.totalBytes;
          });
          break;
        case TaskState.success:
          progress = 0;
          final snapshot = await FirebaseStorage.instance
              .ref('profile_pics/$current_user_name')
              .getDownloadURL();
          FirebaseDatabase.instance
              .ref('Users')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child('profile_pic')
              .set(snapshot);
          setState(() {
            uploaded_image = GestureDetector(
              onTap: selectFile,
              child: ClipOval(
                child: Image.network(snapshot),
              ),
            );
          });
      }
    });
  }

  Widget validate_user_name() {
    return FirebaseAnimatedList(
      query: FirebaseDatabase.instance.ref('Users'),
      itemBuilder:
          (BuildContext context, DataSnapshot snapshot, animation, index) {
        Map m = Map<String, String>.from(snapshot.value as Map);
        print(" map values $m");
        setState(() {
          user_lists.add(m['name']);
        });

        return Container();
      },
    );
  }

  Future<void> initialize_currentUser() async {
    var k = await FirebaseAuth.instance.currentUser;
    setState(() {
      user = k;
    });
  }

  @override
  void initState() {
    //we can't use set state inside the init state thats y we are using addPostFrameCallback
    WidgetsBinding.instance!.addObserver(this);
    FirebaseDatabase.instance
        .ref('Users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('status')
        .set('online');
    uploaded_image = FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.data != '') {
          return GestureDetector(
            onTap: selectFile,
            child: ClipOval(child: Image.network(snapshot.data.toString())),
          );
        } else {
          return GestureDetector(
            onTap: selectFile,
            child: Icon(
              Icons.person,
              size: 80,
              color: Colors.white,
            ),
          );
        }
      },
      future: collect_user_info().mapv2,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        FirebaseDatabase.instance
            .ref('Users')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('status')
            .set(DateTime.now().microsecondsSinceEpoch.toString());
        break;
      case AppLifecycleState.resumed:
        FirebaseDatabase.instance
            .ref('Users')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('status')
            .set('online');
        break;
    }
  }

  void shared_preferences_function() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('first_time') == true) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ShowCaseWidget.of(context).startShowCase([drawer_key]));
      sharedPreferences.setBool('first_time', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    shared_preferences_function();
    check_internet();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        key: scaffold_key,
        appBar: AppBar(
          backgroundColor: Colors.purpleAccent[100],
          elevation: 10,
          centerTitle: true,
          leading: Showcase(
            key: drawer_key,
            descTextStyle: TextStyle(fontSize: 15, color: Colors.white),
            targetBorderRadius: BorderRadius.circular(60),
            description: "Here You Can Edit Your Profile",
            tooltipBackgroundColor: Colors.black,
            scaleAnimationCurve: Curves.easeIn,
            scaleAnimationDuration: Duration(milliseconds: 1500),
            movingAnimationDuration: Duration(milliseconds: 1500),
            child: IconButton(
              onPressed: () {
                scaffold_key.currentState!.openDrawer();
              },
              icon: Icon(
                Icons.menu_open,
                size: 30,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
          shadowColor: Colors.purple,
          foregroundColor: Colors.black87,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  '🅤🅢🅔🅡🅢',
                  style: TextStyle(fontSize: 26),
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(115))),
            elevation: 20,
            width: 270,
            backgroundColor: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.purple[300],
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: CircularPercentIndicator(
                          animation: true,
                          animationDuration: 1,
                          radius: 55,
                          percent: (100 * progress).roundToDouble() / 100,
                          progressColor: Colors.purple[300],
                          backgroundColor: Colors.black87,
                          center: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100))),
                            child: uploaded_image,
                          ),
                        )),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(30)),
                      color: Colors.purple[300]),
                  child: Row(
                    children: [
                      Center(
                        child: Padding(
                            padding: EdgeInsets.only(left: 0, top: 15),
                            child: FutureBuilder(
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var map = Map<String, dynamic>.from(
                                      snapshot.data as Map);
                                  name.text = map['name'];
                                  return (map != null)
                                      ? Center(
                                          child: SizedBox(
                                            width: 240,
                                            child: Center(
                                              child: Text(
                                                name.text,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const CircularProgressIndicator();
                                }
                                return Container();
                              },
                              future: collect_user_info()
                                  .mapv1, // use delay function in return then return the respective value
                            )),
                      ),
                      GestureDetector(
                        onTap: () async {
                          showDialog(
                              context: context,
                              barrierDismissible: false // user must tap button
                              , //
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Update Your Name"),
                                  elevation: 60,
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.black87,
                                  ),
                                  iconPadding: EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                  ),
                                  actions: [
                                    Column(
                                      children: [
                                        TextField(
                                          maxLength: 20,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.horizontal(
                                                          left: Radius.circular(
                                                              20),
                                                          right:
                                                              Radius.circular(
                                                                  20))),
                                              hintText: "Enter Your Name"),
                                          controller: name,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                for (var i in user_lists) {
                                                  if (name.text.toString() ==
                                                      i) {
                                                    name_already_exists = true;
                                                    break;
                                                  } else {
                                                    name_already_exists = false;
                                                  }
                                                }
                                                if (name_already_exists ==
                                                    false) {
                                                  user_lists.clear();
                                                  FirebaseDatabase.instance
                                                      .ref('Users')
                                                      .child(FirebaseAuth
                                                          .instance
                                                          .currentUser!
                                                          .uid)
                                                      .child('name')
                                                      .set(name.text);
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              chat_user_list()));
                                                } else {
                                                  var temp = name.text;
                                                  Future.delayed(Duration(
                                                          milliseconds: 1500))
                                                      .then((value) =>
                                                          name.text = temp);
                                                  name.text =
                                                      "Username Already Exists";
                                                }
                                              },
                                              child: Text(
                                                "Update",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.black),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.black),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                );
                              });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(left: 0, top: 16),
                            child: Icon(
                              Icons.edit,
                              size: 24,
                            )),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(left: 0, top: 30),
                        child: Text(
                          "🅐🅑🅞🅤🅣",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            barrierDismissible: false // user must tap button
                            ,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Edit About YourSelf"),
                                elevation: 60,
                                icon: Icon(
                                  Icons.info,
                                  color: Colors.black87,
                                ),
                                iconPadding: EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                ),
                                actions: [
                                  Column(
                                    children: [
                                      TextField(
                                        controller: about,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.horizontal(
                                                      left: Radius.circular(20),
                                                      right:
                                                          Radius.circular(20))),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                FirebaseDatabase.instance
                                                    .ref('Users')
                                                    .child(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .child('about')
                                                    .set(about.text);
                                                Navigator.pop(context);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            chat_user_list()));
                                              },
                                              child: Text(
                                                "Update",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.black)),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              );
                            });
                      },
                      child: Padding(
                          padding: EdgeInsets.only(left: 0, top: 30),
                          child: Icon(
                            Icons.edit,
                            size: 23,
                          )),
                    )
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: FutureBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var map =
                              Map<String, dynamic>.from(snapshot.data as Map);
                          about.text = map['about'];
                          return (map != null)
                              ? Text(
                                  about.text,
                                  style: TextStyle(fontSize: 14.5),
                                  textAlign: TextAlign.center,
                                )
                              : const CircularProgressIndicator();
                        }
                        return Container();
                      },
                      future: collect_user_info().mapv1,
                    )),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 180),
                      child: Text(
                        "𝙻𝚘𝚐𝚘𝚞𝚝‌",
                        style: TextStyle(fontSize: 23),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30, top: 180),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius:
                                BorderRadius.all(Radius.circular(35))),
                        child: IconButton(
                          splashColor: Colors.black,
                          splashRadius: 36,
                          icon: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () async {
                            var current_timestamp =
                                DateTime.now().microsecondsSinceEpoch;
                            FirebaseDatabase.instance
                                .ref('Users')
                                .child(user!.uid)
                                .child('status')
                                .set(current_timestamp.toString());
                            FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => sign_login()));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        "Account Delete",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 20),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius:
                                BorderRadius.all(Radius.circular(35))),
                        child: IconButton(
                          splashColor: Colors.black,
                          splashRadius: 36,
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                        "Are You Sure To Delete Your Account"),
                                    elevation: 60,
                                    icon: Icon(
                                      Icons.info,
                                      color: Colors.black87,
                                    ),
                                    iconPadding: EdgeInsets.only(bottom: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              FirebaseAuth.instance.currentUser!
                                                  .delete();
                                              FirebaseAuth.instance.signOut();
                                              await FirebaseDatabase.instance
                                                  .ref('Users')
                                                  .child(user!.uid)
                                                  .remove();
                                              Navigator.pop(context);
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          sign_login()));
                                            },
                                            child: Text(
                                              "Yes",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "No",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black),
                                          )
                                        ],
                                      )
                                    ],
                                  );
                                });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )),
        body: FirebaseAnimatedList(
          query: FirebaseDatabase.instance.ref('Users'),
          itemBuilder:
              (BuildContext context, DataSnapshot snapshot, animation, index) {
            if (user != null) {
              if (snapshot.exists) {
                if (snapshot.key != user?.uid) {
                  var m = Map<String, dynamic>.from(snapshot.value as Map);
                  user_lists.add(m['name']);
                  if (m['name'] != '') {
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black87, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60)),
                              color: Colors.black87),
                          child: ClipOval(
                            child: isdeviceConnected
                                ? (m['profile_pic'] != '')
                                    ? Image.network(m['profile_pic'])
                                    : Container(
                                        child: Icon(Icons.person),
                                      )
                                : Container(child: Icon(Icons.person)),
                          ),
                        ),
                        title: Text(m['name']),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShowCaseWidget(
                                      builder: Builder(
                                        builder: (_) => User_Chats(
                                          user_name: m['name'],
                                          profile_pic: m['profile_pic'],
                                        ),
                                      ),
                                    ))),
                      ),
                    );
                  } else {
                    return Container();
                  }
                } else {
                  var m = Map<String, dynamic>.from(snapshot.value as Map);
                  current_user_name = m['name'];
                  return Container();
                }
              } else {
                return Container();
              }
            } else {
              initialize_currentUser();
              return Container();
            }
          },
        ),
      ),
    );
  }
}
