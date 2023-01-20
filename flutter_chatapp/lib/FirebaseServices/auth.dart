import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class auth_service {
  final FirebaseAuth _auth_instance = FirebaseAuth.instance;
  //sign in email
  Future sign_with_email_pass(String email, String pass) async {
    User? user;
    try {
      UserCredential user_cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      user = user_cred.user;
      FirebaseDatabase.instance
          .ref('Users')
          .child(user!.uid)
          .child('status')
          .set('online');
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    } finally {
      print("user--->>>${user?.uid}");
    }
  }

//create email
  Future create_user_email_pass(String email, String pass) async {
    try {
      UserCredential user_cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      User? user = user_cred.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  reset_password(String email) {
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
