import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import '../Screens/add_members.dart';
import 'group_chat_room.dart';


class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<GroupChatHomeScreen> createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = true;
  List groupList = [];
  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;

        isloading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Groups"),
      ),
      body: isloading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: ((context, index) {
                return ListTile(
                    title: Text(groupList[index]['name']),
                    leading: Icon(Icons.group),
                    onTap: (() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => GroupChatRoom(
                                groupChatId: groupList[index]['id'],
                                groupName: groupList[index]['name'],
                              )));
                    }));
              })),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: (() => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context)=>AddMembersInGroupCreation()))),
        tooltip: "Crate Group",
      ),
    );
  }
}
