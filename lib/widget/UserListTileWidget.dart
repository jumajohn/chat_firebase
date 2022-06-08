import 'package:flutter/material.dart';
import '../pages/ImageView.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/ChatPage.dart';
import 'package:provider/provider.dart';
import '../provider/DataProvider.dart';
import '../models/schema.dart';

class UserListTilewidget extends StatefulWidget {
  const UserListTilewidget(
      {Key? key,
      required this.id,
      required this.username,
      required this.imageUrl,
      required this.aboutMe,
      required this.Lastsms})
      : super(key: key);
  final String id;
  final String imageUrl;
  final String username;
  final String aboutMe;
  final String Lastsms;

  @override
  State<UserListTilewidget> createState() => _UserListTilewidgetState();
}

class _UserListTilewidgetState extends State<UserListTilewidget> {
  bool isLoading = false;
  String myusername = "";
  String myaboutMe = "";
  String myId = "";
  String chatId = "";
  String myimageUrl = "";

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
    myusername = data.username;
    myaboutMe = data.aboutMe;
    myimageUrl = data.imageUrl;
    myId = data.id;

    if (myId.hashCode <= widget.id.hashCode) {
      chatId = "${myId}-${widget.id}";
    } else {
      chatId = "${widget.id}-${myId}";
    }

  
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
    return InkWell(
      onTap: () =>
          Navigator.of(context).pushNamed(ChatPage.routeName, arguments: {
        "chatId": chatId,
        "name": widget.username,
        "id": widget.id,
        "imageurl": widget.imageUrl,
        "myname": myusername,
        "myid": myId,
        "myimageurl": myimageUrl
      }),
      child: ListTile(
        leading: imageWidget(context, widget.imageUrl),
        title: Text(widget.username),
        subtitle: Text(
          widget.aboutMe,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
