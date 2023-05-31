import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/Screens/home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  CreateGroup({required this.memberList, Key? key}) : super(key: key);
  final List<Map<String, dynamic>> memberList;

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = false;
 void createGroup() async {
  setState(() {
    isloading = true;
  });
  String groupId = Uuid().v1();
  await _firestore
      .collection('groups')
      .doc(groupId)
      .set({"members": widget.memberList, "id": groupId});
  for (int i = 0; i < widget.memberList.length; i++) {
    String uid = widget.memberList[i]['uid'];
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .doc(groupId)
        .set({"name": _groupName.text, "id": groupId});
  }
  await _firestore.collection('groups').doc(groupId).collection('chats').add({
    "message": "${_auth.currentUser!.displayName} created this group",
    "type": "notify",
  });

  // Fetch and print the members of the group
  DocumentSnapshot groupSnapshot =
      await _firestore.collection('groups').doc(groupId).get();
  if (groupSnapshot.exists) {
    Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;

    if (groupData != null && groupData.containsKey('members')) {
      List<dynamic> members = groupData['members'] as List<dynamic>;
      print('Group Members:');
      members.forEach((member) {
        if (member.containsKey('uid') && member.containsKey('name')) {
          print('${member['uid']}: ${member['name']}');
        }
      });
    }
  }

  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => HomePage()), (route) => false);
}


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Name"),
      ),
      body: isloading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(height: size.height / 10),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    height: size.height / 14,
                    width: size.width / 1.2,
                    child: TextField(
                      controller: _groupName,
                      decoration: InputDecoration(
                          hintText: "Enter group name",
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
                      createGroup();
                    },
                    child: Text("Create Group")),
                SizedBox(
                  height: size.height / 30,
                ),
              ],
            ),
    );
  }
}
