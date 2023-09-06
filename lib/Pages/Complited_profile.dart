import 'dart:io';

import 'package:chat_app/Pages/homepage.dart';
import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';

class CompliteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompliteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompliteProfile> createState() => _CompliteProfileState();
}

class _CompliteProfileState extends State<CompliteProfile> {
  File? selectedImage;
  TextEditingController fullNameController = TextEditingController();
  Future pickImageFromGallery() async {
    final returnrdImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnrdImage == null) return;
    setState(() {
      selectedImage = File(returnrdImage.path);
    });
  }

  Future selectImageFromCamera() async {
    final returnrdImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnrdImage == null) return;
    setState(() {
      selectedImage = File(returnrdImage.path);
    });
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Profile Picture'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            onTap: () {
              pickImageFromGallery();
              Navigator.pop(context);
            },
            leading: Icon(Icons.photo_album),
            title: Text('Select from gallery'),
          ),
          ListTile(
            onTap: () {
              selectImageFromCamera();
              Navigator.pop(context);
            },
            leading: Icon(Icons.camera),
            title: Text('Take a Photo'),
          )
        ]),
      ),
    );
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    if (fullname == "" || selectedImage == null) {
      UIHelper.showAlertDialog(context, "Incomplite Data",
          "Please fill all the fields and upload a profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading Image..");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(selectedImage!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullNameController.text.trim();
    widget.userModel.fullName = fullname;
    widget.userModel.profilepic = imageUrl;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print('Data Uploaded');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Complite Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: ListView(children: [
          SizedBox(
            height: 20,
          ),
          CupertinoButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              showPhotoOptions();
            },
            child: CircleAvatar(
                backgroundImage:
                    selectedImage != null ? FileImage(selectedImage!) : null,
                radius: 60,
                child: selectedImage == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                      )
                    : null),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: fullNameController,
            decoration: InputDecoration(labelText: "Full Name"),
          ),
          SizedBox(
            height: 20,
          ),
          CupertinoButton(
            color: Theme.of(context).colorScheme.secondary,
            child: const Text(
              'Submit',
              // style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              checkValues();
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => const SignUpPage(),
              //     ));
            },
          )
        ]),
      )),
    );
  }
}
