// ignore_for_file: depend_on_referenced_packages, unnecessary_null_comparison

import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/new.dart';

class EditMessage extends StatefulWidget {
  const EditMessage({super.key, required this.note});
  final NewNote note;

  @override
  State<EditMessage> createState() => _EditMessageState();
}

class _EditMessageState extends State<EditMessage> {
  final GlobalKey<FormState> formState = GlobalKey();
  late String title, description, photoURL;
  CollectionReference<Map<String, dynamic>> notesData =
      FirebaseFirestore.instance.collection("notes");
  TextEditingController titleTEC = TextEditingController(),
      descriptionTEC = TextEditingController();
  String valueTitle = "", valueDescription = "";
  File? photoFile;
  bool keySaved = false;

  @override
  void initState() {
    title = widget.note.title;
    description = widget.note.description;
    photoURL = widget.note.photoURL.isEmpty ? "" : widget.note.photoURL[0];
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
              String? urlphoto;
              setState(() => keySaved = true);
              if (photoFile != null) {
                Reference refStorage = FirebaseStorage.instance.ref(
                    "${widget.note.uesr.email}/${path.basename(photoFile!.path)}(${math.Random.secure().nextInt(10000)})");
                await refStorage.putFile(photoFile!);
                urlphoto = await refStorage.getDownloadURL();
              }
              notesData.doc(widget.note.id).update({
                "img": urlphoto != null
                    ? [urlphoto]
                    : widget.note.photoURL.isEmpty,
                "title": title,
                "description": description,
              }).then((value) {
                Navigator.of(context).pop();
                setState(() => keySaved = false);
              });
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
                      textEditProfile("Edit Your Title:"),
                      editTitle(),
                      textEditProfile("Edit Your Description:"),
                      editDescription(),
                      textEditProfile("Edit Photo:"),
                      editPhoto(),
                    ]),
              ),
            ),
    );
  }

  Widget editTitle() {
    return Form(
        key: formState,
        child: group(
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextFormField(
            controller: titleTEC,
            validator: (value) {
              if (value == null || value == "") {
                return "    There is no Title.";
              } else {
                return null;
              }
            },
            onChanged: (value) => setState(() => valueTitle = value),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  FormState? formData = formState.currentState;
                  if (formData!.validate()) {
                    setState(() {
                      title = valueTitle;
                      valueTitle = "";
                      titleTEC.clear();
                    });
                  }
                },
                icon: const Icon(Icons.save),
              ),
              errorMaxLines: 1,
              prefixIcon: const Icon(Icons.title),
              border: InputBorder.none,
              hintText: 'Enter Your Title...',
            ),
          ),
        ])));
  }

  Widget editDescription() {
    return group(Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(description, style: const TextStyle(fontSize: 12)),
      TextFormField(
        controller: descriptionTEC,
        onChanged: (value) => setState(() => valueDescription = value),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                description = valueDescription;
                valueDescription = "";
                descriptionTEC.clear();
              });
            },
            icon: const Icon(Icons.save),
          ),
          errorMaxLines: 1,
          border: InputBorder.none,
          hintText: 'Enter Your Description...',
        ),
      ),
    ]));
  }

  Container editPhoto() {
    String? newPhotoURL = photoURL == "" ? null : photoURL;
    void onPressed(Future<File?> file) async {
      File? newPhotoFile = await file;
      if (newPhotoFile != null) {
        setState(() => photoFile = newPhotoFile);
      }
    }

    return group(
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          height: 100,
          width: 120,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              image: "$photoFile" == "null"
                  ? "$newPhotoURL" == "null"
                      ? null
                      : DecorationImage(image: NetworkImage(newPhotoURL!))
                  : DecorationImage(image: FileImage(photoFile!)),
              borderRadius: BorderRadius.circular(8),
            ),
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
