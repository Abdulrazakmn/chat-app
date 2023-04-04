import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_project/Screens/chat_room.dart';
import 'package:firebase_project/methods/logout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  bool isloading = false;
  Map<String, dynamic>? userMap;
 final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    setStatus("online");
  }
  void setStatus(String status)async{
    await _firestore.collection('users').doc(_auth.currentUser?.uid).update({"status":status,});

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if(state==AppLifecycleState.resumed){
      setStatus("online");
      //online
    }
    else{
      setStatus("offline");
      //offline

    }
  }
  String chatRoomId(String user1,String user2){
    if (user1 == null || user2 == null || user1.isEmpty || user2.isEmpty) {
  throw ArgumentError('user1 and user2 cannot be null or empty');
}

   else if(user1[0].toLowerCase().codeUnits[0] > user2[0].toLowerCase().codeUnits[0]){
      return "$user1$user2";//user 1 want  chat with user 2

    }
    else{
      return "$user2$user1";//return id if user2 want chat with user
    }

  }
  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    setState(() {
      isloading = true;
    });
    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isloading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              logOut(context);
            },
            icon: Icon(Icons.logout)),

      ]),
      body: isloading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.width / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.2,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                ElevatedButton(
                    onPressed: () {
                      onSearch();
                    },
                    child: Text("Search")),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? ListTile(
                        onTap: (() {
                          String roomId=chatRoomId(_auth.currentUser!.displayName! ,userMap!['name']);//i am using uid instead of display name
                        //  String roomId=chatRoomId('razak',userMap!['name']);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChatRoom(chatRoomId:roomId, userMap: userMap!,)));
                        }),
                        leading: Icon(
                          Icons.account_box,
                          color: Colors.black,
                        ),
                        title: Text(userMap!['name']),
                        subtitle: Text(userMap!['email']),
                        trailing: Icon(Icons.chat, color: Colors.black),
                      )
                    : Container()
              ],
            ),
    );
  }

 
}
