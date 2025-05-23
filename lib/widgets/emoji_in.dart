import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmojiIn extends StatelessWidget {
  const EmojiIn({super.key, required this.notesData, this.size, this.color});
  final CollectionReference<Map<String, dynamic>> notesData;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: notesData.snapshots(),
      builder: (context, snapshot) {
        String emojis = "";
        if (snapshot.hasData) {
          List emojiT = ["👍", "❤️", "😂", "😮", "😢", "😠"];
          List<int> emojiN = [0, 0, 0, 0, 0, 0];
          for (var element in snapshot.data!.docs) {
            for (var i = 0; i < emojiT.length; i++) {
              if (element["emoji"] == emojiT[i]) {
                emojiN[i]++;
                break;
              }
            }
          }
          for (var i = 0; i < emojiT.length; i++) {
            if (emojiN[i] != 0) emojis += " ${emojiT[i]} ${emojiN[i]}   ";
          }
          return Text(
            "${emojis.isNotEmpty ? " " : ""}$emojis",
            style: TextStyle(fontSize: size, color: color),
          );
        } else if (snapshot.hasError) {
          return const SizedBox();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else {
          return const Icon(Icons.error_outline_rounded);
        }
      },
    );
  }
}
