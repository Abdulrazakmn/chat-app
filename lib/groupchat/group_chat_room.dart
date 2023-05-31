import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_project/groupchat/group_info.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class GroupChatRoom extends StatelessWidget {
  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);
  String currentUser = "user1";
  final String groupChatId, groupName;

  TextEditingController _message = TextEditingController();
  // List<Map<String, dynamic>> dummychatList = [
  //   {"message": "user1 created this group", "type": "notify"},
  //   {"message": "hello this is user 1", "sendby": "User1", "type": "text"},
  //   {"message": "hello this is user 2", "sendby": "User2", "type": "text"},
  //   {"message": "hello this is user 3", "sendby": "User3", "type": "text"},
  //   {"message": "hello this is user 4", "sendby": "User4", "type": "text"},
  //   {"message":"user1 added user 8","type":"notify"}
  // ];
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp()
      };
      _message.clear();
      await _firestore
          .collection('groups')
          .doc(groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => GroupInfo(
                          groupName: groupName,
                          groupId: groupChatId,
                        )));
              },
              icon: Icon(Icons.more_vert))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: size.height / 1.27,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(groupChatId)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          return messageTile(size, chatMap);
                        },
                      );
                    } else {
                      return Container();
                    }
                  }),
                )),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.3,
                      child: TextField(
                        controller: _message,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                return;
                              },
                              icon: Icon(Icons.photo),
                            ),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () => onSendMessage()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
     DateTime? timestamp = (chatMap['time'] as Timestamp?)?.toDate();

      // Check if timestamp is not null
      if (timestamp != null) {
        // Format the timestamp into "hh:mm a" pattern
        String formattedTime = DateFormat('hh:mm a').format(timestamp);
        // Fixed condition to check 'type' instead of 'sendby'
        return Container(
          alignment: chatMap['sendBy'] == _auth.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          width: size.width,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatMap['sendBy'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  chatMap['message'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 7, 240, 81),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  formattedTime, // Display formatted time
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          alignment: chatMap['sendBy'] == currentUser
              ? Alignment.centerRight
              : Alignment.centerLeft,
          width: size.width,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(chatMap['message']),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          alignment: Alignment.center,
          width: size.width,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black26,
            ),
            child: Column(
              children: [
                Text(
                  chatMap['sendBy'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height / 50),
                Text(
                  chatMap['message'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}
