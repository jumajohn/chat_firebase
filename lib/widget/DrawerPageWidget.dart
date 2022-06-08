import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../pages/UsersPage.dart';

import 'package:provider/provider.dart';
import '../provider/DataProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerPageWidget extends StatefulWidget {
  @override
  State<DrawerPageWidget> createState() => _DrawerPageWidgetState();
}

class _DrawerPageWidgetState extends State<DrawerPageWidget> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    final pres = await SharedPreferences.getInstance();
    pres.clear();

    Provider.of<DataProvider>(context, listen: false).logout();
  

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: Text("Hello Friend!"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Users"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(UsersPage.routeName);
              },
            ),
            const Divider(
              color: Colors.grey,
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
              onTap: null,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }
}
