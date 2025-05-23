// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/new.dart';
import '../models/tools.dart';
import '../widgets/emoji_in.dart';
import '../widgets/read_sata_user.dart';
import 'open_image.dart';

class Chat extends StatefulWidget {
  const Chat({
    super.key,
    required this.friend,
    required this.backgroundURL,
    required this.idUesr,
    required this.idChat,
    required this.phoneID,
    this.users,
  });
  final String backgroundURL, idUesr, idChat, phoneID;
  final NewChat friend;
  final List<NewUesr>? users;

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with Tools {
  // Variable -------------------------------------------------------------------
  final messagTextContronal = TextEditingController();
  final CollectionReference<Map<String, dynamic>> allChatsData =
      FirebaseFirestore.instance.collection("chats");
  final User user = FirebaseAuth.instance.currentUser!;
  String messageText = "";
  String reply = "";
  List<NewMessage> messages = [];
  NewMessage? mesReply;
  bool emojiKey = false, gridView = false;

// Add Topic ------------------------------------------------------------------
  void addTopic() async {
    if (widget.friend.uesr.idUesr == "group") {
      await FirebaseMessaging.instance.subscribeToTopic(widget.friend.id);
    }
  }

// Init State -----------------------------------------------------------------
  late CollectionReference<Map<String, dynamic>> chatsData;
  @override
  void initState() {
// Open Chat ------------------------------------------------------------------
    chatsData = FirebaseFirestore.instance
        .collection("openChat")
        .doc(widget.friend.uesr.idUesr == "group" ? "openGroups" : "openChats")
        .collection(widget.friend.id);
    addTopic();
    chatsData.orderBy("time", descending: true).snapshots().listen((value) {
      messages = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        QueryDocumentSnapshot<Map<String, dynamic>>? reply;
        if (element["reply"] != "") {
          reply = value.docs.firstWhere((e) => e.id == element["reply"]);
        }
        setState(() {
          messages.add(NewMessage(
            element["email"] == user.email
                ? NewUesr(
                    user.email!,
                    user.displayName!,
                    user.photoURL!,
                    widget.backgroundURL,
                    widget.idUesr,
                    phoneID: widget.phoneID,
                  )
                : NewUesr(
                    element["email"],
                    widget.friend.uesr.name,
                    widget.friend.uesr.photoURL,
                    widget.friend.uesr.backgroundURL,
                    widget.friend.uesr.idUesr,
                    phoneID: widget.friend.uesr.phoneID,
                  ),
            element["Text"],
            element.id,
            isMy: element["email"] == user.email,
            emoji: element["emoji"],
            photoURL: element["photo"],
            reply: reply == null
                ? null
                : NewMessage(
                    reply["email"] == user.email
                        ? NewUesr(
                            user.email!,
                            user.displayName!,
                            user.photoURL!,
                            widget.backgroundURL,
                            widget.idUesr,
                            phoneID: widget.phoneID,
                          )
                        : widget.friend.uesr,
                    reply["Text"],
                    reply.id,
                    isMy: reply["email"] == user.email,
                    emoji: reply["emoji"],
                  ),
          ));
        });
      }
    });
    super.initState();
  }

// Sind Button ----------------------------------------------------------------
  void sindButton() async {
    String? urlPhoto;
    if (messageText != "" || file != null) {
      messagTextContronal.clear();
      if (file != null) {
        Reference refStorage = FirebaseStorage.instance.ref(
            "Open Chats/${widget.friend.id}/${path.basename(file!.path)}(${math.Random.secure().nextInt(10000)})");
        await refStorage.putFile(file!);
        urlPhoto = await refStorage.getDownloadURL();
      }
      sendNotfiy(
        title: widget.friend.uesr.name,
        body: messageText,
        imageUrl: urlPhoto,
        phoneID: widget.friend.uesr.phoneID,
      );
      await chatsData
          .add({
            "Text": messageText,
            "email": user.email,
            "time": FieldValue.serverTimestamp(),
            "emoji": "",
            "reply": (reply == "") ? "" : mesReply!.id,
            "photo": urlPhoto ?? "",
          })
          .then((value) => setState(() {
                reply = "";
                messageText = "";
                file = null;
              }))
          .catchError((e) => error("$e"));
    }
  }

// Sind Notfiy ----------------------------------------------------------------
  void sendNotfiy({
    required String title,
    required String phoneID,
    required String body,
    String? imageUrl,
  }) async {
    String serverKey =
        "AAAAAUGx0ns:APA91bHjv2M-NkNkNZ1ERXmXn7BANODrxWF0ZYLH15XKXJrsT6G_h_ol6WXDRmBro6464ZKiZTRQuKYI-9saRKEfTltyNoXnOJFRWLInQVIXr4y9Hf0M4FKFDbYuvlzlomhCnqE_O7mf";
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(<String, dynamic>{
        'notification': <String, dynamic>{
          'body': body,
          'title': title,
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'to': phoneID
      }),
    );
  }

// Block Friend Dialog --------------------------------------------------------
  void blockFriendDialog() => dialog(
        context,
        text: "Block",
        onPressed: blockFriend,
        title: "Block",
        child: Text("Do you want to Block ${widget.friend.uesr.name}."),
      );

// Block Friend ---------------------------------------------------------------
  void blockFriend() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    widget.friend.igo
        ? allChatsData.doc(widget.idChat).update({"isOpenOne": 3})
        : allChatsData.doc(widget.idChat).update({"isOpenTow": 3});
  }

