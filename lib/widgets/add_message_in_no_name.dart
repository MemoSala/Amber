// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMessageInNoName extends StatefulWidget {
  const AddMessageInNoName({super.key});

  @override
  State<AddMessageInNoName> createState() => _AddMessageInNoNameState();
}

class _AddMessageInNoNameState extends State<AddMessageInNoName> {
  final GlobalKey<FormState> formState = GlobalKey();
  CollectionReference<Map<String, dynamic>> notesData =
      FirebaseFirestore.instance.collection("notes");
  TextEditingController titleTEC = TextEditingController(),
      descriptionTEC = TextEditingController();
  final User user = FirebaseAuth.instance.currentUser!;
  String title = "", description = "";
  bool isPublic = true, isPublish = false;

  File? file;

  void deleteNewMessage() {
    titleTEC.clear();
    descriptionTEC.clear();
    setState(() {
      title = "";
      description = "";
      file = null;
    });
  }

  void uploadPhoto() async {
    XFile? imageXFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageXFile != null) setState(() => file = File(imageXFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.only(right: 8, left: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: isPublish
          ? Container(
              padding: const EdgeInsets.only(top: 8),
              height: 140,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Form(
              key: formState,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: titleTEC,
                    validator: (value) =>
                        value == "" ? "Must be written Title." : null,
                    onChanged: (value) => setState(() => title = value),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 8, bottom: -10),
                      hintText: 'Here you type Title ...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionTEC,
                    minLines: 1,
                    maxLines: 100,
                    onChanged: (value) => setState(() => description = value),
                    maxLength: 2500,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(top: 0, bottom: -10),
                      border: InputBorder.none,
                      hintText: 'Here you type Description ...',
                    ),
                  ),
                  if (file != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          file!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: uploadPhoto,
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                        ),
                      ),
                      IconButton(
                        onPressed: deleteNewMessage,
                        icon: const Icon(Icons.delete),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 40,
                        width: 130,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(247, 242, 242, 1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const <BoxShadow>[
                            BoxShadow(
                              color: Color.fromRGBO(181, 166, 121, 1),
                              offset: Offset(0, 1),
                              blurRadius: 0.8,
                              spreadRadius: -0.2,
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField(
                          dropdownColor: const Color.fromRGBO(247, 242, 242, 1),
                          iconEnabledColor: const Color.fromRGBO(103, 80, 0, 1),
                          value: isPublic,
                          iconSize: 20,
                          onChanged: (value) =>
                              setState(() => isPublic = value),
                          style: const TextStyle(
                            color: Color.fromRGBO(103, 80, 0, 1),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(0),
                          ),
                          items: const <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: true,
                              child: Text("Public"),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text("My Friends"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => isPublish = true);
                          FormState? formData = formState.currentState;
                          if (formData!.validate()) {
                            String? urlPhoto;
                            formState.currentState!.save();
                            if (file != null) {
                              Reference refStorage = FirebaseStorage.instance.ref(
                                  "${user.email}/${basename(file!.path)}(${math.Random.secure().nextInt(10000)})");
                              await refStorage.putFile(file!);
                              urlPhoto = await refStorage.getDownloadURL();
                            }
                            await notesData.add({
                              "description": description,
                              "email": user.email,
                              "isPublic": isPublic,
                              "time": DateTime.now(),
                              'title': title,
                              "img": urlPhoto == null ? [] : [urlPhoto],
                            });
                            deleteNewMessage();
                            setState(() => isPublish = false);
                          }
                        },
                        child: const Text(
                          "Publish",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
