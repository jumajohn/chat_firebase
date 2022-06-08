import 'package:flutter/material.dart';
import '../widget/ChatPageInputextWidget.dart';
import '../widget/StickerWidget.dart';
import '../widget/MessageCardWidget.dart';
import 'package:provider/provider.dart';
import '../provider/DataProvider.dart';
import '../models/schema.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  static const routeName = "/chatpage";
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isInit = true;

  late String chatId;
  late String myId;
  late String myname;
  late String myimageurl;
  late String id;
  late String imageurl;
  late String name;
  late bool isAlreadyAvailable;
  bool isFileAttached = false;
  String attchedFileName = "";
  bool canscroll = true;

  ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    if (isInit) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      // ignore: unnecessary_null_comparison
      if (args == null) {
        return;
      }
      chatId = args['chatId'];
      name = args['name'];
      chatId = args["chatId"];
      name = args["name"];
      id = args["id"];
      imageurl = args["imageurl"];
      myname = args["myname"];
      myId = args["myid"];
      myimageurl = args["myimageurl"];

      final List<Conversation> convs =
          Provider.of<DataProvider>(context, listen: false).conv;
      for (var map in convs) {
        if (map.id == chatId) {
          isAlreadyAvailable = true;
        } else {
          isAlreadyAvailable = false;
        }
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(seconds: 2), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .doc(chatId)
                  .collection("messages")
                  .orderBy("createdAt", descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    return const Center(child: Text("Start Coversation"));
                  }

                  final List<QueryDocumentSnapshot> item = snapshot.data!.docs;

                 

                  return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(top: 10, bottom: 50),
                      itemCount: item.length,
                      itemBuilder: (context, index) {
                        final itemData = item[index];

                        bool isMe = itemData['senderId'] == myId;

                        return MessageCardWidget(
                          isMe: isMe,
                          text: itemData['text'],
                          type: itemData['type'],
                          url: itemData['mediaUrl'],
                          createdAt: itemData['createdAt'],
                        );
                      });
                }
              },
            ),
          ),
          ChatPageInputextWidget(
            tobottom: scrollToBottom,
            id: id,
            name: name,
            imageurl: imageurl,
            myId: myId,
            myimageurl: myimageurl,
            myname: myname,
            chatId: chatId,
            isAlreadyAvailable: isAlreadyAvailable,
          ),
          const StickerWidget()
        ],
      ),
    );
  }
}
