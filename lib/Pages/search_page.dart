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
                      leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              searchedUser.profilepic!,
                              scale: 10)),
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
