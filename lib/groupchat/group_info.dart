import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/Screens/home_page.dart';
import 'package:firebase_project/groupchat/add_members.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupName, groupId;
  GroupInfo({required this.groupName, required this.groupId, Key? key}) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  bool isLoading = false;
  List memberList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

//   
Future getGroupDetails() async {
  await _firestore
      .collection('groups')
      .doc(widget.groupId)
      .get()
      .then((chatSnapshot) {
    if (chatSnapshot.exists) {
      var chatMap = chatSnapshot.data(); // Get the document data
      memberList = chatMap!['members'];
      print(memberList);
      isLoading = false;
      setState(() {});
    }
  });
}



  void removeUser(int index) async {
    if (_auth.currentUser?.uid != memberList[index]['uid']) {
      setState(() {
        isLoading = true;
      });
      String uid = memberList[index]['uid'];
      memberList.removeAt(index);
      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": memberList,
      });
      await _firestore.collection('users').doc(uid).collection('groups').doc(widget.groupId).delete();
      setState(() {
        isLoading = false;
      });
    }
  }

  void showRemoveDialog(int index) async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: ListTile(
            onTap: () => removeUser(index),
            title: Text("Remove This member"),
          ),
        );
      },
    );
  }

  void onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });
      String uid = _auth.currentUser!.uid;
      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['uid'] == uid) {
          memberList.removeAt(i);
        }
      }
      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": memberList,
      });
      await _firestore.collection('users').doc(uid).collection('groups').doc(widget.groupId).delete();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => HomePage()), (route) => false);
    } else {
      print("can't leave group");
    }
  }

  bool checkAdmin() {
    bool isadmin = false;
    memberList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isadmin = element['isAdmin'];
      }
    });
    return isadmin;
  }

  

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                    Flexible(
                      child: Container(
                        height: size.height / 8,
                        width: size.width / 1.1,
                        child: Row(
                          children: [
                            Container(
                              height: size.height / 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                              child: Icon(
                                Icons.group,
                                size: size.width / 14,
                              ),
                            ),
                            SizedBox(
                              width: size.width / 20,
                            ),
                            Container(
                              child: Text(
                                widget.groupName,
                                style: TextStyle(
                                  fontSize: size.width / 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${memberList.length} members",
                        style: TextStyle(
                          fontSize: size.width / 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    Flexible(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: memberList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => showRemoveDialog(index),
                            leading: Icon(
                              Icons.account_circle,
                            ),
                            title: Text(
                              memberList[index]['name'],
                              style: TextStyle(
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text("${memberList[index]['email']}"),
                          trailing: Text(memberList[index]['isadmin'] ?? false ? "Admin" : ""),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddMembersInGroup(
                            groupId: widget.groupId,
                            groupName: widget.groupName,
                            memberList: memberList,
                          ),
                        ),
                      ),
                      leading: Icon(
                        Icons.add,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Add members",
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
