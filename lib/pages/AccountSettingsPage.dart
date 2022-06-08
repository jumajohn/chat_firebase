import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/UserImageWidget.dart';
import '../widget/UserInfoTile.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);
  static const routeName = "/accountsettingspage";
  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        padding: EdgeInsets.only(
            top: (screenHeight * 5) / 100, bottom: (screenHeight * 5) / 100),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: [Colors.lightBlueAccent, Colors.purpleAccent]),
        ),
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              padding:
                  const EdgeInsets.only(top: 70, left: 5, bottom: 5, right: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  )),
              child: Container(
                  margin: const EdgeInsets.all(20), child: UserInfoTile()),
            ),
            Positioned(
                top: 0,
                left: (screenWidth / 2) - 20,
                child: const UserImageWidget())
          ],
        ),
      ),
    );
  }
}
