import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ChatroomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatroomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage> {
  TextEditingController messageController = TextEditingController();
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if (msg != "") {
      //send message
      MessageModel newMessage = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          createdone: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());
      print("message send!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage:
                NetworkImage(widget.targetUser.profilepic.toString()),
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.targetUser.fullName.toString())
        ]),
      ),
      body: SafeArea(
          child: Container(
        child: Column(children: [
          //this is where the chats will go
          Expanded(child: Container()),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [
              Flexible(
                child: TextFormField(
                  maxLines: null,
                  controller: messageController,
                  decoration: InputDecoration(
                      hintText: "Enter Message", border: InputBorder.none),
                ),
              ),
              IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.secondary,
                  ))
            ]),
          )
        ]),
      )),
    );
  }
}
