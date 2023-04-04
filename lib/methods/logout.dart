import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_project/Screens/Login_page.dart';

import 'package:flutter/material.dart';

Future logOut(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
  await  _auth.signOut().then((value) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Login_page()));
  });
  } catch (e) {
    print(e);
    return null;
  }
}
