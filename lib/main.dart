import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'Screens/log_and_sign.dart';
import 'Screens/amber.dart';

Future backgroundMessage(RemoteMessage remoteMessage) async {
  print("------------------------- Notification -------------------------");
  print(remoteMessage.notification!.title);
  print(remoteMessage.notification!.body);
  print("----------------------------------------------------------------");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(backgroundMessage);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amber',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 234, 195, 43),
        ),
        scaffoldBackgroundColor: Colors.amber.shade50,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amberAccent),
        useMaterial3: true,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? const LogAndSign()
          : FirebaseAuth.instance.currentUser!.emailVerified
              ? const Amber()
              : const LogAndSign(),
    );
  }
}
