import 'package:audioplayers/audioplayers.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chatapp/Chat_user_list.dart';
import 'package:flutter_chatapp/FirebaseServices/auth.dart';
import 'package:flutter_chatapp/User_info_details.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class sign_login extends StatefulWidget {
  const sign_login({Key? key}) : super(key: key);
  @override
  State<sign_login> createState() => _sign_loginState();
}

class _sign_loginState extends State<sign_login> {
  var c_mail = TextEditingController();
  var c_pass = TextEditingController();
  var c_repass = TextEditingController();
  var l_mail = TextEditingController();
  var l_pass = TextEditingController();
  var password_reset_mail = TextEditingController();
  bool validate_c_mail = false;
  bool validate_c_pass = false;
  bool validate_c_repass = false;
  bool validate_l_mail = false;
  bool validate_l_pass = false;
  bool password_mode = true;
  bool retype_password_mode = true;
  bool create_or_login_page = true;
  dynamic enable_circular_processor;
  final pageController = PageController(initialPage: 0);
  double page_index = 0;
  void shared_preferences_function() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('first_time', true);
    sharedPreferences.setBool('first_time2', true);
  }

  @override
  Widget build(BuildContext context) {
    shared_preferences_function();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.purpleAccent[100],
          foregroundColor: Colors.black87,
          centerTitle: true,
          elevation: 10,
          shadowColor: Colors.purple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(35))),
          title: Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "🅢❷🅕🅒🅗🅐🅣",
              style: TextStyle(fontSize: 26),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        pageController.animateToPage(0,
                            duration: Duration(milliseconds: 1000),
                            curve: Curves.linearToEaseOut);
                        setState(() {
                          create_or_login_page = true;
                        });
                      },
                      child: Text(
                        "Create",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            decoration: create_or_login_page
                                ? TextDecoration.underline
                                : null,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationColor: Colors.black,
                            decorationThickness: 3),
                      ),
                    ),
                  ),
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        pageController.animateToPage(1,
                            duration: Duration(milliseconds: 1000),
                            curve: Curves.linearToEaseOut);
                        setState(() {
                          create_or_login_page = false;
                        });
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            decoration: create_or_login_page
                                ? null
                                : TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.solid,
                            decorationColor: Colors.black,
                            decorationThickness: 3),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (i) {
                    if (i == 0) {
                      setState(() {
                        create_or_login_page = true;
                      });
                    } else {
                      setState(() {
                        create_or_login_page = false;
                      });
                    }
                  },
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  "🅒🅡🅔🅐🅣🅔",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                )),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 40, top: 20, right: 40),
                            child: SizedBox(
                                width: 300,
                                child: TextField(
                                  controller: c_mail,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      fillColor: Colors.white38,
                                      filled: true,
                                      errorText: validate_c_mail
                                          ? "please enter a valid email"
                                          : null,
                                      border: OutlineInputBorder(),
                                      hintText: "Mail",
                                      prefixIcon: IconTheme(
                                        data: IconThemeData(
                                            color: Colors.black87),
                                        child: Icon(Icons.mail),
                                      )),
                                )),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 40, top: 20, right: 40),
                            child: SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: c_pass,
                                obscureText: retype_password_mode,
                                obscuringCharacter: "#",
                                decoration: InputDecoration(
                                    fillColor: Colors.white38,
                                    filled: true,
                                    errorText: validate_c_pass
                                        ? "minimum 6 characters"
                                        : null,
                                    border: OutlineInputBorder(),
                                    hintText: "Password",
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          retype_password_mode =
                                              retype_password_mode
                                                  ? false
                                                  : true;
                                        });
                                      },
                                      child: Icon(retype_password_mode
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                    prefixIcon: IconTheme(
                                      data:
                                          IconThemeData(color: Colors.black87),
                                      child: Icon(Icons.lock_outline),
                                    )),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 40, top: 20, right: 40),
                            child: SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: c_repass,
                                obscureText: retype_password_mode,
                                obscuringCharacter: "#",
                                decoration: InputDecoration(
                                    fillColor: Colors.white38,
                                    filled: true,
                                    errorText: validate_c_repass
                                        ? "password doesn't match"
                                        : null,
                                    border: OutlineInputBorder(),
                                    hintText: "Re-Type Password",
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          retype_password_mode =
                                              retype_password_mode
                                                  ? false
                                                  : true;
                                        });
                                      },
                                      child: Icon(retype_password_mode
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                    prefixIcon: IconTheme(
                                      data:
                                          IconThemeData(color: Colors.black87),
                                      child: Icon(Icons.lock_outline_sharp),
                                    )),
                              ),
                            ),
                          ),
                          OutlinedButton(
                              onPressed: () async {
                                if (EmailValidator.validate(
                                    c_mail.text.trim())) {
                                  setState(() {
                                    validate_c_mail = false;
                                  });
                                  if (c_pass.text.trim().length >= 6) {
                                    setState(() {
                                      validate_c_pass = false;
                                    });
                                    if (c_repass.text.trim() ==
                                        c_pass.text.trim()) {
                                      setState(() {
                                        validate_c_repass = false;
                                      });
                                      var res = await auth_service()
                                          .create_user_email_pass(
                                              c_mail.text, c_pass.text);
                                      if (res != null) {
                                        Map<String, dynamic> map = {
                                          'name': '',
                                          'about': '',
                                          'profile_pic': ''
                                        };
                                        FirebaseDatabase.instance
                                            .ref("Users")
                                            .child(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .set(map);
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                child: ShowCaseWidget(
                                                  builder: Builder(
                                                    builder: (_) => user_info(),
                                                  ),
                                                ),
                                                type: PageTransitionType.fade,
                                                duration: Duration(
                                                    milliseconds: 1500)));
                                      } else {
                                        AudioPlayer().play(
                                            AssetSource('pop_up.wav'),
                                            volume: 0.1);
                                        MotionToast(
                                          primaryColor: Colors.purpleAccent,
                                          displayBorder: true,
                                          icon: Icons.no_accounts_sharp,
                                          iconSize: 50,
                                          barrierColor: Colors.black54,
                                          secondaryColor: Colors.black,
                                          enableAnimation: true,
                                          description: Text(
                                            "This email address is already in use by another account.",
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ).show(context);
                                      }
                                    } else {
                                      setState(() {
                                        validate_c_mail = false;
                                        validate_c_pass = false;
                                        validate_c_repass = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      validate_c_mail = false;
                                      validate_c_pass = true;
                                      validate_c_repass = false;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    validate_c_mail = true;
                                    validate_c_pass = false;
                                    validate_c_repass = false;
                                  });
                                }
                              },
                              child: Text("🄲🅁🄴🄰🅃🄴"),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.black87,
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16))),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  "🅛🅞🅖🅘🅝",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                )),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 40, top: 20, right: 40),
                            child: SizedBox(
                              width: 300,
                              child: TextField(
                                controller: l_mail,
                                decoration: InputDecoration(
                                    fillColor: Colors.white38,
                                    filled: true,
                                    errorText: validate_l_mail
                                        ? "please enter a valid email"
                                        : null,
                                    border: OutlineInputBorder(),
                                    hintText: "Mail",
                                    prefixIcon: IconTheme(
                                      data:
                                          IconThemeData(color: Colors.black87),
                                      child: Icon(Icons.mail),
                                    )),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 40, top: 20, right: 40),
                            child: SizedBox(
                              width: 300,
                              child: TextFormField(
                                obscureText: password_mode,
                                controller: l_pass,
                                obscuringCharacter: "#",
                                decoration: InputDecoration(
                                    fillColor: Colors.white38,
                                    filled: true,
                                    errorText: validate_l_pass
                                        ? "minimum 6 characters"
                                        : null,
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          password_mode =
                                              password_mode ? false : true;
                                        });
                                      },
                                      child: Icon(password_mode
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                    border: OutlineInputBorder(),
                                    hintText: "Password",
                                    prefixIcon: IconTheme(
                                      data:
                                          IconThemeData(color: Colors.black87),
                                      child: Icon(Icons.lock_outline),
                                    )),
                              ),
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton(
                                  onPressed: () async {
                                    var res;
                                    if (EmailValidator.validate(
                                        l_mail.text.trim())) {
                                      setState(() {
                                        validate_l_mail = false;
                                      });
                                      if (l_pass.text.trim().length >= 6) {
                                        setState(() {
                                          validate_l_pass = false;
                                        });
                                        res = await auth_service()
                                            .sign_with_email_pass(
                                                l_mail.text, l_pass.text);
                                        if (res == null) {
                                          AudioPlayer().play(
                                              AssetSource('pop_up.wav'),
                                              volume: 0.1);
                                          MotionToast(
                                            primaryColor: Colors.purpleAccent,
                                            displayBorder: true,
                                            icon: Icons.no_accounts_sharp,
                                            iconSize: 50,
                                            barrierColor: Colors.black54,
                                            secondaryColor: Colors.black,
                                            enableAnimation: true,
                                            description: Text(
                                              "Incorrect Username Or Password",
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ).show(context);
                                        }
                                        if (res != null) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShowCaseWidget(
                                                      builder: Builder(
                                                        builder: (_) =>
                                                            chat_user_list(),
                                                      ),
                                                    )),
                                          );
                                        }
                                      } else {
                                        setState(() {
                                          validate_l_pass = true;
                                          validate_l_mail = false;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        validate_l_mail = true;
                                        validate_l_pass = false;
                                      });
                                    }
                                  },
                                  child: Text("🅂🄸🄶🄽 🄸🄽"),
                                  style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black87,
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Password Reset"),
                                              backgroundColor:
                                                  Colors.purple[100],
                                              elevation: 60,
                                              icon: Icon(
                                                Icons.info,
                                                color: Colors.black87,
                                              ),
                                              iconPadding:
                                                  EdgeInsets.only(bottom: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(50)),
                                              ),
                                              actions: [
                                                Center(
                                                  child: Column(
                                                    children: [
                                                      TextField(
                                                        decoration: InputDecoration(
                                                            border:
                                                                OutlineInputBorder(),
                                                            fillColor:
                                                                Colors.white,
                                                            filled: true,
                                                            hintText:
                                                                "Enter Your Email"),
                                                        controller:
                                                            password_reset_mail,
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (EmailValidator
                                                              .validate(
                                                                  password_reset_mail
                                                                      .text
                                                                      .trim())) {
                                                            auth_service()
                                                                .reset_password(
                                                                    password_reset_mail
                                                                        .text);
                                                            AudioPlayer().play(
                                                                AssetSource(
                                                                    'pop_up.wav'),
                                                                volume: 0.1);
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              content: Text(
                                                                  "Check Your Mail (Including Spam Folder)"),
                                                            ));
                                                            Navigator.pop(
                                                                context);
                                                          } else {
                                                            AudioPlayer().play(
                                                                AssetSource(
                                                                    'pop_up.wav'),
                                                                volume: 0.1);
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                              content: Text(
                                                                  "There Is No Account For This Email"),
                                                            ));
                                                          }
                                                        },
                                                        child: Text(
                                                          "Reset Password",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            );
                                          });
                                    },
                                    child: Text(
                                      "Forgot Password ?",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                          decoration: TextDecoration.underline,
                                          decorationThickness: 1,
                                          decorationColor: Colors.black54,
                                          decorationStyle:
                                              TextDecorationStyle.solid),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
