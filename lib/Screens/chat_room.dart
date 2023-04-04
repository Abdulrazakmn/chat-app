

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ChatRoom extends StatelessWidget {
  ChatRoom({super.key, required this.chatRoomId, required this.userMap});
 final TextEditingController _messages = TextEditingController();
  Map<String, dynamic>? userMap;
 final String chatRoomId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void onSendMessage() async {
    if (_messages.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _messages.text,
        "time": FieldValue.serverTimestamp()
      };
     // _messages.clear();
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
      _messages.clear();
    } else {
      print("enter some text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("users").doc(userMap!['uid']).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Container(
              child: Row(
                children: [Text(userMap!['name']),SizedBox(width: 10,), Text(snapshot.data!['status'])],
              ),
            );
          }
          else{
            return Container();
          }
        },
      )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatroom')
                      .doc(chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: ((BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: ((context, index) {
                            // return Text(snapshot.data?.docs[index]['message']);
                            Map<String, dynamic>? map =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return messages(size, map,context);
                          }));
                    } else {
                      return Container();
                    }
                  })),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(children: [
                  Container(
                    height: size.height / 17,
                    width: size.width / 1.3,
                    child: TextField(
                      showCursor: false,
                      controller: _messages,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        onSendMessage();
                      },
                      icon: Icon(Icons.send))
                ]),
              ),
            ),
          ],
        ),
      ),
      // body: Container(),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map,BuildContext context){
    Timestamp timestamp = map['time'];
    String time = DateFormat('hh:mm a').format(timestamp.toDate());
    print(time); // Prints the formatted time
    return Container(
      width: size.width,
      alignment: map['sendby'] == _auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.blue),
        child: Column(
          children: [
            Text(
              map['message'],
              style: TextStyle(color: Colors.white),
            ),
            Text(
              time.toString(),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            )
          ],
        ),
      ),
    );
  }
}
