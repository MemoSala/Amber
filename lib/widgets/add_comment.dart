import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/tools.dart';

class AddComment extends StatefulWidget {
  const AddComment({super.key, required this.id});
  final String id;

  @override
  State<AddComment> createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> with Tools {
  late CollectionReference<Map<String, dynamic>> notesData;
  String commentType = "";
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    notesData = FirebaseFirestore.instance
        .collection("notes")
        .doc(widget.id)
        .collection("comment");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => dialog(
        context,
        text: "Ok",
        onPressed: () async => await notesData.add({
          "comment": commentType,
          "email": user.email,
          "time": DateTime.now(),
        }),
        child: TextFormField(
          onChanged: (value) => setState(() => commentType = value),
          maxLines: 10,
          minLines: 1,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Type Comment...',
          ),
        ),
      ),
      icon: const Icon(Icons.chat_rounded),
    );
  }
}
