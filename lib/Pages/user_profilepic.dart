import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart';

class UserProfilePic extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const UserProfilePic(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: PhotoView(imageProvider: NetworkImage(userModel.profilepic!)),
      ),
    );
  }
}
