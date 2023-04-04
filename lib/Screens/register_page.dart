import 'package:firebase_project/methods/create_user.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController name_editingcontroller = TextEditingController();

  TextEditingController emailcontroller = TextEditingController();

  TextEditingController passwordcontroller = TextEditingController();

  bool isloading = false;

  void login(String user, String password) async {
    //final controller = Get.put(DataController(us:user,pass: password ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isloading
          ? CircularProgressIndicator(color: Colors.red,)
          : Center(
              child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(hintText: "Name"),
                    controller: name_editingcontroller,
                  ),
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
                      onPressed: () {
                        print("register page");
                        if (name_editingcontroller.text.isNotEmpty &&
                            emailcontroller.text.isNotEmpty &&
                            passwordcontroller.text.isNotEmpty) {
                          setState(() {
                            isloading = true;
                          });
                          createUser(name_editingcontroller.text,
                                  emailcontroller.text, passwordcontroller.text)
                              .then((user) {
                            if (user != null) {
                              setState(() {
                                isloading = false;
                              });
                              print("register Successfull");
                            } else {
                              print("register  failed");
                            }
                          });
                        }
                      },
                      child: Text("register"))
                ],
              ),
            )),
    );
  }
}
