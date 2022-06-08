import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/schema.dart';

class DataProvider with ChangeNotifier {
  List<CurrentUser> _items = [];

  List<CurrentUser> get items {
    return [..._items];
  }

  List<Conversation> _conv = [Conversation(id: "null", name: "null")];

  List<Conversation> get conv {
    return [..._conv];
  }

  void setDetails(Map data) {
    if (data["imageUrl"] == null) {
      var variable = _items.firstWhere((element) => element.id == data['id']);
      variable.username = data["username"];
      variable.aboutMe = data["aboutMe"];
    } else {
      _items.add(CurrentUser(
        id: data["id"],
        username: data["username"],
        imageUrl: data["imageUrl"],
        aboutMe: data["aboutMe"],
      ));
    }
  }

  void setConversations(Map data) {
    _conv.add(Conversation(
      id: data['id'],
      name: data['name'],
    ));
  }

  void logout() {
    _items.clear();
    _conv.clear();
  }
}
