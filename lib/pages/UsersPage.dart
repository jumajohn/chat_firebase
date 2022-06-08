import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'ImageView.dart';
import '../widget/UserListTileWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../provider/DataProvider.dart';
import '../models/schema.dart'; 


class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);
  static const routeName = "/userspage";
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String myId = "";
 bool isInit = true;

  @override
  void didChangeDependencies() {
    if (isInit) { readData();}
    isInit = false;
    super.didChangeDependencies();
  }


  void readData() {
 
final List<CurrentUser> items = Provider.of<DataProvider>(context).items;
    final data = items[0];
    myId = data.id;
  }

  Widget imageWidget(String imageUrl) {
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
            errorWidget: (context, url, error) => Image.asset(
              "assets/images/Capture5.PNG",
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("users"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
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
            final List<QueryDocumentSnapshot> item = snapshot.data!.docs;

            return ListView.builder(
              itemCount: item.length,
              itemBuilder: (context, index) {
                final itemData = item[index];
                if (itemData['id'] == myId) {
                  return Container();
                } else {
                  return UserListTilewidget(
                    id: itemData['id'],
                    imageUrl: itemData['imageUrl'],
                    username: itemData['username'],
                    aboutMe: itemData['aboutMe'],
                    Lastsms: "none",
                  );
                }
              },
            );

            ;
          }
        },
      ),
    );
  }
}
