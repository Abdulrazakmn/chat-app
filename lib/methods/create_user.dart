import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<User?> createUser(String name, String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print("Account created  sucessfully");
      // ignore: deprecated_member_use
      user.updateProfile(displayName: name);
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({"name": name, "email": email, "status": "unavailable",
          "uid":_auth.currentUser!.uid});
      return user;
    } else {
      print("login failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}
