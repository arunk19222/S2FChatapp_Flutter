import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Chat_user_list.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:showcaseview/showcaseview.dart';

class user_info extends StatefulWidget {
  const user_info({Key? key}) : super(key: key);

  @override
  State<user_info> createState() => _user_infoState();
}

class _user_infoState extends State<user_info> {
  final firebase_database = FirebaseDatabase.instance;
  var name = TextEditingController();
  var about_me = TextEditingController();
  var name_already_exist = false;
  var user_lists = [];
  PlatformFile? pickedFile;
  dynamic uploaded_image = Container();
  var pic_path;
  dynamic progress;

  Future selectFile() async {
    final select_file =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (select_file != null) {
      pickedFile = select_file.files.first;
      setState(() {
        uploaded_image = ClipOval(
          child: Image.file(
            File(pickedFile!.path!),
          ),
        );
      });
    } else {
      setState(() {
        uploaded_image = ClipOval(
          child: Container(
            color: Colors.black,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent[100],
        title: Text(
          "🅓🅔🅣🅐🅘🅛🅢",
          style: TextStyle(fontSize: 26),
        ),
        elevation: 10,
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
        shadowColor: Colors.purple,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 0,
              height: 0,
              child: FirebaseAnimatedList(
                  query: FirebaseDatabase.instance.ref("Users"),
                  itemBuilder:
                      (context, DataSnapshot snapshot, animation, index) {
                    if (snapshot.exists) {
                      if (FirebaseAuth.instance.currentUser!.uid !=
                          snapshot.key) {
                        var map =
                            Map<dynamic, dynamic>.from(snapshot.value as Map);
                        user_lists.add(map['name']);
                      }
                    }

                    return Text('');
                  }),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Container(
                  width: 100,
                  height: 100,
                  child: GestureDetector(
                    onTap: selectFile,
                    child: uploaded_image,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.all(Radius.circular(100))),
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SizedBox(
                  width: 260,
                  child: Theme(
                    data: ThemeData(primaryColor: Colors.black87),
                    child: TextField(
                      maxLength: 20,
                      controller: name,
                      decoration: InputDecoration(
                          errorText:
                              name_already_exist ? "name already exist" : null,
                          hintText: "Enter Your Name",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2))),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 60, right: 250),
              child: Text(
                "Description",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SizedBox(
                  width: 260,
                  height: 100,
                  child: Theme(
                    data: ThemeData(primaryColor: Colors.black87),
                    child: TextField(
                      maxLines: 2,
                      controller: about_me,
                      decoration: InputDecoration(
                          hintText: "About You",
                          labelText: "About You",
                          labelStyle: TextStyle(color: Colors.black87),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 2))),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 130),
              child: SizedBox(
                width: 110,
                height: 55,
                child: OutlinedButton(
                  onPressed: () async {
                    if (name.text != '') {
                      for (var i in user_lists) {
                        if (name.text.toString() == i) {
                          setState(() {
                            name_already_exist = true;
                          });
                          break;
                        } else {
                          setState(() {
                            name_already_exist = false;
                          });
                        }
                      }

                      if (name_already_exist) {
                      } else {
                        setState(() {
                          name_already_exist = false;
                        });
                        Map<String, String> map = {
                          'name': name.text.toString(),
                          'about': about_me.text.toString()
                        };
                        FirebaseDatabase.instance
                            .ref("Users")
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .update(map);
                        if (pickedFile != null) {
                          final ref = await FirebaseStorage.instance
                              .ref('profile_pics/${name.text}');
                          ref
                              .putFile(File(pickedFile!.path!))
                              .snapshotEvents
                              .listen((event) async {
                            switch (event.state) {
                              case TaskState.running:
                                setState(() {
                                  progress =
                                      event.bytesTransferred / event.totalBytes;
                                });
                                break;
                              case TaskState.success:
                                setState(() {
                                  progress = null;
                                });
                                final snapshot = await FirebaseStorage.instance
                                    .ref('profile_pics/${name.text}')
                                    .getDownloadURL();
                                FirebaseDatabase.instance
                                    .ref('Users')
                                    .child(
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .child('profile_pic')
                                    .set(snapshot);
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ShowCaseWidget(
                                            builder: Builder(
                                              builder: (_) => chat_user_list(),
                                            ),
                                          )),
                                );
                            }
                          });
                        } else {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShowCaseWidget(
                                      builder: Builder(
                                        builder: (_) => chat_user_list(),
                                      ),
                                    )),
                          );
                        }
                        //Navigator.pop(context);

                      }
                    }
                  },
                  child: Icon(
                    Icons.done,
                    color: Colors.white,
                    size: 40,
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            topLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    backgroundColor: Colors.black87,
                  ),
                ),
              ),
            ),
            (progress != null)
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: LinearPercentIndicator(
                      percent: ((100 * progress).roundToDouble()) / 100,
                      lineHeight: 20,
                      backgroundColor: Colors.black87,
                      progressColor: Colors.purple[300],
                      barRadius: Radius.circular(30),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    uploaded_image = IconButton(
      icon: Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
      onPressed: selectFile,
    );
  }
}
