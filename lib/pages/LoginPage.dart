// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:chat_firebase/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../provider/DataProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const routeName = "/loginpage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool isLogin = false;
  bool isLoading = false;
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> signingWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    print("jumaaa");
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final prefs = await SharedPreferences.getInstance();

      AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      User? user = (await firebaseAuth.signInWithCredential(credential)).user;

//check if user exist
      if (user != null) {
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("id", isEqualTo: user.uid)
            .get();

        final List<DocumentSnapshot> documentSnapshot = querySnapshot.docs;

//save to firestore if new user
        if (documentSnapshot.length == 0) {
          FirebaseFirestore.instance.collection("users").doc(user.uid).set({
            "id": user.uid,
            "username": user.displayName,
            "imageUrl": user.photoURL,
            "aboutMe": "yah lets chat",
            "conversations": null,
          });

          //save data to local

          await prefs.setString("id", user.uid);
          await prefs.setString("username", user.displayName!);
          await prefs.setString("imageUrl", user.photoURL!);
          await prefs.setString("aboutMe", "yah lets chat");

          Provider.of<DataProvider>(context, listen: false).setDetails({
            "id": user.uid,
            "username": user.displayName,
            "imageUrl": user.photoURL,
            "aboutMe": "yah lets chat",
          });
        } else {
          await prefs.setString("id", documentSnapshot[0]["id"]);
          await prefs.setString("username", documentSnapshot[0]["username"]);
          await prefs.setString("imageUrl", documentSnapshot[0]["imageUrl"]);
          await prefs.setString("aboutMe", documentSnapshot[0]["aboutMe"]);

          Provider.of<DataProvider>(context, listen: false).setDetails({
            "id": documentSnapshot[0]["id"],
            "username": documentSnapshot[0]["username"],
            "imageUrl": documentSnapshot[0]["imageUrl"],
            "aboutMe": documentSnapshot[0]["aboutMe"],
          });
        }

        setState(() {
          isLoading = false;
        });

        // ignore: use_build_context_synchronously
        Navigator.of(context)
            .pushNamed(HomePage.routeName, arguments: {"id": user.uid});
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isSigning();
  }

  void isSigning() async {
    isLogin = await googleSignIn.isSignedIn();

    final preps = await SharedPreferences.getInstance();

    Provider.of<DataProvider>(context, listen: false).setDetails({
      "id": preps.getString("id"),
      "username": preps.getString("username"),
      "imageUrl": preps.getString("imageUrl"),
      "aboutMe": preps.getString("aboutMe"),
    });

    if (isLogin) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(HomePage.routeName,
          arguments: {"id": preps.getString("id")});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
        ),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(
              Buttons.Google,
              onPressed: signingWithGoogle,
            ),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
