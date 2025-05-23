import 'package:flutter/material.dart';

mixin Tools {
  void dialog(
    BuildContext context, {
    required void Function() onPressed,
    required String text,
    Widget? child,
    String? title,
    void Function()? cancelOnPressed,
    String cancelText = "cancel",
  }) async =>
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Colors.amber.shade50,
          title: title == null ? null : Text(title),
          content: child,
          actionsAlignment: MainAxisAlignment.center,
          actions: <ElevatedButton>[
            _commentButton(
              onPressed: cancelOnPressed ?? () => Navigator.of(context).pop(),
              text: cancelText,
            ),
            _commentButton(
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
              text: text,
            ),
          ],
        ),
      );

  ElevatedButton _commentButton({
    required void Function() onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        width: 50,
        height: 40,
        alignment: Alignment.center,
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
