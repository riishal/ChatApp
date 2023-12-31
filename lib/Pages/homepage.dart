import 'package:chat_app/Pages/LoginPage.dart';
import 'package:chat_app/Pages/chatroom_page.dart';
import 'package:chat_app/Pages/drawe_page.dart';
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
      drawer: DrawerPage(
        firebaseUser: widget.firebaseUser,
        userModel: widget.userModel,
      ),
      appBar: AppBar(
        title: Text(
          'Chat App',
        ),
        actions: [
          Builder(builder: (context) {
            return InkWell(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.userModel.profilepic!),
              ),
            );
          }),
          SizedBox(
            width: 10,
          ),
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
                              trailing:
                                  chatRoomModel.fromId == widget.userModel.uid
                                      ? SizedBox.shrink()
                                      : chatRoomModel.seen
                                          ? SizedBox.shrink()
                                          : const Icon(
                                              Icons.error,
                                              color: Colors.green,
                                              size: 25,
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
