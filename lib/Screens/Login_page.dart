import 'package:firebase_project/Screens/home_page.dart';
import 'package:firebase_project/Screens/register_page.dart';
import 'package:flutter/material.dart';

import '../methods/login.dart';

class Login_page extends StatefulWidget {
  Login_page({super.key});

  @override
  State<Login_page> createState() => _Login_pageState();
}

class _Login_pageState extends State<Login_page> {
  TextEditingController emailcontroller = TextEditingController();

  TextEditingController passwordcontroller = TextEditingController();
  bool isloading = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(hintText: "email"),
              controller: emailcontroller,
            ),
            TextFormField(
              decoration: InputDecoration(hintText: "password"),
              controller: passwordcontroller,
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: (() async {
                if (emailcontroller.text.isNotEmpty &&
                    passwordcontroller.text.isNotEmpty) {
                  setState(() {
                    isloading = true;
                  });

                  Login(emailcontroller.text.toString(),
                          passwordcontroller.text.toString())
                      .then((user) {
                    if (user != null) {
                      print("login sucessful");
                      setState(() {
                        isloading = false;
                      });
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => HomePage()));
                    } else {
                      print("login failed");
                      setState(() {
                        isloading = false;
                      });
                    }
                  });
                } else {
                  print("please fill the form correctly");
                }
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (BuildContext context) => HomePage()));
              }),
              child: Text("sign_up"),
            ),
            TextButton(
                onPressed: () {
                  print("register page");
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => RegisterPage())));
                },
                child: Text("register"))
          ],
        ),
      )),
    );
  }
}
