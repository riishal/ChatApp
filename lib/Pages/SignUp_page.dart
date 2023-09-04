import 'package:chat_app/Pages/Complited_profile.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cpasswordController.text.trim();
    if (email == "" || password == "" || cPassword == "") {
      print('please fill all the fields');
    } else if (password != cPassword) {
      print('passwords do not match');
    } else {
      signUp(email, password);
      print('signUp Successful');
    }
  }

  void signUp(String email, String password) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }
    if (userCredential != null) {
      String uid = userCredential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullName: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then(
        (value) {
          print('New user Created');
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompliteProfile(
                    userModel: newUser, firebaseUser: userCredential!.user!),
              ));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Text(
                'Chat App',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email Address"),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: cpasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                child: Text('Sign Up '),
                onPressed: () {
                  checkValue();
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => CompliteProfile(),
                  //     ));
                },
                color: Theme.of(context).colorScheme.secondary,
              )
            ],
          )),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Already have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
            child: Text(
              'Log In',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ]),
      ),
    );
  }
}
