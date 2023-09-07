import 'package:chat_app/Pages/LoginPage.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            User? currentUser = FirebaseAuth.instance.currentUser;
            QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
            if (dataSnapshot.docs.length > 0) {
              Map<String, dynamic> userMap =
                  dataSnapshot.docs[0].data() as Map<String, dynamic>;
              UserModel currentUser = UserModel.fromMap(userMap);
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
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[500],
                        backgroundImage: NetworkImage(
                          currentUser.profilepic!,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        currentUser.fullName!.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        currentUser.email!.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(27)),
                        child: TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Log out?"),
                                  content:
                                      Text("Are you sure want to log out?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel")),
                                    TextButton(
                                        onPressed: () async {
                                          await FirebaseAuth.instance.signOut();
                                          Navigator.popUntil(context,
                                              (route) => route.isFirst);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginPage(),
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

              // ListTile(
              //   onTap: () {},
              //   trailing: Icon(
              //     Icons.keyboard_arrow_right,
              //     size: 30,
              //   ),
              //   leading: CircleAvatar(
              //       backgroundColor: Colors.grey[500],
              //       backgroundImage: NetworkImage(
              //         currentUser.profilepic!,
              //       )),
              //   title:
              // Text(
              //     currentUser.fullName!.toString(),
              //     style: TextStyle(color: Colors.black),
              //   ),
              //   subtitle: Text(currentUser.email!.toString()),
              // );
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
    );

    // StreamBuilder(
    //     stream: FirebaseFirestore.instance.collection("users").snapshots(),
    //     builder: (context, snapshot) {
    //       return Drawer(
    //         child: ListView(
    //           padding: EdgeInsets.zero,
    //           // ignore: prefer_const_literals_to_create_immutables
    //           children: [
    //             SizedBox(
    //               child:
    // DrawerHeader(
    //                 decoration: const BoxDecoration(
    //                   color: Colors.blue,
    //                 ),
    //                 child: UserAccountsDrawerHeader(
    //                   decoration: const BoxDecoration(color: Colors.blue),
    //                   accountName: Text(
    //                     "",
    //                     style: const TextStyle(fontSize: 18),
    //                   ),
    //                   accountEmail:
    //                       Text(FirebaseAuth.instance.currentUser!.email ?? ""),
    //                   currentAccountPictureSize: const Size.square(50),
    //                   currentAccountPicture: CircleAvatar(
    //                     backgroundColor: Colors.white,
    //                     backgroundImage: NetworkImage(""),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             ListTile(
    //               leading: const Icon(Icons.person),
    //               title: const Text("Profile"),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             ),
    //             ListTile(
    //               leading: const Icon(Icons.notifications_none_outlined),
    //               title: const Text("Notification"),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             ),
    //             ListTile(
    //               leading: const Icon(Icons.settings),
    //               title: const Text("Settings"),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             ),
    //             // ListTile(
    //             //   leading: const Icon(Icons.shopping_cart),
    //             //   title: const Text("Shopping List"),
    //             //   onTap: () {
    //             //     Navigator.push(context,
    //             //         MaterialPageRoute(builder: ((context) => const Cartpage())));
    //             //   },
    //             // ),
    //             ListTile(
    //               leading: const Icon(Icons.star),
    //               title: const Text("Rate the App"),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             ),
    //             ListTile(
    //               leading: const Icon(Icons.notes),
    //               title: const Text("Terms & Conditions"),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             ),
    //             ListTile(
    //               leading: const Icon(Icons.privacy_tip_outlined),
    //               title: const Text("Privacy Policy"),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             ),
    //             ListTile(
    //               leading: const Icon(Icons.info),
    //               title: const Text("About Us"),
    //               onTap: () {
    //                 Navigator.pop(context);
    //               },
    //             ),
    //             ListTile(
    //               leading: const Icon(
    //                 Icons.logout_sharp,
    //                 color: Colors.red,
    //               ),
    //               title: const Text(
    //                 "Logout",
    //                 style: TextStyle(color: Colors.red),
    //               ),
    //               onTap: () {
    //                 FirebaseAuth.instance.signOut();
    //                 // Google_Signin().signout();
    //               },
    //             ),
    //           ],
    //         ),
    //       );
    //     });
  }
}
