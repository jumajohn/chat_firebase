import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../pages/ImageView.dart';

class UserImageWidget extends StatefulWidget {
  const UserImageWidget({Key? key}) : super(key: key);

  @override
  State<UserImageWidget> createState() => _UserImageWidgetState();
}

class _UserImageWidgetState extends State<UserImageWidget> {
  ImagePicker imagePicker = ImagePicker();
  var imageFile;
  String imageUrl = "";
  String id = "";
  bool isLoading = false;

  Future<void> pickImage() async {
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      imageFile = File(file.path);

      uploadImage();
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      isLoading = true;
    });
    Reference storageReference = FirebaseStorage.instance.ref().child(id);
    UploadTask storageUploadTask = storageReference.putFile(imageFile);
    TaskSnapshot storageUploadTaskSnapshot;
    storageUploadTask.then((value) {
      storageUploadTaskSnapshot = value;
      
      storageUploadTaskSnapshot.ref.getDownloadURL().then((newImageUrl) {
        imageUrl = newImageUrl;
        FirebaseFirestore.instance.collection("users").doc(id).update({
          "imageUrl": newImageUrl,
        }).then((value) async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString("imageUrl", imageUrl);
          setState(() {
            isLoading = false;
          });
          Scaffold.of(context).showSnackBar(
              const SnackBar(content: Text("Image successfuly changed")));
        }, onError: (err) {
          imageFile = null;
          setState(() {
            isLoading = false;
          });

          Scaffold.of(context)
              .showSnackBar(const SnackBar(content: Text("Error Occurred")));
        });
      }, onError: (error) {
        imageFile = null;
        setState(() {
          isLoading = false;
        });

        Scaffold.of(context)
            .showSnackBar(const SnackBar(content: Text("Error Occurred")));
      });
    }, onError: (error) {
      print(error);
      imageFile = null;
      setState(() {
        isLoading = false;
      });
      // ignore: deprecated_member_use
      Scaffold.of(context)
          .showSnackBar(const SnackBar(content: Text("Error Occurred")));
    });
  }

  void readPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    imageUrl = prefs.getString("imageUrl")!;
    id = prefs.getString("id")!;
    setState(() {});
  }

  @override
  void initState() {
    readPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 20, bottom: 10),
          child: ClipOval(
           child: InkWell(
        onTap: () => Navigator.of(context)
          .pushNamed(ImageView.routeName, arguments: {"url": imageUrl}),
        child: Hero(
          tag:imageUrl,
              child: CachedNetworkImage(
                width: 100,
                height: 110,
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => imageFile != null
                    ? Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/Capture5.PNG",
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ),),
        Positioned(
            right: 0,
            bottom: 0,
            child: isLoading
                ? const CircularProgressIndicator()
                : Material(
                    clipBehavior: Clip.hardEdge,
                    color: Colors.lightBlueAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    child: IconButton(
                      onPressed: pickImage,
                      icon: const Icon(Icons.camera_alt),
                    )))
      ],
    );
  }
}
