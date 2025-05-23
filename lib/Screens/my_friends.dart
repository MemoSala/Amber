import 'dart:math' as math;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/new.dart';
import '../widgets/read_sata_user.dart';
import 'chat.dart';
import 'profile.dart';

class MyFriends extends StatefulWidget {
  const MyFriends({
    super.key,
    required this.backgroundURL,
    required this.friends,
    required this.idUesr,
    required this.phoneID,
    required this.users,
  });
  final String backgroundURL, idUesr, phoneID;
  final List<String> friends;
  final List<NewUesr> users;
  @override
  State<MyFriends> createState() => _MyFriendsState();
}

class _MyFriendsState extends State<MyFriends> {
  CollectionReference<Map<String, dynamic>> uesrsData =
      FirebaseFirestore.instance.collection("uesrs");
  CollectionReference<Map<String, dynamic>> chatsData =
      FirebaseFirestore.instance.collection("chats");
  final User user = FirebaseAuth.instance.currentUser!;
  bool isOpenKey = false;

  List<NewChat> chats = [];
  List<NewUesr> uesrs = [];

  void futureInitState() async {
    setState(() => isOpenKey = false);
    await uesrsData
        .where("email", isNotEqualTo: user.email)
        .get()
        .then((value) {
      uesrs = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        setState(() {
          uesrs.add(NewUesr(
            element["email"],
            element["name"],
            element["photoURL"],
            element["backgroundURL"],
            element["ID"],
            phoneID: element["phoneID"],
          ));
        });
      }
      chatsData.snapshots().listen((value) {
        uesrs = uesrs;
        chats = [];
        for (QueryDocumentSnapshot<Map<String, dynamic>> element
            in value.docs) {
          NewUesr chat =
              const NewUesr("No Email", "No Name", "", "", "...", phoneID: "");
          try {
            if (element["OneEmail"] == user.email) {
              chat = uesrs.firstWhere((e) => e.email == element["TowEmail"]);
            } else if (element["TowEmail"] == user.email) {
              chat = uesrs.firstWhere((e) => e.email == element["OneEmail"]);
            }
          } catch (e) {
            null;
          }
          if (chat.email != "No Email" && chat.email != "Error") {
            setState(() {
              chats.add(NewChat(
                chat,
                element["isOpenOne"],
                element["isOpenTow"],
                element["id"],
                idChat: element.id,
                element["OneEmail"] == user.email,
              ));
            });
          }
        }
      });
      setState(() => isOpenKey = true);
    });
  }

  void addGroup() {}

  @override
  void initState() {
    futureInitState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Friends"),
          bottom: TabBar(
            tabs: [
              newTab(Icons.group),
              newTab(Icons.person_rounded),
              newTab(Icons.person_pin_rounded),
              newTab(Icons.person_add_rounded),
              newTab(Icons.person_off_rounded),
            ],
          ),
        ),
        body: TabBarView(children: [
          myGroups(),
          myFriends(),
          friendshipRequests(),
          notFriends(),
          block(),
        ]),
      ),
    );
  }

  Widget myGroups() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textOpen("Groups:"),
            AllGroups(users: widget.users),
            //const Center(child: Text("You don't have Groups.")),
            completed(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addGroup,
        child: const Icon(Icons.group_add_rounded),
      ),
    );
  }

  Widget myFriends() {
    List<NewChat> newchats = chats
        .where((element) => element.isOpenOne == 1 && element.isOpenTow == 1)
        .toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textOpen("Friends:"),
          if (newchats.isEmpty)
            const Center(child: Text("You don't have friends.")),
          if (newchats.isNotEmpty)
            for (NewChat element in newchats)
              ReadDataUser(
                uesr: element.uesr,
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Profile(
                        uesrs: uesrs,
                        user: NewUesr(
                          element.uesr.email,
                          element.uesr.name,
                          element.uesr.photoURL,
                          element.uesr.backgroundURL,
                          element.uesr.idUesr,
                          phoneID: element.uesr.phoneID,
                        ),
                        friends: widget.friends),
                  )),
                  icon: Transform.rotate(
                    angle: 0.5 * pi,
                    child: const Icon(Icons.keyboard_control),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Chat(
                      friend: element,
                      backgroundURL: widget.backgroundURL,
                      idUesr: widget.idUesr,
                      idChat: element.idChat!,
                      phoneID: widget.phoneID,
                    ),
                  ));
                },
              ),
        ],
      ),
    );
  }

  Widget friendshipRequests() {
    List<NewChat> newchats = chats
        .where((element) =>
            element.isOpenOne == 1 && element.isOpenTow == 0 && !(element.igo))
        .toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (newchats.isEmpty)
          const Center(child: Text("You don't have Friendship Requests.")),
        if (newchats.isNotEmpty) textOpen("Friendship Requests:"),
        if (newchats.isNotEmpty)
          for (NewChat element in newchats)
            ReadDataUser(
              uesr: element.uesr,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await chatsData
                          .doc(element.idChat)
                          .update({"isOpenTow": 3});
                    },
                    icon: const Icon(Icons.block, size: 30),
                  ),
                  IconButton(
                    onPressed: () async {
                      await chatsData
                          .doc(element.idChat)
                          .update({"isOpenTow": 1});
                    },
                    icon: const Icon(Icons.check_circle, size: 30),
                  ),
                ],
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Profile(
                    uesrs: uesrs,
                    user: NewUesr(
                      element.uesr.email,
                      element.uesr.name,
                      element.uesr.photoURL,
                      element.uesr.backgroundURL,
                      element.uesr.idUesr,
                      phoneID: element.uesr.phoneID,
                    ),
                    friends: widget.friends),
              )),
            ),
      ]),
    );
  }

  Widget notFriends() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          textOpen("People You May Know:"),
          for (NewUesr element in uesrs.where((element) {
            for (var e in chats) {
              if (e.uesr.email == element.email) {
                return false;
              }
            }
            return true;
          }))
            ReadDataUser(
              uesr: element,
              child: IconButton(
                onPressed: () {
                  chatsData.add({
                    "OneEmail": user.email,
                    "TowEmail": element.email,
                    "id":
                        "${user.email![2]}${element.email[2]}${math.Random.secure().nextInt(1000000)}x${math.Random.secure().nextInt(1000000)}",
                    "isOpenOne": 1,
                    "isOpenTow": 0,
                  });
                },
                icon: const Icon(Icons.add_circle_rounded),
              ),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Profile(
                  uesrs: uesrs,
                  user: NewUesr(
                    element.email,
                    element.name,
                    element.photoURL,
                    element.backgroundURL,
                    element.idUesr,
                    phoneID: element.phoneID,
                  ),
                  friends: widget.friends,
                ),
              )),
            ),
          completed(),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_search_rounded),
      ),
    );
  }

  Widget block() {
    List<NewChat> newchats = chats
        .where((element) =>
            (element.isOpenOne == 3 && element.igo) ||
            (element.isOpenTow == 3 && !(element.igo)))
        .toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (newchats.isEmpty)
          const Center(child: Text("You don't have Block friends.")),
        if (newchats.isNotEmpty) textOpen("Block:"),
        if (newchats.isNotEmpty)
          for (NewChat element in newchats)
            ReadDataUser(
              uesr: element.uesr,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Profile(
                  uesrs: uesrs,
                  user: NewUesr(
                    element.uesr.email,
                    element.uesr.name,
                    element.uesr.photoURL,
                    element.uesr.backgroundURL,
                    element.uesr.idUesr,
                    phoneID: element.uesr.phoneID,
                  ),
                  friends: widget.friends,
                ),
              )),
              child: IconButton(
                onPressed: () async {
                  if (element.igo) {
                    await chatsData
                        .doc(element.idChat)
                        .update({"isOpenOne": 1});
                  } else {
                    await chatsData
                        .doc(element.idChat)
                        .update({"isOpenTow": 1});
                  }
                },
                padding: EdgeInsets.zero,
                icon: const Column(children: [
                  Icon(Icons.person_remove_alt_1_rounded, size: 20),
                  Text(
                    "Remove\nBlock",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                ]),
              ),
            ),
      ]),
    );
  }

  Tab newTab(IconData icon) {
    return Tab(
      icon: SizedBox(
        width: double.infinity,
        child: Icon(icon),
      ),
    );
  }

  Text textOpen(text) => Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );

  Container completed() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "It isn't completed.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AllGroups extends StatelessWidget {
  const AllGroups({super.key, required this.users});
  final List<NewUesr> users;

  @override
  Widget build(BuildContext context) {
    final User user = FirebaseAuth.instance.currentUser!;
    CollectionReference<Map<String, dynamic>> groupsData =
        FirebaseFirestore.instance.collection("groups");
    return StreamBuilder(
      stream: groupsData.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              for (QueryDocumentSnapshot<Map<String, dynamic>> group
                  in snapshot.data!.docs)
                if (user.email == group["admin"] ||
                    group["participants"]
                        .any((element) => element == user.email))
                  ReadDataUser(
                    icon: Icons.group_rounded,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Chat(
                          friend: NewChat(
                            NewUesr(
                              "",
                              group["name"],
                              group["photo"],
                              "",
                              "group",
                              phoneID: group["id"],
                            ),
                            0,
                            0,
                            group["id"],
                            true,
                          ),
                          backgroundURL: "",
                          idUesr: "idUesr",
                          idChat: "null",
                          phoneID: "/topics/${group["id"]}",
                          users: users,
                        ),
                      ));
                    },
                    uesr: NewUesr(
                      "",
                      group["name"],
                      group["photo"],
                      "",
                      "group",
                      phoneID: "",
                    ),
                  ),
            ],
          );
        } else if (snapshot.hasError) {
          return const Icon(Icons.error_outline_rounded);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Icon(Icons.refresh);
        } else {
          return const Icon(Icons.error_outline_rounded);
        }
      },
    );
  }
}
