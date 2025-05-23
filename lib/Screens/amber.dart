import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase2/Screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../models/new.dart';
import '../widgets/add_message_in_no_name.dart';
import '../widgets/image_profile.dart';
import '../widgets/all_message.dart';
import 'my_friends.dart';
import 'settings.dart';

class Amber extends StatefulWidget {
  const Amber({super.key});

  @override
  State<Amber> createState() => _AmberState();
}

class _AmberState extends State<Amber> {
// Variable -------------------------------------------------------------------
  List<NewUesr> uesrs = [];
  List<NewNote> notes = [];
  List<String> friends = [];
  final User user = FirebaseAuth.instance.currentUser!;
  CollectionReference<Map<String, dynamic>> notesData =
      FirebaseFirestore.instance.collection("notes");
  CollectionReference<Map<String, dynamic>> uesrsData =
      FirebaseFirestore.instance.collection("uesrs");
  CollectionReference<Map<String, dynamic>> chatsData =
      FirebaseFirestore.instance.collection("chats");
  bool isOpenKey = false;
  String backgroundURL = "", id = "", idUesr = "", phoneID = "";

// Init State -----------------------------------------------------------------
  @override
  void initState() {
    initialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      openFriends();
    });
    FirebaseMessaging.onMessage.listen((event) {
      print("------------------------- Notification -------------------------");
      print(event.notification!.title);
      print(event.notification!.body);
      //print(event.notification!.android!.imageUrl);
      print("----------------------------------------------------------------");
    });
    setState(() => isOpenKey = false);
    uesrsData.snapshots().listen((value) async {
      uesrs = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        if (element["email"] == user.email) {
          backgroundURL = element["backgroundURL"];
          id = element.id;
          idUesr = element["ID"];
          phoneID = element["phoneID"];
          if (phoneID == "") {
            var newPhoneID = FirebaseMessaging.instance;
            await newPhoneID.getToken().then((value) async {
              await uesrsData.doc(element.id).update({"phoneID": value});
              phoneID = value ?? element["phoneID"];
              print(
                  "--------------------------- phone ID ---------------------------");
              print(value);
              print(
                  "----------------------------------------------------------------");
            });
          }
        }
        setState(() {
          uesrs.add(NewUesr(
            element["email"],
            element["name"],
            element["photoURL"],
            element["backgroundURL"],
            element["ID"],
            id: element["email"] == user.email ? element.id : null,
            phoneID: element["phoneID"],
          ));
        });
      }
      setState(() => isOpenKey = true);
    });
    chatsData.snapshots().listen((value) {
      friends = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        if (element["OneEmail"] == user.email) {
          setState(() => friends.add(element["TowEmail"]));
        } else if (element["TowEmail"] == user.email) {
          setState(() => friends.add(element["OneEmail"]));
        }
      }
    });
    super.initState();
  }

  void initialMessage() async {
    RemoteMessage? getInitialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (getInitialMessage != null) {
      openFriends();
    }
  }

// Open Profile ---------------------------------------------------------------
  void openProfile() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Profile(
        user: NewUesr(
          user.email ?? "Error",
          user.displayName ?? "Error",
          user.photoURL ?? "null",
          backgroundURL,
          idUesr,
          id: id,
          phoneID: phoneID,
        ),
        friends: friends,
        uesrs: uesrs,
      ),
    ));
  }

// Open Settings ---------------------------------------------------------------
  void openSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsApp(),
    ));
  }

// Open Friends ---------------------------------------------------------------
  void openFriends() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MyFriends(
        backgroundURL: backgroundURL,
        friends: friends,
        idUesr: idUesr,
        phoneID: phoneID,
        users: uesrs,
      ),
    ));
  }

// Refresh --------------------------------------------------------------------
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {});
  }

// Widget ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: openProfile,
          icon: ImageProfile(sizeImeage: 40, photoURL: user.photoURL ?? ""),
        ),
        title: const Text("Amber"),
        actions: [
          IconButton(onPressed: openSettings, icon: const Icon(Icons.settings)),
        ],
      ),
      body: isOpenKey
          ? RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 4),
                  const AddMessageInNoName(),
                  message(),
                  const SizedBox(height: 4),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: openFriends,
        child: const Icon(Icons.people_rounded, size: 30),
      ),
    );
  }

// Message ---------------------------------------------------------------------
  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> message() {
    return FutureBuilder(
      future: notesData.orderBy("time", descending: true).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AllMessage(
            uesrs: uesrs,
            friends: friends,
            keyProfile: true,
            notes: snapshot.data!.docs
                .map((element) => NewNote(
                      uesrs.firstWhere((e) => e.email == element["email"]),
                      element["title"],
                      element["description"],
                      element["img"],
                      element.id,
                      isMyFriends: element["isPublic"]
                          ? true
                          : friends.any((friend) => friend == element["email"]),
                    ))
                .toList(),
          );
        } else if (snapshot.hasError) {
          return const Icon(Icons.error_outline_rounded);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Icon(Icons.error_outline_rounded);
        }
      },
    );
  }
}
