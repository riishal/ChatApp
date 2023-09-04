import 'package:chat_app/Pages/Complited_profile.dart';
import 'package:chat_app/Pages/LoginPage.dart';
import 'package:chat_app/Pages/SignUp_page.dart';
import 'package:chat_app/Pages/homepage.dart';
import 'package:chat_app/models/firebase_helper.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    //logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelId(currentUser.uid);
    if (thisUserModel != null) {
      runApp(MyAppLoggedIn(
        firebaseUser: currentUser,
        userModel: thisUserModel,
      ));
    } else {
      runApp(MyApp());
    }
  } else {
    //not logged In
    runApp(MyApp());
  }
}

//not logged In
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//Already loggedIn
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
