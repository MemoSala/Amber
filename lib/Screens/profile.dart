import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/new.dart';
import '../widgets/image_profile.dart';
import '../widgets/all_message.dart';
import 'edit_profile.dart';
import 'image.dart';
import 'log_and_sign.dart';

class Profile extends StatelessWidget {
  const Profile(
      {super.key,
      required this.user,
      required this.friends,
      required this.uesrs});
  final NewUesr user;
  final List<String> friends;
  final List<NewUesr> uesrs;

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> notesData =
        FirebaseFirestore.instance.collection("notes");
    final User myUser = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () async =>
                // الخروج من الحساب
                await FirebaseAuth.instance.signOut().then(
                      // الانتقال الى صفحة تسجيل الدخول
                      (value) => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LogAndSign()),
                      ),
                    ),
            icon: const Icon(Icons.exit_to_app_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            Container(
              width: double.infinity,
              height: 150,
              color: Colors.black12,
              child: user.backgroundURL == ""
                  ? null
                  : Image.network(
                      user.backgroundURL,
                      fit: BoxFit.cover,
                    ),
            ),
            Row(children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 100.0,
                  bottom: 12,
                  right: 12,
                  left: 12,
                ),
                child: ImageProfile(
                  photoURL: user.photoURL,
                  sizeImeage: 100,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 150.0,
                    bottom: 12,
                  ),
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (user.id != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 150.0,
                    right: 8,
                    left: 8,
                    bottom: 12,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => EditProfile(user: user)),
                    ),
                    icon: const Icon(Icons.edit_square),
                  ),
                ),
            ]),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                if (user.idUesr == "amber" &&
                    myUser.email == "mooosalah1223@gmail.com")
                  const FolderImage(refImage: "image"),
                FolderImage(refImage: user.email),
              ]),
            ),
          ),
          StreamBuilder(
            stream: notesData
                .orderBy("time", descending: true)
                .where("email", isEqualTo: user.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AllMessage(
                  uesrs: uesrs,
                  keyProfile: false,
                  friends: friends,
                  notes: snapshot.data!.docs
                      .map((element) => NewNote(
                            NewUesr(
                              user.email,
                              user.name,
                              user.photoURL,
                              user.backgroundURL,
                              user.idUesr,
                              phoneID: user.phoneID,
                            ),
                            element["title"],
                            element["description"],
                            element["img"],
                            element.id,
                            isMyFriends: user.email == myUser.email ||
                                    element["isPublic"]
                                ? true
                                : friends.any((friend) => friend == user.email),
                          ))
                      .toList(),
                );
              } else if (snapshot.hasError) {
                return const Icon(Icons.error_outline_rounded);
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              } else {
                return const Icon(Icons.error_outline_rounded);
              }
            },
          ),
        ]),
      ),
    );
  }
}

class FolderImage extends StatefulWidget {
  const FolderImage({super.key, required this.refImage});

  final String refImage;

  @override
  State<FolderImage> createState() => _FolderImageState();
}

class _FolderImageState extends State<FolderImage> {
  List<String> imagesUrl = [];
  bool keyOpen = false;
  List<String> listRefImage = [];

  @override
  void initState() {
    getImages();
    super.initState();
  }

  getImages() async {
    setState(() => keyOpen = false);
    String refImage = widget.refImage;
    for (var element in listRefImage) {
      refImage += "/$element";
    }
    ListResult ref = await FirebaseStorage.instance
        .ref(refImage)
        .list(const ListOptions(maxResults: 4));
    for (Reference item in ref.items) {
      String url = await item.getDownloadURL();
      setState(() {
        imagesUrl.add(url);
      });
    }
    setState(() => keyOpen = true);
  }

  @override
  Widget build(BuildContext context) {
    Widget? child;
    switch (imagesUrl.length) {
      case 1:
        child = box1();
        break;
      case 2:
        child = box2();
        break;
      case 3:
        child = box3();
        break;
      case 4:
        child = box4();
        break;
    }
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageApp(widget.refImage),
        ),
      ),
      child: Container(
        height: 100,
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child:
            keyOpen ? child : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Container box1() {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imagesUrl[0]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Padding box2() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(imagesUrl[0]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 1),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(imagesUrl[1]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Padding box3() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(children: [
        Container(
          width: 50 - 2.5,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(20),
            ),
            image: DecorationImage(
              image: NetworkImage(imagesUrl[0]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 1),
        Column(children: [
          Container(
            width: 50 - 2.5,
            height: 50 - 2.5,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(imagesUrl[1]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Container(
            width: 50 - 2.5,
            height: 50 - 2.5,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: NetworkImage(imagesUrl[2]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  GridView box4() {
    return GridView(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 50,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      children: [
        for (int i = 0; i < imagesUrl.length; i++)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(i == 0 ? 20 : 0),
                topRight: Radius.circular(i == 1 ? 20 : 0),
                bottomLeft: Radius.circular(i == 2 ? 20 : 0),
                bottomRight: Radius.circular(i == 3 ? 20 : 0),
              ),
              image: DecorationImage(
                image: NetworkImage(imagesUrl[i]),
                fit: BoxFit.cover,
              ),
            ),
          )
      ],
    );
  }
}
