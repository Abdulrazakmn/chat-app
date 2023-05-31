// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

 Future getImage() async {
  ImagePicker _picker = ImagePicker();

  try {
    XFile? xFile = await _picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      imageFile = File(xFile.path);
      uploadImage();
    }
  } catch (e) {
    print("Error picking image: $e");
  }
}

  Future<void> uploadImage() async {
     if (imageFile == null) {
    return;
  }

  String fileName = Uuid().v1();
  int status = 1;

  await _firestore
      .collection('chatroom')
      .doc(chatRoomId)
      .collection('chats')
      .doc(fileName)
      .set({
    "sendby": _auth.currentUser!.displayName,
    "message": "",
    "type": "img",
    "time": FieldValue.serverTimestamp(),
  });

  var ref = FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

  try {
    UploadTask uploadTask = ref.putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;

    String imageUrl = await snapshot.ref.getDownloadURL();

    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .update({"message": imageUrl});

    print(imageUrl);

  } catch (e) {
    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .delete();

    status = 0;
  }
}

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream:
              _firestore.collection("users").doc(userMap['uid']).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    Text(userMap['name']),
                    Text(
                      snapshot.data!['status'],
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
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
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        return messages(size, map, context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
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
                              onPressed: () => getImage(),
                              icon: Icon(Icons.photo),
                            ),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
     Timestamp? timestampValue = map['time'] as Timestamp?;
  DateTime? timestamp;
  // In this updated code, I've introduced the timestampValue and timestamp variables, which handle the type casting and null check for the timestamp value. If timestampValue is not null, it is cast to a DateTime and assigned to timestamp. Then, the formattedTime variable is only populated if timestamp is not null, and the condition if (formattedTime.isNotEmpty) is used to render the Text widget for displaying the formatted time only when it is available.

// Make sure to adjust the rest of your code accordingly, taking into account the possible null value of timestamp and the presence of formattedTime before rendering the corresponding UI elements.

  if (timestampValue != null) {
    timestamp = timestampValue.toDate();
  }

  String formattedTime = '';
  if (timestamp != null) {
    formattedTime = DateFormat('hh:mm a').format(timestamp);
  }
    return map['type'] == "text"
        ? Container(
            width: size.width,
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Text(
                  map['sendby'],
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
                  map['message'],
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
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? Image.network(
                        map['message'],
                        fit: BoxFit.cover,
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}

//

// class ChatRoom extends StatelessWidget {
//   ChatRoom({super.key, required this.chatRoomId, required this.userMap});
//   final TextEditingController _messages = TextEditingController();
//   Map<String, dynamic>? userMap;
//   final String chatRoomId;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   File? imageFile;
//   Future getImage() async {
//     ImagePicker _picker = ImagePicker();
//     await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
//       if (xFile != null) {
//         imageFile = File(xFile.path);
//         uploadImage();
//       }
//     });
//   }
//  Future uploadImage() async {
//     String fileName = Uuid().v1();// A Version 1 UUID is a universally 
//     // unique identifier that is generated using a timestamp and the 
//     // MAC address of the computer on which it was generated.
//     int status = 1;

//     await _firestore
//         .collection('chatroom')
//         .doc(chatRoomId)
//         .collection('chats')
//         .doc(fileName)
//         .set({
//       "sendby": _auth.currentUser!.displayName,
//       "message": "",
//       "type": "img",
//       "time": FieldValue.serverTimestamp(),
//     });

//     var ref =
//         FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

//     var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .delete();

//       status = 0;
//     });

//     if (status == 1) {
//       String imageUrl = await uploadTask.ref.getDownloadURL();

//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .doc(fileName)
//           .update({"message": imageUrl});

//       print(imageUrl);
//     }
//   }

//   void onSendMessage() async {
//     if (_messages.text.isNotEmpty) {
//       Map<String, dynamic> messages = {
//         "sendby": _auth.currentUser!.displayName,
//         "message": _messages.text,
//         "type": "text",
//         "time": FieldValue.serverTimestamp()
//       };
//       // _messages.clear();
//       await _firestore
//           .collection('chatroom')
//           .doc(chatRoomId)
//           .collection('chats')
//           .add(messages);
//       _messages.clear();
//     } else {
//       print("enter some text");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//           title: StreamBuilder<DocumentSnapshot>(
//         stream: _firestore.collection("users").doc(userMap!['uid']).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.data != null) {
//             return Container(
//               child: Row(
//                 children: [
//                   Text(userMap!['name']),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   Text(snapshot.data!['status'])
//                 ],
//               ),
//             );
//           } else {
//             return Container();
//           }
//         },
//       )),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               height: size.height / 1.25,
//               width: size.width,
//               child: StreamBuilder<QuerySnapshot>(
//                   stream: _firestore
//                       .collection('chatroom')
//                       .doc(chatRoomId)
//                       .collection('chats')
//                       .orderBy("time", descending: false)
//                       .snapshots(),
//                   builder: ((BuildContext context,
//                       AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (snapshot.data != null) {
//                       return ListView.builder(
//                           itemCount: snapshot.data!.docs.length,
//                           itemBuilder: ((context, index) {
//                             // return Text(snapshot.data?.docs[index]['message']);
//                             Map<String, dynamic>? map =
//                                 snapshot.data!.docs[index].data()
//                                     as Map<String, dynamic>;
//                             return messages(size, map, context);
//                           }));
//                     } else {
//                       return Container();
//                     }
//                   })),
//             ),
//             Container(
//               height: size.height / 10,
//               width: size.width,
//               alignment: Alignment.center,
//               child: Container(
//                 height: size.height / 12,
//                 width: size.width / 1.1,
//                 child: Row(children: [
//                   Container(
//                     height: size.height / 17,
//                     width: size.width / 1.3,
//                     child: TextField(
//                       showCursor: false,
//                       controller: _messages,
//                       decoration: InputDecoration(
//                           suffixIcon: IconButton(
//                               onPressed: () {getImage();},
//                               icon: Icon(Icons.photo_album_rounded)),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8))),
//                     ),
//                   ),
//                   IconButton(
//                       onPressed: () {
//                         onSendMessage();
//                       },
//                       icon: Icon(Icons.send))
//                 ]),
//               ),
//             ),
//           ],
//         ),
//       ),
//       // body: Container(),
//     );
//   }

//   // Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
//   // //  Timestamp timestamp = map["time"];
//   // Timestamp timestamp = map.containsKey("time") ? map["time"] : Timestamp.now();
//   //   String time = DateFormat('hh:mm a').format(timestamp.toDate());
//   //    // Prints the formatted time
//   //   return Container(
//   //     width: size.width,
//   //     alignment: map['sendby'] == _auth.currentUser!.displayName
//   //         ? Alignment.centerRight
//   //         : Alignment.centerLeft,
//   //     child: Container(
//   //       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//   //       margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//   //       decoration: BoxDecoration(
//   //           borderRadius: BorderRadius.circular(15), color: Colors.blue),
//   //       child: Column(
//   //         children: [
//   //           Text(
//   //             map['message'],
//   //             style: TextStyle(color: Colors.white),
//   //           ),
//   //           Text(
//   //             time.toString(),
//   //             style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//   //           )
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//    Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
//     return map['type'] == "text"
//         ? Container(
//             width: size.width,
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//               margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.blue,
//               ),
//               child: Text(
//                 map['message'],
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           )
//         : Container(
//             height: size.height / 2.5,
//             width: size.width,
//             padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
//             alignment: map['sendby'] == _auth.currentUser!.displayName
//                 ? Alignment.centerRight
//                 : Alignment.centerLeft,
//             child: InkWell(
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ShowImage(
//                     imageUrl: map['message'],
//                   ),
//                 ),
//               ),
//               child: Container(
//                 height: size.height / 2.5,
//                 width: size.width / 2,
//                 decoration: BoxDecoration(border: Border.all()),
//                 alignment: map['message'] != "" ? null : Alignment.center,
//                 child: map['message'] != ""
//                     ? Image.network(
//                         map['message'],
//                         fit: BoxFit.cover,
//                       )
//                     : CircularProgressIndicator(),
//               ),
//             ),
//           );
//   }
// }

// class ShowImage extends StatelessWidget {
//   final String imageUrl;

//   const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: Container(
//         height: size.height,
//         width: size.width,
//         color: Colors.black,
//         child: Image.network(imageUrl),
//       ),
//     );
//   }
// }
