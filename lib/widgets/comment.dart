import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/new.dart';
import 'read_sata_user.dart';

class Comment extends StatefulWidget {
  const Comment({
    super.key,
    required this.id,
    required this.uesrs,
    required this.isMaxLine,
  });
  final String id;
  final List<NewUesr> uesrs;
  final bool isMaxLine;
  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  CollectionReference<Map<String, dynamic>> notesData =
      FirebaseFirestore.instance.collection("notes");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: notesData
          .doc(widget.id)
          .collection("comment")
          .orderBy("time", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int index = 0;
          return Column(
            children: snapshot.data!.docs.map((element) {
              index++;
              if (widget.isMaxLine) {
                return oneComment(element);
              } else {
                if (index < 3) {
                  return oneComment(element);
                } else if (index == 3) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Icon(Icons.keyboard_control),
                  );
                } else {
                  return const SizedBox();
                }
              }
            }).toList(),
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

  Column oneComment(QueryDocumentSnapshot<Map<String, dynamic>> element) {
    NewUesr uesr =
        widget.uesrs.firstWhere((NewUesr e) => e.email == element["email"]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ReadDataUser(uesr: uesr, sizeImeage: 30),
      Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(bottom: 8.0, right: 16.0, left: 16.0),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          element["comment"],
          maxLines: widget.isMaxLine ? 10000 : 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
