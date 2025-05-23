// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/new.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.user});
  final NewUesr user;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> formState = GlobalKey();
  CollectionReference<Map<String, dynamic>> uesrsData =
      FirebaseFirestore.instance.collection("uesrs");
  final User user = FirebaseAuth.instance.currentUser!;
  late String name, backgroundURL, photoURL;
  File? backgroundFile, photoFile;
  bool keySaved = false;

  @override
  void initState() {
    name = widget.user.name;
    backgroundURL = widget.user.backgroundURL;
    photoURL = widget.user.photoURL;
    super.initState();
  }

  Future<File?> getPhoto(ImageSource imageSource) async {
    XFile? imageXFile = await ImagePicker().pickImage(source: imageSource);
    if (imageXFile != null) return File(imageXFile.path);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() => keySaved = true);
              String? urlbackground, urlphoto;
              if (backgroundFile != null) {
                Reference refStorage = FirebaseStorage.instance.ref(
                    "${user.email}/${path.basename(backgroundFile!.path)}(${math.Random.secure().nextInt(10000)})");
                await refStorage.putFile(backgroundFile!);
                urlbackground = await refStorage.getDownloadURL();
              }
              if (photoFile != null) {
                Reference refStorage = FirebaseStorage.instance.ref(
                    "${user.email}/${path.basename(photoFile!.path)}(${math.Random.secure().nextInt(10000)})");
                await refStorage.putFile(photoFile!);
                urlphoto = await refStorage.getDownloadURL();
              }

              if (urlbackground != null) {
                uesrsData
                    .doc(widget.user.id)
                    .update({"backgroundURL": urlbackground});
              }
              if (urlphoto != null) {
                uesrsData.doc(widget.user.id).update({"photoURL": urlphoto});
                await user.updatePhotoURL(urlphoto);
              }
              await user
                  .updateDisplayName(name)
                  .then((value) => Navigator.of(context).pop());
              setState(() => keySaved = false);
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: keySaved
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textEditProfile("Edit Your Name:"),
                      editName(),
                      textEditProfile("Edit Background:"),
                      editPhoto(
                        height: 60,
                        photoURL: backgroundURL == "" ? null : backgroundURL,
                        file: backgroundFile,
                        onPressed: (file) async {
                          File? newBackgroundFile = await file;
                          if (newBackgroundFile != null) {
                            setState(() => backgroundFile = newBackgroundFile);
                          }
                        },
                      ),
                      textEditProfile("Edit Your Photo:"),
                      editPhoto(
                        width: 100,
                        borderRadius: 50,
                        photoURL: photoURL == "" ? null : photoURL,
                        color: Colors.blue.shade700,
                        child: const Icon(
                          Icons.person,
                          size: 90,
                          color: Colors.white,
                        ),
                        file: photoFile,
                        onPressed: (file) async {
                          File? newPhotoFile = await file;
                          if (newPhotoFile != null) {
                            setState(() => photoFile = newPhotoFile);
                          }
                        },
                      ),
                    ]),
              ),
            ),
    );
  }

  String valueName = "";
  TextEditingController nameTEC = TextEditingController();
  Widget editName() {
    return group(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      Form(
        key: formState,
        child: TextFormField(
          controller: nameTEC,
          validator: (value) {
            if (value == null || value == "") {
              return "    There is no name.";
            } else if (value.length > 32) {
              return "    Your name can't to do larger than 32 letter.";
            } else if (value.length < 3) {
              return "    Your name can't to do less than 5 letter.";
            } else {
              return null;
            }
          },
          onChanged: (value) => setState(() => valueName = value),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                FormState? formData = formState.currentState;

                if (formData!.validate()) {
                  setState(() {
                    name = valueName;
                    valueName = "";
                    nameTEC.clear();
                  });
                }
              },
              icon: const Icon(Icons.save),
            ),
            errorMaxLines: 1,
            prefixIcon: const Icon(Icons.person),
            border: InputBorder.none,
            hintText: 'Enter Your name',
          ),
        ),
      ),
    ]));
  }

  Container editPhoto({
    double height = 100,
    double width = 120,
    double borderRadius = 8,
    Color color = Colors.black12,
    String? photoURL,
    Widget? child,
    File? file,
    required void Function(Future<File?>) onPressed,
  }) {
    return group(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          height: 100,
          width: 120,
          alignment: Alignment.center,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: color,
              image: "$file" == "null"
                  ? "$photoURL" == "null"
                      ? null
                      : DecorationImage(
                          image: NetworkImage(photoURL!),
                          fit: BoxFit.cover,
                        )
                  : DecorationImage(
                      image: FileImage(file!),
                      fit: BoxFit.cover,
                    ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: "$photoURL" != "null" || "$file" != "null" ? null : child,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt_rounded),
          onPressed: () => onPressed(getPhoto(ImageSource.camera)),
        ),
        IconButton(
          icon: const Icon(Icons.add_photo_alternate_outlined),
          onPressed: () => onPressed(getPhoto(ImageSource.gallery)),
        ),
        const SizedBox(),
      ]),
    );
  }

  Padding textEditProfile(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container group(child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
