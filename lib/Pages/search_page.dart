import 'dart:math';

import 'package:chat_app/Pages/chatroom_page.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      //fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      //create a new one

      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomId: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          },
          users: [widget.userModel.uid.toString(), targetUser.uid.toString()],
          createdone: DateTime.now());
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomId)
          .set(newChatroom.toMap());
      chatRoom = newChatroom;
      print("new  chatr0om Created!");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(labelText: "Email Address"),
          ),
          SizedBox(
            height: 20,
          ),
          CupertinoButton(
            color: Theme.of(context).colorScheme.secondary,
            child: Text('Search'),
            onPressed: () {
              setState(() {});
            },
          ),
          SizedBox(
            height: 20,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("email", isEqualTo: searchController.text)
                .where("email", isNotEqualTo: widget.userModel.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                  if (dataSnapshot.docs.length > 0) {
                    Map<String, dynamic> userMap =
                        dataSnapshot.docs[0].data() as Map<String, dynamic>;
                    UserModel searchedUser = UserModel.fromMap(userMap);
                    return ListTile(
                      onTap: () async {
                        ChatRoomModel? chatRoomModel =
                            await getChatroomModel(searchedUser);
                        if (chatRoomModel != null) {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatroomPage(
                                  firebaseUser: widget.firebaseUser,
                                  targetUser: searchedUser,
                                  userModel: widget.userModel,
                                  chatroom: chatRoomModel,
                                ),
                              ));
                        }
                      },
                      trailing: Icon(
                        Icons.keyboard_arrow_right,
                        size: 30,
                      ),
                      leading: CircleAvatar(
                          backgroundColor: Colors.grey[500],
                          backgroundImage: NetworkImage(
                            searchedUser.profilepic!,
                          )),
                      title: Text(
                        searchedUser.fullName!.toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(searchedUser.email!.toString()),
                    );
                  } else {
                    return Text('No Result Found!');
                  }
                } else if (snapshot.hasError) {
                  return Text('An error occured');
                } else {
                  return Text('No Result Found!');
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          )
        ]),
      )),
    );
  }
}
