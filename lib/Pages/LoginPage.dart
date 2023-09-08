import 'package:chat_app/Pages/Completed_profile.dart';
import 'package:chat_app/Pages/SignUp_page.dart';
import 'package:chat_app/Pages/homepage.dart';
import 'package:chat_app/models/ui_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../models/google_signUp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isHidden = true;
  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplited Data", "Please fill all the fields");
      print('please fill All fields!');
    } else {
      //login
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? userCredential;
    UIHelper.showLoadingDialog(context, "Logging In..");
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      //Close the Loading Dialog

      Navigator.pop(context);
      //Show Alert Dialog
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
      print(ex.message.toString());
    }
    if (userCredential != null) {
      String uid = userCredential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      //go to Homepage
      print('Login successful');
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
                userModel: userModel, firebaseUser: userCredential!.user!),
          ));
    }
  }

  void signUpGoogle() async {
    UserCredential? userCredential;
    // UIHelper.showLoadingDialog(context, "GoogleSign in...");

    try {
      userCredential = await Google_Signin().signInWithGoogle();
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
      print(ex.code.toString());
    }
    if (userCredential != null) {
      String uid = userCredential.user!.uid;
      UserModel newUser = UserModel(
          uid: uid,
          email: userCredential.user!.email,
          fullName: userCredential.user!.displayName,
          profilepic: userCredential.user!.photoURL);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then(
        (value) {
          print('New user Created');
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                      userModel: newUser, firebaseUser: userCredential!.user!)
                  // CompliteProfile(
                  //     userModel: newUser, firebaseUser: userCredential!.user!),
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
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
              const SizedBox(
                height: 19,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email Address"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: passwordController,
                obscureText: isHidden,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: InkWell(
                      onTap: togglePasswordView,
                      child: Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                child: const Text('Log In'),
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(
                height: 20,
              ),
              Text('OR'),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                    onPressed: (() {
                      signUpGoogle();
                    }),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(246, 234, 236, 240)),
                    child: Row(children: <Widget>[
                      Image.network(
                        'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                        height: 30,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Expanded(
                        child: Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ])),
              ),
            ],
          )),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ));
            },
          )
        ]),
      ),
    );
  }

  void togglePasswordView() {
    setState(() {
      isHidden = !isHidden;
    });
  }
}
