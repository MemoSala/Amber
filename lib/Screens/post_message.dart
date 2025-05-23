import 'package:flutter/material.dart';

import '../models/new.dart';
import '../widgets/message.dart';

class PostMessage extends StatelessWidget {
  const PostMessage({
    super.key,
    required this.note,
    required this.keyProfile,
    required this.friends,
    required this.uesrs,
  });

  final NewNote note;
  final bool keyProfile;
  final List<String> friends;
  final List<NewUesr> uesrs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post")),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Message(
            note: note,
            keyProfile: keyProfile,
            friends: friends,
            isMaxLine: true,
            uesrs: uesrs,
          ),
        ),
      ]),
    );
  }
}
