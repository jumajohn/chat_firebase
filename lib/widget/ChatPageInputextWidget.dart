import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class ChatPageInputextWidget extends StatefulWidget {
  const ChatPageInputextWidget({
    Key? key,
    required this.chatId,
    required this.myId,
    required this.myname,
    required this.myimageurl,
    required this.id,
    required this.imageurl,
    required this.name,
    required this.isAlreadyAvailable,
    required this.tobottom,
  }) : super(key: key);
  final String chatId;
  final String myId;
  final String myname;
  final String myimageurl;
  final String id;
  final bool isAlreadyAvailable;
  final String imageurl;
  final String name;
  final Function tobottom;

  @override
  State<ChatPageInputextWidget> createState() => _ChatPageInputextWidgetState();
}

class _ChatPageInputextWidgetState extends State<ChatPageInputextWidget> {
  final FocusNode inputFocus = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  bool isLoading = false;
  bool isFileAttached = false;
  ImagePicker imagePicker = ImagePicker();
  var imageFile;
  String imageUrl = "";
  String attchedFileName = "";

  double uploadPregress = 0;

  Future<void> sendMessage() async {
    String uniqueId =
        "${widget.myId}-${DateTime.now().millisecondsSinceEpoch.toString()}";
    setState(() {
      isLoading = true;
    });

    widget.tobottom();

    try {
      if (widget.isAlreadyAvailable == false) {
        FirebaseFirestore.instance
            .collection("conversations")
            .doc(widget.chatId)
            .set({
          "conversationId": widget.chatId,
          "createdAt": uniqueId,
          "creator": widget.myId,
          "name": "juma",
          "dateModified": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastmessage": textEditingController.text,
          "members": FieldValue.arrayUnion(['${widget.myId}', '${widget.id}'])
        });
      } else {
        FirebaseFirestore.instance
            .collection("conversations")
            .doc(widget.chatId)
            .update({
          "dateModified": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastmessage": textEditingController.text,
        });
      }

      if (isFileAttached == true) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child("Upload Images")
            .child(DateTime.now().millisecondsSinceEpoch.toString());
        UploadTask storageUploadTask = storageReference.putFile(imageFile);
        TaskSnapshot storageUploadTaskSnapshot;

        storageUploadTask.snapshotEvents.listen((event) {
          if (event.state == TaskState.running) {
            setState(() {
              uploadPregress =
                  (event.bytesTransferred / event.totalBytes) * 100;
            });
          }
        });

        storageUploadTask.then((value) {
          storageUploadTaskSnapshot = value;

          storageUploadTaskSnapshot.ref.getDownloadURL().then((newImageUrl) {
            imageUrl = newImageUrl;

            FirebaseFirestore.instance
                .collection("messages")
                .doc(widget.chatId)
                .collection("messages")
                .doc(uniqueId)
                .set({
              "chatId": widget.chatId,
              "senderId": widget.myId,
              "text": textEditingController.text,
              "type": "1",
              "mediaUrl": imageUrl,
              "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
            });

            Scaffold.of(context).showSnackBar(
                const SnackBar(content: Text("Message Sent Successfully")));

            isFileAttached = false;

            setState(() {
              isLoading = false;
            });

            textEditingController.clear();
          }, onError: (error) {
            imageFile = null;
            setState(() {
              isLoading = false;
            });

            Scaffold.of(context)
                .showSnackBar(const SnackBar(content: Text("Error Occurred")));
          });
        }, onError: (err) {
          imageFile = null;
          setState(() {
            isLoading = false;
          });

          Scaffold.of(context)
              .showSnackBar(const SnackBar(content: Text("Error Occurred")));
        });
      } else {
        FirebaseFirestore.instance
            .collection("messages")
            .doc(widget.chatId)
            .collection("messages")
            .doc(uniqueId)
            .set({
          "chatId": widget.chatId,
          "senderId": widget.myId,
          "text": textEditingController.text,
          "type": "0",
          "mediaUrl": "0",
          "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
        });

        textEditingController.clear();

        Scaffold.of(context).showSnackBar(
            const SnackBar(content: Text("Message Sent Successfully")));

        isFileAttached = false;

        setState(() {
          isLoading = false;
        });
      }
    } catch (err) {
      // ignore: deprecated_member_use
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Error Occurred ${err.toString()}")));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> inputFileset() async {
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      imageFile = File(file.path);
      isFileAttached = true;
      attchedFileName = file.path;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: const BoxConstraints(maxHeight: 150),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(width: 0.5, color: Colors.grey),
              )),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: Colors.white,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: isFileAttached
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                isFileAttached = false;
                              });
                            },
                            icon: Icon(Icons.cancel))
                        : IconButton(
                            onPressed: inputFileset,
                            icon: const Icon(Icons.photo))),
              ),
              Material(
                color: Colors.white,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.emoji_emotions))),
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(
                  10,
                ),
                child: TextField(
                  controller: textEditingController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 20),
                  focusNode: inputFocus,
                  decoration: const InputDecoration.collapsed(
                      hintText: "write message",
                      hintStyle: TextStyle(color: Colors.grey)),
                ),
              )),
              Material(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: isLoading
                        ? CircularProgressIndicator(
                            value: isFileAttached ? uploadPregress / 100 : null,
                            color: Colors.orange,
                          )
                        : IconButton(
                            onPressed: sendMessage,
                            icon: const Icon(Icons.send))),
              ),
            ],
          ),
        ),
        if (isFileAttached)
          Container(
            child: ListTile(
              title: Text(" attached file"),
              subtitle: Text(
                attchedFileName,
                softWrap: true,
              ),
            ),
          ),
      ],
    );
  }
}