// Copy Message ---------------------------------------------------------------
  void copyMessage() {
    Clipboard.setData(ClipboardData(text: mesReply!.messageText));
    setState(() => emojiKey = false);
  }

// Reply Message --------------------------------------------------------------
  void replyMessage() => setState(() {
        reply = mesReply!.messageText;
        emojiKey = false;
      });

// Delete Message Dialog ------------------------------------------------------
  void deleteMessageDialog() => dialog(
        context,
        text: "Delete",
        onPressed: deleteMessage,
        title: "Delete Messages.",
      );

// Delete Message -------------------------------------------------------------
  void deleteMessage() async {
    setState(() => emojiKey = false);
    await chatsData.doc(mesReply!.id).delete();
  }

// Get Photo ------------------------------------------------------------------
  File? file;
  void getPhoto(ImageSource imageSource) async {
    setState(() => gridView = false);
    XFile? imageXFile = await ImagePicker().pickImage(source: imageSource);
    if (imageXFile != null) setState(() => file = File(imageXFile.path));
  }

// Open Emoji Key -------------------------------------------------------------
  void openEmojiKey(mes) => setState(() {
        emojiKey = true;
        mesReply = mes;
      });

// Text Emoji Void ------------------------------------------------------------
  void textEmojiVoid(text) async {
    text == "🚫"
        ? await chatsData
            .doc(mesReply!.id)
            .collection("emoji")
            .doc(user.email)
            .delete()
        : await chatsData
            .doc(mesReply!.id)
            .collection("emoji")
            .doc(user.email)
            .set({"emoji": text, "email": user.email});
    setState(() => emojiKey = false);
  }

//

// Widget =====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleSpacing: -15,
// User -----------------------------------------------------------------------
        title:
            ReadDataUser(uesr: widget.friend.uesr, icon: Icons.group_rounded),
// Block ----------------------------------------------------------------------
        actions: [
          if (widget.friend.uesr.idUesr != "group")
            IconButton(
              onPressed: blockFriendDialog,
              icon: const Icon(Icons.block_rounded),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(children: [
        // Body Chat ----------------------------------------------------------
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [allMessages(context), sendMessage()],
        ),
        // Button is Exit Emoji and Grid View ---------------------------------
        if (emojiKey || gridView)
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: GestureDetector(
              onTap: () => setState(() {
                emojiKey = false;
                gridView = false;
              }),
            ),
          ),
        // Emoji --------------------------------------------------------------
        Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            transform: Matrix4.translationValues(emojiKey ? 0 : -420, -72, 0),
            child: mesReply != null
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      textEmoji("❤️"),
                      textEmoji("😂"),
                      textEmoji("😮"),
                      textEmoji("😢"),
                      textEmoji("😠"),
                      textEmoji("👍"),
                      textEmoji("🚫"),
                    ]),
                  )
                : null,
          ),
        ),
        // Edit Message -------------------------------------------------------
        Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 80 - 16,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            transform: Matrix4.translationValues(0, emojiKey ? 0 : 80, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                coolButton(
                  icon: Icons.copy,
                  text: "Copy",
                  onPressed: copyMessage,
                ),
                coolButton(
                  icon: Icons.reply,
                  text: "Reply",
                  onPressed: replyMessage,
                ),
                if (mesReply != null)
                  if (mesReply!.uesr.email == user.email)
                    coolButton(
                      icon: Icons.delete_outline,
                      text: "Delete",
                      onPressed: deleteMessageDialog,
                    ),
              ],
            ),
          ),
        ),
        // Grid View ----------------------------------------------------------
        Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 80 - 16,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            transform: Matrix4.translationValues(0, gridView ? 0 : 80, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                coolButton(
                  icon: Icons.camera_alt_rounded,
                  text: "Camera",
                  onPressed: () => getPhoto(ImageSource.camera),
                ),
                coolButton(
                  icon: Icons.add_photo_alternate_outlined,
                  text: "Gallery",
                  onPressed: () => getPhoto(ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
        // background Color ---------------------------------------------------
        Container(
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 110,
            color: Colors.amber.shade50,
            transform: Matrix4.translationValues(0, 110, 0),
          ),
        ),
      ]),
    );
  }

// All Messages ---------------------------------------------------------------
  Expanded allMessages(BuildContext context) {
    return Expanded(
      child: ListView(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        children: [
          for (NewMessage mes in messages)
            Stack(children: [
              // One Message --------------------------------------------------
              oneMessage(mes),
              // Emoji --------------------------------------------------------
              Positioned(
                left: mes.isMy ? null : 25,
                right: mes.isMy ? 25 : null,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12.5),
                  ),
                  child: EmojiIn(
                    notesData: chatsData.doc(mes.id).collection("emoji"),
                    size: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ])
        ],
      ),
    );
  }

