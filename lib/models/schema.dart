

class CurrentUser {
   String id;
   String username;
   String imageUrl;
   String aboutMe;


  CurrentUser(
      {required this.id,
      required this.username,
      required this.imageUrl,
      required this.aboutMe,
 });
}


class Conversation {
  final String id;
  final String name;
 

  Conversation(
      {required this.id,
      required this.name,
    });
}
