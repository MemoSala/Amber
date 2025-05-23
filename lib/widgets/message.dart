import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Screens/edit_message.dart';
import '../Screens/open_image.dart';
import '../Screens/profile.dart';
import '../models/new.dart';
import 'add_comment.dart';
import 'comment.dart';
import 'emoji_in.dart';
import 'read_sata_user.dart';

class NameMenuData {
  final String name;
  final IconData icon;
  const NameMenuData(this.name, this.icon);
}

class Message extends StatelessWidget {
  const Message({
    super.key,
    required this.note,
    required this.keyProfile,
    required this.friends,
    this.isMaxLine = false,
    required this.uesrs,
  });
  final bool isMaxLine;
  final NewNote note;
  final bool keyProfile;
  final List<String> friends;
  final List<NewUesr> uesrs;
  final List<NameMenuData> menuData = const [
    NameMenuData("Copy ID", Icons.copy_outlined),
    NameMenuData("Edit", Icons.edit),
    NameMenuData("Delete", Icons.delete),
  ];

// Menu Void ------------------------------------------------------------------
  void menuVoid(context, int value, NewNote note) {
    CollectionReference<Map<String, dynamic>> notesData =
        FirebaseFirestore.instance.collection("notes");
    switch (value) {
      case 0:
        Clipboard.setData(ClipboardData(text: note.uesr.idUesr));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditMessage(note: note),
        ));
        break;
      case 2:
        notesData.doc(note.id).delete();
        if (isMaxLine) Navigator.of(context).pop();
        break;
      default:
    }
  }

  // Open User Message Profile --------------------------------------------------
  void openUserMessageProfile(BuildContext context, NewUesr uesr) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Profile(
        uesrs: uesrs,
        user: NewUesr(
          uesr.email,
          uesr.name,
          uesr.photoURL,
          uesr.backgroundURL,
          uesr.idUesr,
          id: uesr.id,
          phoneID: uesr.phoneID,
        ),
        friends: friends,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
// Purt One User --------------------------------------------------------------
          ReadDataUser(
            uesr: note.uesr,
            sizeImeage: 40,
            onTap: () =>
                keyProfile ? openUserMessageProfile(context, note.uesr) : null,
            child: PopupMenuButton<int>(
              onSelected: (value) => menuVoid(context, value, note),
              itemBuilder: (context) => [
                for (int index = 0; index < menuData.length; index++)
                  if (note.uesr.email == user.email || index == 0)
                    PopupMenuItem(
                      value: index,
                      child: Row(children: [
                        Icon(menuData[index].icon),
                        const SizedBox(width: 8),
                        Text(menuData[index].name),
                      ]),
                    ),
              ],
            ),
          ),
// Message Title --------------------------------------------------------------
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
// Message Description --------------------------------------------------------
          if (note.description.isNotEmpty)
            Text(
              note.description,
              maxLines: isMaxLine ? 10000 : 5,
              overflow: TextOverflow.ellipsis,
            ),
// Message Image --------------------------------------------------------------
          if (note.photoURL.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => OpenImage(
                      imageUrl: note.photoURL[0],
                      imageName: note.title,
                    ),
                  )),
                  child: Image.network(
                    note.photoURL[0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
// comment --------------------------------------------------------------------
          const SizedBox(height: 8),
          Row(children: [
            AddComment(id: note.id),
            Expanded(
              child: EmojiIn(
                notesData: FirebaseFirestore.instance
                    .collection("notes")
                    .doc(note.id)
                    .collection("emoji"),
              ),
            ),
            AddEmojiInMessage(id: note.id),
          ]),
          Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Comment(id: note.id, uesrs: uesrs, isMaxLine: isMaxLine),
          ),
        ],
      ),
    );
  }
}

class PopupMenuWidget<T> extends PopupMenuEntry<T> {
  const PopupMenuWidget({super.key, required this.height, required this.child});

  final Widget child;

  @override
  final double height;

  @override
  State<PopupMenuWidget> createState() => _PopupMenuWidgetState();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PopupMenuWidgetState extends State<PopupMenuWidget> {
  @override
  Widget build(BuildContext context) => widget.child;
}

class AddEmojiInMessage extends StatefulWidget {
  const AddEmojiInMessage({super.key, required this.id});
  final String id;

  @override
  State<AddEmojiInMessage> createState() => _AddEmojiInMessageState();
}

class _AddEmojiInMessageState extends State<AddEmojiInMessage> {
  late CollectionReference<Map<String, dynamic>> notesData;
  String commentType = "";
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    notesData = FirebaseFirestore.instance
        .collection("notes")
        .doc(widget.id)
        .collection("emoji");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      InkWell(
        onTap: () async {
          await notesData.doc(user.email).set({
            "emoji": "👍",
            "email": user.email,
          });
        },
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Text("👍", style: TextStyle(fontSize: 22)),
        ),
      ),
      PopupMenuButton<String>(
        onSelected: (String emoji) async {
          if (emoji == "🚫") {
            await notesData.doc(user.email).delete();
          } else {
            await notesData.doc(user.email).set({
              "emoji": emoji,
              "email": user.email,
            });
          }
        },
        itemBuilder: (BuildContext context) => [
          PopupMenuWidget(
            height: 40.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                emojiButton(emoji: "👍"),
                emojiButton(emoji: "❤️"),
                emojiButton(emoji: "😂"),
                emojiButton(emoji: "😮"),
                emojiButton(emoji: "😢"),
                emojiButton(emoji: "😠"),
                emojiButton(emoji: "🚫"),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  InkWell emojiButton({required String emoji}) {
    return InkWell(
      onTap: () => Navigator.pop(context, emoji),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
