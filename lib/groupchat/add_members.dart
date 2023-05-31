import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/Screens/home_page.dart';
import 'package:flutter/material.dart';

class AddMembersInGroup extends StatefulWidget {
  final String groupName, groupId;
  final List memberList;
  const AddMembersInGroup(
      {Key? key,
      required this.groupName,
      required this.groupId,
      required this.memberList})
      : super(key: key);

  @override
  _AddMembersInGroupState createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  Map<String, dynamic>? userMap;
  bool isloading = false;
  List memberList = [];
    final TextEditingController _search = TextEditingController();
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth=FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    memberList = widget.memberList;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
  
    
   void onSearch() async {
  setState(() {
    isloading = true;
  });

  try {
    final querySnapshot = await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        userMap = querySnapshot.docs[0].data();
        isloading = false;
      });
      print('User map: $userMap');
    } else {
      // Handle the case when no matching document is found
      setState(() {
        isloading = false;
      });
      print('No matching document found');
    }
  } catch (e) {
    // Handle the error
    setState(() {
      isloading = false;
    });
    print('Error searching for user: $e');
  }
}



    void onAddmembers() async {
      memberList.add({
        "name": userMap!['name'],
        "email": userMap!['email'],
        "uid": userMap!['uid'],
        "isAdmin": false,
      });
      await _firestore.collection('groups').doc(widget.groupId).update({
        "members":memberList,
      });
      await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('groups').doc(widget.groupId).set({
        "name":widget.groupName,
        "id":widget.groupId
      });
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_)=>HomePage()
      ), (route) => false,);

    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                child: TextField(controller: _search,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isloading
                ? Container(
                    height: size.height / 20,
                    width: size.width / 12,
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: () {
                      onSearch();
                    },
                    child: Text("Search")),
            userMap != null
                ? ListTile(
                    onTap: () => onAddmembers(),
                    leading: Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle: Text(userMap!['email']),
                    trailing: Icon(Icons.add),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
