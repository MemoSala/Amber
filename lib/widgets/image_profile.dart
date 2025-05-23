import 'package:flutter/material.dart';

class ImageProfile extends StatelessWidget {
  const ImageProfile({
    super.key,
    required this.sizeImeage,
    required this.photoURL,
    this.icon = Icons.person,
  });

  final IconData icon;
  final double sizeImeage;
  final String photoURL;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: sizeImeage / 2,
      foregroundImage: photoURL != "null" ? NetworkImage(photoURL) : null,
      backgroundColor: Colors.blue.shade700,
      child: Icon(
        icon,
        size: sizeImeage - 10,
        color: Colors.white,
      ),
    );
  }
}
