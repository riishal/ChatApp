import 'package:chat_app/Pages/LoginPage.dart';
import 'package:chat_app/Pages/chatroom_page.dart';
import 'package:chat_app/Pages/search_page.dart';
import 'package:chat_app/models/chat_room.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat App',
        ),
        actions: [
          IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Log Out?"),
                    content: Text("Are you sure want to log out?"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ));
                          },
                          child: Text(
                            "Log out",
                            style: TextStyle(color: Colors.red),
                          )),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout))
        ],
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("users", arrayContains: widget.userModel.uid)
              .orderBy("createdone")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshot.docs[index].data()
                            as Map<String, dynamic>);
                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;
                    List<String> participantKey = participants.keys.toList();
                    participantKey.remove(widget.userModel.uid);
                    return FutureBuilder(
                      future: FirebaseHelper.getUserModelId(participantKey[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;
                            return ListTile(
                              trailing: Icon(Icons.circle,
                                  color: chatRoomModel.lastMessage !=
                                          widget.userModel.uid
                                      ? Colors.green
                                      : Colors.amber),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatroomPage(
                                          targetUser: targetUser,
                                          chatroom: chatRoomModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser),
                                    ));
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[500],
                                backgroundImage: NetworkImage(
                                    targetUser.profilepic.toString()),
                              ),
                              title: Text(
                                targetUser.fullName.toString(),
                              ),
                              subtitle: chatRoomModel.lastMessage.toString() !=
                                      ""
                                  ? Text(chatRoomModel.lastMessage.toString())
                                  : Text(
                                      "Say hi to your new friend",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else {
                return Center(child: Text("No Chats"));
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser),
              ));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
