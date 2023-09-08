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
import 'package:intl/intl.dart';

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
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomId)
          .set(widget.chatroom.toMap());
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
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatroom.chatroomId)
                  .collection("messages")
                  .orderBy("createdone", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                    return ListView.separated(
                      separatorBuilder: (context, index) {
                        MessageModel currentMessage = MessageModel.fromMap(
                            dataSnapshot.docs[index].data()
                                as Map<String, dynamic>);

                        return SizedBox(
                          height: 10,
                          // child: widget.chatroom.lastMessage != null
                          //     ? currentMessage.seen != null
                          //         ? Text('seen')
                          //         : Text('Not seen')
                          //     : SizedBox()
                        );
                      },
                      reverse: true,
                      itemCount: dataSnapshot.docs.length,
                      itemBuilder: (context, index) {
                        MessageModel currentMessage = MessageModel.fromMap(
                            dataSnapshot.docs[index].data()
                                as Map<String, dynamic>);
                        String currentTime = DateFormat('h:mm a')
                            .format(currentMessage.createdone!);
                        return Row(
                          mainAxisAlignment:
                              currentMessage.sender == widget.userModel.uid
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            currentMessage.sender == widget.userModel.uid
                                ? SizedBox(
                                    width: 60,
                                  )
                                : SizedBox(
                                    width: 0,
                                  ),
                            Flexible(
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: currentMessage.sender ==
                                              widget.userModel.uid
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey[400]),
                                  child: Column(
                                    crossAxisAlignment: currentMessage.sender ==
                                            widget.userModel.uid
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentMessage.text.toString(),
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: currentMessage.sender ==
                                                    widget.userModel.uid
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        currentTime,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: currentMessage.sender ==
                                                    widget.userModel.uid
                                                ? Colors.white
                                                : Colors.black),
                                      )
                                    ],
                                  )),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            "An error occured ! please check your internet connection."));
                  } else {
                    return Center(child: Text("Say hi to your new firend"));
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          )),
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
