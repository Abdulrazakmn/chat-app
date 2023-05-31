import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/groupchat/create_group.dart';
import 'package:flutter/material.dart';

class AddMembersInGroupCreation extends StatefulWidget {
  const AddMembersInGroupCreation(
      {Key? key,
     })
      : super(key: key);

  @override
  State<AddMembersInGroupCreation> createState() =>
      _AddMembersInGroupCreationState();
}

class _AddMembersInGroupCreationState extends State<AddMembersInGroupCreation> {
  List<Map<String, dynamic>> memberList = [];
  bool isloading = false;
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userMap;
  //for storing search result
  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
  DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
      .collection('user')
      .doc(_auth.currentUser!.uid)
      .get();

  if (snapshot.exists) {
    Map<String, dynamic>? data = snapshot.data();

    if (data != null &&
        data.containsKey('name') &&
        data.containsKey('email') &&
        data.containsKey('uid')) {
      setState(() {
        memberList.add({
          "name": data['name'],
          "email": data['email'],
          "uid": data['uid'],
          "isAdmin": true,
        });
      });
    } else {
      print('One or more fields missing in the document');
    }
  } else {
    print('Document does not exist');
  }
}


 void onSearch() async {
  setState(() {
    print("value of text ${_search.text}");
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
      print(userMap);
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

  void onResultTap() {
  if (userMap != null) {
    bool isAlreadyExist = false;
    for (int i = 0; i < memberList.length; i++) {
      if (memberList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
        break;
      }
    }
    if (!isAlreadyExist) {
      setState(() {
        memberList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });
        userMap = null;
      });
    }
  }
}


  void onRemoveMember(int index) {
    if (memberList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        memberList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: ListView.builder(
                    itemCount: memberList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: ((context, index) {
                      return ListTile(
                        onTap: () {
                          onRemoveMember(index);
                        },
                        leading: Icon(Icons.account_circle),
                        title: Text(memberList[index]['name']),
                        subtitle: Text(memberList[index]['email']),
                        trailing: Icon(Icons.close),
                      );
                    }))),
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
                    onTap: () => onResultTap(),
                    leading: Icon(Icons.account_box),
                    title: Text(userMap!['name']),
                    subtitle:Text(userMap!['email']),
                    trailing: Icon(Icons.add),
                  )
                : SizedBox()
          ],
        ),
      ),
      floatingActionButton: memberList.length >= 2
          ? FloatingActionButton(
              child: Icon(Icons.forward),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return CreateGroup(
                    memberList: memberList,
                  );
                })));
              })
          : SizedBox(),
    );
  }
}
