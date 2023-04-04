import 'package:firebase_auth/firebase_auth.dart';

Future<User?> Login(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    User? user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
    if (user != null) {
      print("login sucessful");
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
