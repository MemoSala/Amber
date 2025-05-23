import 'package:flutter/material.dart';

import '../models/new.dart';
import 'image_profile.dart';

class ReadDataUser extends StatelessWidget {
  const ReadDataUser({
    super.key,
    required this.uesr,
    this.child,
    this.onTap,
    this.sizeImeage = 50,
    this.icon = Icons.person,
  });

  final IconData icon;
  final NewUesr uesr;
  final Widget? child;
  final double sizeImeage;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
      leading: ImageProfile(
        sizeImeage: sizeImeage,
        photoURL: uesr.photoURL,
        icon: icon,
      ),
      title: Text(
        uesr.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          height: 1.2,
        ),
      ),
      subtitle: uesr.idUesr != "group"
          ? Text(
              "ID: ${uesr.idUesr}",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            )
          : null,
      trailing: child,
    );
  }
}
