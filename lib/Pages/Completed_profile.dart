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
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? cropedImage = await ImageCropper.platform.cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(
          ratioX: 1,
          ratioY: 1,
        ),
        compressQuality: 20);
    if (cropedImage != null) {
      setState(() {
        imageFile = File(cropedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Profile Picture'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            onTap: () {
              selectImage(ImageSource.gallery);
              // pickImageFromGallery();
              Navigator.pop(context);
            },
            leading: Icon(Icons.photo_album),
            title: Text('Select from gallery'),
          ),
          ListTile(
            onTap: () {
              selectImage(ImageSource.camera);
              // selectImageFromCamera();
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
    if (fullname == "" || imageFile == null) {
      UIHelper.showAlertDialog(context, "Incomplite Data",
          "Please fill all the fields and upload a profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Loading...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

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
        title: Text("Complete Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: ListView(children: [
          SizedBox(
            height: 20,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  backgroundImage:
                      imageFile != null ? FileImage(imageFile!) : null,
                  radius: 60,
                  child: imageFile == null
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        )
                      : null),
              Positioned(
                bottom: 0,
                right: 100,
                child: CircleAvatar(
                  child: IconButton(
                      onPressed: () {
                        showPhotoOptions();
                      },
                      icon: Icon(Icons.camera_alt)),
                ),
              )
            ],
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
