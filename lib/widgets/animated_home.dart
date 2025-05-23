// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedHome extends StatelessWidget {
  const AnimatedHome({super.key, required this.isLogIn, required this.child});

  final bool isLogIn;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 216,
        transform: Matrix4.translationValues(
            (isLogIn ? -1 : 1) * (216 / 2 - 50), 0, 0),
        child: Row(
          children: [
            Transform.translate(
              offset: const Offset(-4, -4),
              child: Transform.rotate(
                angle: 0.5 * pi,
                child: container(),
              ),
            ),
            Container(
              height: 58,
              width: 116,
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Center(child: child),
            ),
            container()
          ],
        ),
      ),
    );
  }

  ClipPath container() {
    return ClipPath(
      clipper: MyCustomClipper(),
      child: Container(
        height: 58,
        width: 50,
        color: Colors.amber.shade100,
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()
      ..lineTo(0, 25)
      ..arcToPoint(const Offset(25, 0), radius: const Radius.elliptical(25, 25))
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
