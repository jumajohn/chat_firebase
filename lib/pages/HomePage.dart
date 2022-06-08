import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widget/SearchTextFieldWidget.dart';
import 'AccountSettingsPage.dart';
import '../widget/DrawerPageWidget.dart';
import '../widget/UserListTileWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import './ImageView.dart';
import './ChatPage.dart';
import 'package:provider/provider.dart';
import '../provider/DataProvider.dart';
import '../models/schema.dart';
import 'UsersPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = "/homepage";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearch = false;

  void closeTextbox() {
    setState(() {
      isSearch = false;
    });
  }

  void openTextbox() {
    setState(() {
      isSearch = true;
    });
  }

  @override
  void initState() {
    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((Event) {
      print(Event.data);
    });

   
    

    // TODO: implement initState
    super.initState();
  }

  Future<void> gg(RemoteMessage mm) async {
    print(mm);
  }

  @override
  Widget build(BuildContext context) {
    final myid = Provider.of<DataProvider>(context, listen: false).items[0].id;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isSearch ? false : true,
        title: isSearch
            ? SearchTextFieldWidget(closeTextbox: closeTextbox)
            : const Text("MyChats"),
        backgroundColor: Colors.transparent,
        actions: [
          if (!isSearch)
            IconButton(
              onPressed: openTextbox,
              icon: const Icon(Icons.search),
            ),
          if (!isSearch)
            IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(AccountSettingsPage.routeName),
                icon: const Icon(Icons.settings))
        ],
      ),
      drawer: DrawerPageWidget(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("conversations")
            .where("members", arrayContains: myid)
            .orderBy("dateModified", descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Error Occurred"),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data!.docs.length == 0) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Empty Charts"),
                  FlatButton(
                      color: Colors.lightBlueAccent,
                      textColor: Colors.white,
                      onPressed: () =>
                          Navigator.of(context).pushNamed(UsersPage.routeName),
                      child: Text("Start new Chart"))
                ],
              ));
            }

            final List<QueryDocumentSnapshot> item = snapshot.data!.docs;

            return ListView.builder(
                itemCount: item.length,
                itemBuilder: (context, index) {
                  final itemData = item[index];

                  Provider.of<DataProvider>(context, listen: false)
                      .setConversations({
                    "id": itemData['conversationId'],
                    "name": itemData['name']
                  });

                  return Tile(
                    member: itemData['members'],
                    lastmes: itemData['lastmessage'],
                    groupName: itemData['name'],
                    conversationId: itemData['conversationId'],
                  );
                });

            ;
          }
        },
      ),
    );
  }
}

class Tile extends StatefulWidget {
  const Tile({
    Key? key,
    required this.member,
    required this.lastmes,
    required this.conversationId,
    required this.groupName,
  }) : super(key: key);
  final List member;
  final String lastmes;
  final String conversationId;
  final String groupName;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  String myid = "";
  String myusername = "";
  String myaboutMe = "";
  String myId = "";
  String chatId = "";
  String myimageUrl = "";
  String id = "";
  String username = "";
  String aboutMe = "";

  String imageUrl = "";

  bool isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) {
      readData();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void readData() async {
    final List<CurrentUser> items = Provider.of<DataProvider>(context).items;
    final data = items[0];
    myusername = data.username;
    myaboutMe = data.aboutMe;
    myimageUrl = data.imageUrl;
    myId = data.id;

    List members = widget.member as List;

    members.remove(myId);

    final Future<QuerySnapshot> userdata = FirebaseFirestore.instance
        .collection("users")
        .where("id", isEqualTo: members[0])
        .get();

    List datalist = [];

    userdata.then((snap) {
      datalist = snap.docs;

      id = datalist[0]['id'];
      imageUrl = datalist[0]['imageUrl'];
      username = datalist[0]['username'];
      aboutMe = datalist[0]['aboutMe'];

      setState(() {});
    });
    setState(() {});
  }

  Widget imageWidget(BuildContext context, String imageUrl) {
    return ClipOval(
      child: InkWell(
        onTap: () => Navigator.of(context)
            .pushNamed(ImageView.routeName, arguments: {"url": imageUrl}),
        child: Hero(
          tag: imageUrl,
          child: CachedNetworkImage(
            width: 55,
            height: 60,
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.info),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () =>
          Navigator.of(context).pushNamed(ChatPage.routeName, arguments: {
        "chatId": widget.conversationId,
        "name": username,
        "id": id,
        "imageurl": imageUrl,
        "myname": myusername,
        "myid": myId,
        "myimageurl": myimageUrl
      }),
      leading: imageWidget(context, imageUrl),
      title:
          widget.member.length >= 3 ? Text(widget.groupName) : Text(username),
      subtitle: Text(
        widget.lastmes,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
