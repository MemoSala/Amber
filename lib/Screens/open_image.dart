import 'package:flutter/material.dart';

class OpenImage extends StatelessWidget {
  const OpenImage({super.key, required this.imageUrl, required this.imageName});

  final String imageUrl, imageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(imageName)),
      body: Center(child: Image.network(imageUrl)),
    );
  }
}
