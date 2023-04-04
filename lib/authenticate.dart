import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/Screens/Login_page.dart';
import 'package:firebase_project/Screens/home_page.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth=FirebaseAuth.instance;
   Authenticate({super.key});

  @override
  Widget build(BuildContext context) {
    if(_auth.currentUser!=null){
      return HomePage();

    }
    else{
      return Login_page();
    }
  }
}