// One Message ----------------------------------------------------------------
  Container oneMessage(NewMessage mes) {
    late String name;
    if (widget.users != null) {
      try {
        name = widget.users!
            .firstWhere((element) => element.email == mes.uesr.email)
            .name;
      } catch (e) {
        name = mes.uesr.name;
      }
    } else {
      name = mes.uesr.name;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 5, bottom: 15, right: 10, left: 10),
      child: Column(
        crossAxisAlignment:
            mes.isMy ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Name User --------------------------------------------------------
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          // Data Message -----------------------------------------------------
          GestureDetector(
            onLongPress: () => openEmojiKey(mes),
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular((mes.isMy) ? 0 : 20),
                topLeft: Radius.circular((mes.isMy) ? 20 : 0),
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
              color: (mes.isMy) ? Colors.black87 : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Reply -----------------------------------------------
                  if (mes.reply != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 28, right: 28, top: 10),
                      child: Text(
                        mes.reply!.uesr.name,
                        style: TextStyle(
                          color: Colors.amber.withOpacity(mes.isMy ? 0.7 : 1),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  // Text Reply -----------------------------------------------
                  if (mes.reply != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        mes.reply!.messageText,
                        style: TextStyle(
                          color: (mes.isMy) ? Colors.white70 : Colors.black38,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  // Text Message ---------------------------------------------
                  if (mes.messageText != "")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        mes.messageText,
                        style: TextStyle(
                          color: (mes.isMy) ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  // photo Message --------------------------------------------
                  if (mes.photoURL != "")
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          mes.messageText != "" || mes.reply != null
                              ? 0
                              : (mes.isMy)
                                  ? 0
                                  : 20,
                        ),
                        topLeft: Radius.circular(
                          mes.messageText != "" || mes.reply != null
                              ? 0
                              : (mes.isMy)
                                  ? 20
                                  : 0,
                        ),
                        bottomLeft: const Radius.circular(20),
                        bottomRight: const Radius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OpenImage(
                              imageUrl: mes.photoURL!,
                              imageName: mes.uesr.name,
                            ),
                          ),
                        ),
                        child: Image.network(mes.photoURL!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Send Message ---------------------------------------------------------------
  Column sendMessage() {
    return Column(children: [
      // photo Message --------------------------------------------------------
      if (file != null)
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // photo ------------------------------------------------------------
          Container(
            height: 100,
            padding: const EdgeInsets.all(2.0),
            constraints: const BoxConstraints(maxWidth: 250),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.file(
                file!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Delete photo -----------------------------------------------------
          IconButton(
            onPressed: () => setState(() => file = null),
            icon: const Icon(Icons.close_rounded),
          ),
        ]),
      // Divider And Reply ----------------------------------------------------
      Container(
        width: double.infinity,
        color: Colors.amber,
        constraints: const BoxConstraints(minHeight: 2),
        child: reply == ""
            ? null
            : Row(children: [
                // Data Reply -------------------------------------------------
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 2, bottom: 2, left: 5),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reply,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Delete Reply -----------------------------------------------
                Container(
                  height: 24,
                  transform: Matrix4.translationValues(0, 0, 0),
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () => setState(() {
                      reply = "";
                      emojiKey = false;
                    }),
                    icon: const Icon(Icons.close_rounded),
                  ),
                )
              ]),
      ),
      // Made Message ----------------------------------------------------------
      Row(children: [
        // Write Message ------------------------------------------------------
        Expanded(
          child: TextField(
            controller: messagTextContronal,
            onChanged: (value) {
              messageText = value;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              hintText: "Write your message here...",
              border: InputBorder.none,
            ),
          ),
        ),
        // Tools Message ------------------------------------------------------
        IconButton(
          onPressed: () => setState(() => gridView = !gridView),
          icon: const Icon(Icons.grid_view_rounded),
        ),
        // Button Sind Message ------------------------------------------------------
        TextButton(
          onPressed: sindButton,
          child: Text(
            "send",
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
    ]);
  }

// Text Emoji -----------------------------------------------------------------
  TextButton textEmoji(text) => TextButton(
        onPressed: () => textEmojiVoid(text),
        child: Text(text, style: const TextStyle(fontSize: 30)),
      );
// Cool Button ----------------------------------------------------------------
  IconButton coolButton({
    required IconData icon,
    required String text,
    required void Function() onPressed,
  }) =>
      IconButton(
        onPressed: onPressed,
        iconSize: 30,
        icon: Column(children: [
          Icon(icon),
          Text(text, style: const TextStyle(fontSize: 12)),
        ]),
      );

// Error ----------------------------------------------------------------
  AwesomeDialog error(String e) => AwesomeDialog(
        context: context,
        title: "Error",
        body: Text("$e\n", textAlign: TextAlign.center),
      );
}
