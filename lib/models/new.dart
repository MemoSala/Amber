class NewNote {
  final NewUesr uesr;
  final String title;
  final List photoURL;
  final String description;
  final bool isMyFriends;
  final String id;
  const NewNote(this.uesr, this.title, this.description, this.photoURL, this.id,
      {required this.isMyFriends});
}

class NewUesr {
  final String email;
  final String name;
  final String photoURL;
  final String backgroundURL;
  final String idUesr;
  final String? id;
  final String phoneID;
  const NewUesr(
      this.email, this.name, this.photoURL, this.backgroundURL, this.idUesr,
      {this.id, required this.phoneID});
}

class NewChat {
  final NewUesr uesr;
  final int isOpenOne;
  final int isOpenTow;
  final String id;
  final String? idChat;
  final bool igo;
  const NewChat(this.uesr, this.isOpenOne, this.isOpenTow, this.id, this.igo,
      {this.idChat});
}

class NewMessage {
  final NewUesr uesr;
  final String messageText;
  final String id;
  final bool isMy;
  final String emoji;
  final String? photoURL;
  final NewMessage? reply;
  const NewMessage(this.uesr, this.messageText, this.id,
      {required this.isMy, this.photoURL, required this.emoji, this.reply});
}
