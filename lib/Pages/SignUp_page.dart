import 'package:chat_app/Pages/Completed_profile.dart';
import 'package:chat_app/models/ui_helper.dart';
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
  bool isHidden = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cpasswordController.text.trim();
    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(
          context, "Incomplite Data", "Please fill all the fields");
    } else if (password != cPassword) {
      print('passwords do not match');
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The password you entered  do not match!");
    } else {
      signUp(email, password);
      print('signUp Successful');
    }
  }

  void signUp(String email, String password) async {
    UserCredential? userCredential;
    UIHelper.showLoadingDialog(context, "Creating new account...");
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UIHelper.showAlertDialog(
          context, "An error occured", ex.message.toString());
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
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
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
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: cpasswordController,
                obscureText: isHidden,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  suffixIcon: InkWell(
                      onTap: togglePasswordView,
                      child: Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      )),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                child: Text('Sign Up '),
                onPressed: () {
                  checkValue();
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

  void togglePasswordView() {
    setState(() {
      isHidden = !isHidden;
    });
  }
}
