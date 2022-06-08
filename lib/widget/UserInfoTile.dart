// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../provider/DataProvider.dart';
import '../models/schema.dart';

class UserInfoTile extends StatefulWidget {
  const UserInfoTile({
    Key? key,
  }) : super(key: key);

  @override
  State<UserInfoTile> createState() => _UserInfoTileState();
}

class _UserInfoTileState extends State<UserInfoTile> {
  TextEditingController name = TextEditingController();
  TextEditingController about = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String username = "";
  String aboutMe = "";
  String id = "";
  bool isLoading = false;

  bool isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) {
      readData();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void readData() {
    final List<CurrentUser> items = Provider.of<DataProvider>(context).items;
    final data = items[0];
    username = data.username;
    aboutMe = data.aboutMe;
    id = data.id;

    name.text = username;
    about.text = aboutMe;
  }

  Future<void> updateInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      FirebaseFirestore.instance.collection("users").doc(id).update({
        "username": name.text,
        "aboutMe": about.text,
      }).then((value) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString("username", name.text);
        prefs.setString("aboutMe", about.text);
        setState(() {
          isLoading = false;
        });

        Provider.of<DataProvider>(context, listen: false).setDetails({
          "id": id,
          "username": name.text,
          "imageUrl": null,
          "aboutMe": about.text,
        });

        Scaffold.of(context).showSnackBar(
            const SnackBar(content: Text("info successfuly updated")));
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
        Scaffold.of(context)
            .showSnackBar(const SnackBar(content: Text("Error Occurred")));
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Scaffold.of(context)
          .showSnackBar(const SnackBar(content: Text("Error Occurred")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Name:",
                style: TextStyle(fontSize: 20),
              ),
              Container(
                child: TextFormField(
                  controller: name,
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "About:",
              style: TextStyle(fontSize: 20),
            ),
            Container(
              child: TextFormField(
                controller: about,
                onTap: () {
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(microseconds: 1),
                      curve: Curves.easeOut);
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(microseconds: 1),
                      curve: Curves.easeOut);
                },
              ),
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          child: isLoading
              ? const CircularProgressIndicator()
              : FlatButton(
                  onPressed: updateInfo,
                  color: Colors.lightBlueAccent,
                  child: const Text("Update"),
                ),
        ),
      ],
    );
  }
}
