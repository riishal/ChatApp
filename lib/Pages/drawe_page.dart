import 'package:chat_app/Pages/LoginPage.dart';
import 'package:chat_app/Pages/user_profilepic.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DrawerPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const DrawerPage({key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   'Your Profile',
            //   style: TextStyle(
            //       fontStyle: FontStyle.italic,
            //       color: Colors.white,
            //       fontSize: 30,
            //       fontWeight: FontWeight.w400),
            // ),
            // SizedBox(
            //   height: 15,
            // ),
            InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePic(
                        userModel: widget.userModel,
                        firebaseUser: widget.firebaseUser),
                  )),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[500],
                backgroundImage: NetworkImage(
                  widget.userModel.profilepic!,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.userModel.fullName!.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              widget.userModel.email!.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 25,
            ),
            Container(
              height: 45,
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(27)),
              child: TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Log out?"),
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
                                await GoogleSignIn().signOut();
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
                  icon: Icon(
                    Icons.logout_sharp,
                    color: Colors.red,
                  ),
                  label: Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  )),
            )
          ],
        ),
      ],
    );
  }
}
