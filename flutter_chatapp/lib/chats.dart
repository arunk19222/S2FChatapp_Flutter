import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:swipe_to/swipe_to.dart';

class User_Chats extends StatefulWidget {
  final user_name;
  final profile_pic;
  const User_Chats({Key? key, required this.user_name, this.profile_pic})
      : super(key: key);

  @override
  State<User_Chats> createState() => _User_ChatsState();
}

class _User_ChatsState extends State<User_Chats> with WidgetsBindingObserver {
  final clear_chat_key = GlobalKey();
  var chat_text_controller = TextEditingController();
  var users_lists = [];
  var check_date = '';
  var rec_user_id;
  var current_user_name;
  dynamic chat_text;
  dynamic store_date = '';
  var check_same_date = false;
  dynamic chat_date_display = '';
  var reciever_user_id;
  bool start_only = true;
  String reciever_status = '';
  ScrollController scrollController = ScrollController();
  var isdeviceConnected = false;
  Container swipe_container = Container(
    width: 0,
    height: 0,
  );
  var istyping = false;
  final focus_node = FocusNode();
  var swipe_reply_msg = '';
  bool isSwipedToReply = false;
  bool whoSwiped = false;
  void shared_preferences_function() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getBool('first_time2') == true) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ShowCaseWidget.of(context).startShowCase([clear_chat_key]));
      sharedPreferences.setBool('first_time2', false);
    }
  }

  void functionop() {
    print("onsubmitted");
  }

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

  Container replyBoxContainer(String msg, bool isSendbyme) {
    swipe_reply_msg = msg;
    isSwipedToReply = true;
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        color: isSendbyme ? Colors.black : Colors.purple,
      ),
      child: Column(
        children: [
          Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                  onTap: () {
                    isSwipedToReply = false;
                    setState(() {
                      swipe_container = Container(
                        width: 0,
                        height: 0,
                      );
                    });
                  },
                  child: Container(
                    child: Icon(
                      Icons.close,
                      color: isSendbyme ? Colors.white : Colors.black,
                      size: 21,
                    ),
                  ))),
          Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 70,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, bottom: 1),
                  child: Text(
                    isSendbyme ? 'You: $msg' : '${widget.user_name}: $msg',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatDisplayStyle(String chat, String date, String time, bool sender,
      bool hasreply, String replyChat, bool recieved) {
    return Container(
      padding: sender
          ? EdgeInsets.only(left: 30, right: 8, top: 10, bottom: 10)
          : EdgeInsets.only(left: 8, right: 30, top: 10, bottom: 10),
      child: Align(
        alignment: (sender ? Alignment.topRight : Alignment.topLeft),
        child: Container(
          decoration: BoxDecoration(
            color: sender ? Colors.purple[200] : Color.fromRGBO(9, 1, 10, 20),
            borderRadius: sender
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    topLeft: Radius.circular(25))
                : BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    topRight: Radius.circular(25)),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              (chat != '|||Msg Deleted|||')
                  ? (hasreply)
                      ? Container(
                          decoration: BoxDecoration(
                            color: sender ? Colors.black87 : Colors.purple[200],
                            border: Border.all(color: Colors.white, width: 2.5),
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                topLeft: Radius.circular(10)),
                          ),
                          padding: EdgeInsets.all(15),
                          child: Text(
                            replyChat,
                            style: TextStyle(
                              fontSize: 12,
                              color: sender ? Colors.white : Colors.black,
                            ),
                          ))
                      : Container(
                          width: 0,
                          height: 0,
                        )
                  : Container(
                      width: 0,
                      height: 0,
                    ),
              Text(
                chat,
                style: sender
                    ? TextStyle(
                        fontSize: 12,
                        color: (chat != '|||Msg Deleted|||')
                            ? Colors.black87
                            : Colors.black54,
                        fontWeight: FontWeight.bold)
                    : TextStyle(
                        fontSize: 12,
                        color: (chat != '|||Msg Deleted|||')
                            ? Colors.white
                            : Colors.white54),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.5),
                child: Text(
                  time,
                  style: sender
                      ? TextStyle(
                          fontSize: 10,
                          color: (chat != '|||Msg Deleted|||')
                              ? Colors.black87
                              : Colors.black54,
                          fontWeight: FontWeight.w600)
                      : TextStyle(
                          fontSize: 10,
                          color: (chat != '|||Msg Deleted|||')
                              ? Colors.white
                              : Colors.white54,
                          fontWeight: FontWeight.w600),
                ),
              ),
              Text('[$date]',
                  style: sender
                      ? TextStyle(
                          fontSize: 10,
                          color: (chat != '|||Msg Deleted|||')
                              ? Colors.black87
                              : Colors.black54,
                          fontWeight: FontWeight.w700)
                      : TextStyle(
                          fontSize: 10,
                          color: (chat != '|||Msg Deleted|||')
                              ? Colors.white
                              : Colors.white54,
                          fontWeight: FontWeight.w700)),
              sender
                  ? (chat != '|||Msg Deleted|||')
                      ? Padding(
                          padding: const EdgeInsets.only(left: 70),
                          child: Icon(
                            Icons.done_all,
                            size: 14,
                            color: recieved ? Colors.black : Colors.white,
                          ),
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        )
                  : Container(
                      width: 0,
                      height: 0,
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget toDisplayChats(Map m, bool sender, bool hasReply) {
    bool message_recieved = false;
    if (m['recieved'] != null) {
      if (m['recieved']) {
        message_recieved = true;
      }
    }
    var currrent_date = DateFormat("dd/MM/yyyy").format(DateTime.now());
    var date = DateFormat("dd/MM/yyyy")
        .format(DateTime.fromMicrosecondsSinceEpoch(m['timestamp']));
    var time = DateFormat("hh:mm a")
        .format(DateTime.fromMicrosecondsSinceEpoch(m['timestamp']));
    if (currrent_date == date) {
      return hasReply
          ? chatDisplayStyle(m['chat'], 'Today', time, sender, hasReply,
              m['reply'], message_recieved)
          : chatDisplayStyle(
              m['chat'], 'Today', time, sender, hasReply, '', message_recieved);
    } else {
      return hasReply
          ? chatDisplayStyle(m['chat'], date, time, sender, hasReply,
              m['reply'], message_recieved)
          : chatDisplayStyle(
              m['chat'], date, time, sender, hasReply, '', message_recieved);
    }
  }

  void add_chats_into_database() async {
    var current_timestamp = DateTime.now().microsecondsSinceEpoch;
    FirebaseDatabase.instance
        .ref('Users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(widget.user_name)
        .child(current_timestamp.toString())
        .child('ME')
        .set(isSwipedToReply
            ? {
                'timestamp': current_timestamp,
                'chat': chat_text_controller.text,
                'reply': whoSwiped
                    ? 'You: ${swipe_reply_msg.toString()}'
                    : '${widget.user_name}: ${swipe_reply_msg.toString()} ',
                'recieved': false
              }
            : {
                'timestamp': current_timestamp,
                'chat': chat_text_controller.text,
                'recieved': false
              });
    DataSnapshot snap = await FirebaseDatabase.instance
        .ref('Users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('name')
        .get();
    for (var i in users_lists) {
      DataSnapshot snapshot =
          await FirebaseDatabase.instance.ref('Users').child(i).get();
      Map m = Map<dynamic, dynamic>.from(snapshot.value as Map);
      if (m['name'] == widget.user_name) {
        FirebaseDatabase.instance
            .ref('Users')
            .child(i)
            .child(snap.value.toString())
            .child(current_timestamp.toString())
            .child('THEY')
            .set(isSwipedToReply
                ? {
                    'timestamp': current_timestamp,
                    'chat': chat_text_controller.text,
                    'reply': whoSwiped
                        ? '${widget.user_name}: ${swipe_reply_msg.toString()} '
                        : 'You: ${swipe_reply_msg.toString()}',
                  }
                : {
                    'timestamp': current_timestamp,
                    'chat': chat_text_controller.text,
                  });
        break;
      }
    }
    chat_text_controller.text = '';
    isSwipedToReply = false;
    swipe_reply_msg = '';
    scrollController.position.animateTo(
        scrollController.position.maxScrollExtent * 5,
        duration: Duration(milliseconds: 1200),
        curve: Curves.linear);
  }

  void check_it_is_delivered(String timeStamp) async {
    DataSnapshot? snap = await FirebaseDatabase.instance
        .ref('Users')
        .child(rec_user_id)
        .child(current_user_name)
        .child(timeStamp)
        .child('ME')
        .child('chat')
        .get();
    if (snap.exists) {
      FirebaseDatabase.instance
          .ref('Users')
          .child(rec_user_id)
          .child(current_user_name)
          .child(timeStamp)
          .child('ME')
          .child('recieved')
          .set(true);
    }
  }

  void get_reciever_status() async {
    final ref = FirebaseDatabase.instance.ref('Users');
    ref.once().then((DatabaseEvent event) async {
      Map m = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      for (var i in m.keys) {
        DataSnapshot snapshot =
            await FirebaseDatabase.instance.ref('Users').child(i).get();
        Map m = Map<dynamic, dynamic>.from(snapshot.value as Map);
        if (m['name'] == widget.user_name) {
          setState(() {
            rec_user_id = i;
          });
          break;
        }
      }
    });
  }

  void get_current_username() async {
    DataSnapshot? snap = await FirebaseDatabase.instance
        .ref('Users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('name')
        .get();
    current_user_name = snap.value.toString();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    final ref = FirebaseDatabase.instance.ref('Users');
    ref.once().then((DatabaseEvent databaseEvent) {
      Map m = Map<dynamic, dynamic>.from(databaseEvent.snapshot.value as Map);
      m.forEach((key, value) {
        users_lists.add(key);
      });
    });
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

  @override
  Widget build(BuildContext context) {
    shared_preferences_function();
    check_internet();
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    if (start_only) {
      Timer(Duration(milliseconds: 1000), () {
        scrollController.position.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut);
      });
      get_reciever_status();
      get_current_username();
      setState(() {
        start_only = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 15, top: 10),
              child: Showcase(
                key: clear_chat_key,
                description: 'Delete All The Chats',
                descTextStyle: TextStyle(fontSize: 15, color: Colors.white),
                targetBorderRadius: BorderRadius.circular(60),
                tooltipBackgroundColor: Colors.black,
                scaleAnimationCurve: Curves.easeIn,
                movingAnimationDuration: Duration(milliseconds: 1800),
                child: PopupMenuButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  color: Colors.black87,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                          value: 0,
                          child: Text(
                            "clear chats",
                            style: TextStyle(color: Colors.white),
                          )),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 0) {
                      swipe_reply_msg = '';
                      chat_text_controller.text = '';
                      isSwipedToReply = false;
                      setState(() {
                        swipe_container = Container();
                      });
                      FirebaseDatabase.instance
                          .ref('Users')
                          .child(FirebaseAuth.instance.currentUser!.uid)
                          .child(widget.user_name)
                          .remove();
                    }
                  },
                ),
              ))
        ],
        backgroundColor: Colors.purpleAccent[100],
        elevation: 10,
        centerTitle: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
        shadowColor: Colors.purple,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                  color: Colors.black87),
              child: (widget.profile_pic != '')
                  ? ClipOval(
                      child: isdeviceConnected
                          ? Image.network(widget.profile_pic)
                          : Container(
                              child: Icon(Icons.person),
                            ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 20, top: 10),
              child: Column(
                children: [
                  Text(
                    widget.user_name,
                    style: TextStyle(
                        fontSize:
                            (widget.user_name.toString().length > 14) ? 14 : 18,
                        fontWeight: FontWeight.w700),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: isdeviceConnected
                        ? (rec_user_id != null)
                            ? FadeIn(
                                child: StreamBuilder(
                                  stream: FirebaseDatabase.instance
                                      .ref('Users')
                                      .child(rec_user_id)
                                      .child('status')
                                      .onValue,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data!.snapshot.value
                                              .toString() ==
                                          'online') {
                                        return Text(
                                          'online',
                                          style: TextStyle(fontSize: 15),
                                        );
                                      } else if (snapshot.data!.snapshot.value
                                              .toString() ==
                                          'Typing...') {
                                        return Text(
                                          'Typing...',
                                          style: TextStyle(fontSize: 15),
                                        );
                                      } else {
                                        var time = DateFormat("hh:mm a").format(
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                int.parse(snapshot
                                                    .data!.snapshot.value
                                                    .toString())));
                                        var date = DateFormat("dd/MM/yyyy")
                                            .format(DateTime
                                                .fromMicrosecondsSinceEpoch(
                                                    int.parse(snapshot
                                                        .data!.snapshot.value
                                                        .toString())));
                                        var currrent_date =
                                            DateFormat("dd/MM/yyyy")
                                                .format(DateTime.now());
                                        if (currrent_date == date) {
                                          reciever_status = time;
                                        } else {
                                          reciever_status = date;
                                        }

                                        return Text(
                                          reciever_status,
                                          style: TextStyle(fontSize: 15),
                                        );
                                      }
                                    } else {
                                      return Container(
                                        width: 0,
                                        height: 0,
                                      );
                                    }
                                  },
                                ),
                                animate: true,
                                delay: Duration(milliseconds: 500),
                              )
                            : Container(
                                width: 0,
                                height: 0,
                              )
                        : Container(
                            width: 0,
                            height: 0,
                          ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).viewInsets.bottom == 0.0)
                    ? MediaQuery.of(context).size.height *
                        (MediaQuery.of(context).size.height / 1000)
                    : MediaQuery.of(context).size.height *
                        (MediaQuery.of(context).size.height / 1700),
                child: FirebaseAnimatedList(
                  controller: scrollController,
                  query: FirebaseDatabase.instance
                      .ref('Users')
                      .child(FirebaseAuth.instance.currentUser!.uid)
                      .child(widget.user_name),
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      animation, int index) {
                    if (snapshot.exists) {
                      Map m1 =
                          Map<dynamic, dynamic>.from(snapshot.value as Map);
                      Map m;
                      if (m1['ME'] != null) {
                        m = m1['ME'];
                        return GestureDetector(
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  FocusScope.of(context)
                                      .unfocus(); //use to unnecessary pop up keyboard displays
                                  return AlertDialog(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 50,
                                      color: Colors.purpleAccent,
                                    ),
                                    elevation: 60,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(50)),
                                    ),
                                    actions: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 0,
                                            bottom: 3,
                                            left: 3,
                                            right: 3),
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                FirebaseDatabase.instance
                                                    .ref('Users')
                                                    .child(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .child(widget.user_name)
                                                    .child(
                                                        snapshot.key.toString())
                                                    .child('ME')
                                                    .remove();
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Delete For me",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black87,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                FirebaseDatabase.instance
                                                    .ref('Users')
                                                    .child(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .child(widget.user_name)
                                                    .child(
                                                        snapshot.key.toString())
                                                    .child('ME')
                                                    .child('chat')
                                                    .set("|||Msg Deleted|||");
                                                FirebaseDatabase.instance
                                                    .ref('Users')
                                                    .child(
                                                        rec_user_id.toString())
                                                    .child(current_user_name)
                                                    .child(
                                                        snapshot.key.toString())
                                                    .child('THEY')
                                                    .child('chat')
                                                    .set("|||Msg Deleted|||");
                                                Navigator.pop(context);
                                              },
                                              child: Text("Delete For Both",
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.black87),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                });
                          },
                          child: SwipeTo(
                              onLeftSwipe: (m['chat'] != '|||Msg Deleted|||')
                                  ? () {
                                      whoSwiped = true;
                                      focus_node.requestFocus();
                                      setState(() {
                                        swipe_container =
                                            replyBoxContainer(m['chat'], true);
                                      });
                                    }
                                  : null,
                              child: Container(
                                  child: (m['reply'] == null)
                                      ? toDisplayChats(m, true, false)
                                      : toDisplayChats(m, true, true))),
                        );
                      } else {
                        m = m1['THEY'];
                        check_it_is_delivered(snapshot.key.toString());
                        return GestureDetector(
                            child: SwipeTo(
                                onRightSwipe: (m['chat'] != '|||Msg Deleted|||')
                                    ? () {
                                        whoSwiped = false;
                                        focus_node.requestFocus();
                                        setState(() {
                                          swipe_container = replyBoxContainer(
                                              m['chat'], false);
                                        });
                                      }
                                    : null,
                                child: Container(
                                    child: (m['reply'] == null)
                                        ? toDisplayChats(m, false, false)
                                        : toDisplayChats(m, false, true))));
                      }
                    } else {
                      return Container();
                    }
                  },
                )),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: swipe_container,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 3),
              child: GestureDetector(
                onTap: () {
                  (MediaQuery.of(context).viewInsets.bottom != 0.0)
                      ? scrollController.position
                          .jumpTo(scrollController.position.maxScrollExtent * 5)
                      : null;
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        width: 330,
                        padding: EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 4),
                            color: Colors.black12,
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(20),
                                right: Radius.circular(20))),
                        child: TextField(
                          onChanged: (i) {
                            FirebaseDatabase.instance
                                .ref('Users')
                                .child(FirebaseAuth.instance.currentUser!.uid)
                                .child('status')
                                .set('Typing...');
                            Future.delayed(Duration(seconds: 2)).then((value) {
                              FirebaseDatabase.instance
                                  .ref('Users')
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .child('status')
                                  .set('online');
                            });
                          },
                          onTap: () {
                            if (MediaQuery.of(context).viewInsets.bottom ==
                                0.0) {
                              scrollController.position.animateTo(
                                  scrollController.position.maxScrollExtent * 5,
                                  duration: Duration(milliseconds: 1200),
                                  curve: Curves.linear);
                            }
                          },
                          controller: chat_text_controller,
                          focusNode: focus_node,
                          maxLines: null,
                          decoration: InputDecoration(
                              hintText: 'Text Here', border: InputBorder.none),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40))),
                          child: IconButton(
                              onPressed: () {
                                isdeviceConnected
                                    ? (chat_text_controller.text != '')
                                        ? add_chats_into_database()
                                        : null
                                    : null;
                                setState(() {
                                  swipe_container = Container(
                                    width: 0,
                                    height: 0,
                                  );
                                });
                                AudioPlayer().play(AssetSource('send_btn2.mp3'),
                                    volume: 0.1);
                              },
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 30,
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
