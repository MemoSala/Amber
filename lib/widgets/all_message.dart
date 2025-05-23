import 'package:flutter/material.dart';

import '../Screens/post_message.dart';
import '../models/new.dart';
import 'message.dart';

class AllMessage extends StatelessWidget {
  const AllMessage({
    super.key,
    required this.notes,
    required this.keyProfile,
    required this.friends,
    required this.uesrs,
  });

  final List<NewNote> notes;
  final bool keyProfile;
  final List<String> friends;
  final List<NewUesr> uesrs;
  // Open User Message Profile --------------------------------------------------
  void openUserMessageProfile(BuildContext context, NewNote note) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PostMessage(
          note: note, keyProfile: keyProfile, friends: friends, uesrs: uesrs),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (NewNote note in notes)
        if (note.isMyFriends)
          InkWell(
            onTap: () => openUserMessageProfile(context, note),
            child: Message(
              note: note,
              keyProfile: keyProfile,
              friends: friends,
              uesrs: uesrs,
            ),
          ),
    ]);
  }
}
