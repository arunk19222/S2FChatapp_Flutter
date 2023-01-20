import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class collect_user_info {
  var m;
  var pic_path;
  var users_lists = [];
  var rec_user_id;
  final ref = FirebaseDatabase.instance.ref('Users');
  Future<Map> name_and_about() async {
    DataSnapshot snapshot =
        await ref.child(FirebaseAuth.instance.currentUser!.uid).get();
    if (snapshot.exists) {
      m = await Map<String, dynamic>.from(snapshot.value as Map);
    }
    return m;
  }

  Future<String> pic() async {
    var snapshot = await FirebaseDatabase.instance
        .ref('Users')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('profile_pic')
        .get();
    print("arun ${snapshot.value}");
    if (snapshot.exists) {
      pic_path = await snapshot.value;
      return pic_path;
    } else {
      pic_path = await snapshot.value;
      return pic_path;
    }
  }

  Future<Map> get mapv1 {
    return Future.delayed(Duration(milliseconds: 1200))
        .then((value) => name_and_about());
  }

  Future<String> get mapv2 {
    return Future.delayed(Duration(milliseconds: 1200)).then((value) => pic());
  }
}
