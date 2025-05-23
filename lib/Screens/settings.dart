import 'package:flutter/material.dart';

class SettingsApp extends StatefulWidget {
  const SettingsApp({super.key});

  @override
  State<SettingsApp> createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  Color colorApp = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Settings"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.save_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Color App:"),
            newRadio(Colors.amber),
            newRadio(Colors.grey),
            newRadio(Colors.black),
            newRadio(Colors.red),
            newRadio(Colors.green),
          ]),
        ]),
      ),
    );
  }

  Radio<Color> newRadio(color) {
    return Radio(
      value: color,
      groupValue: colorApp,
      fillColor: MaterialStatePropertyAll(color),
      onChanged: (value) => setState(() => colorApp = value!),
    );
  }
}
