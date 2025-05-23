// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math' as math;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/tools.dart';
import '../widgets/animated_home.dart';
import 'amber.dart';

class LogAndSign extends StatefulWidget {
  const LogAndSign({super.key});

  @override
  State<LogAndSign> createState() => _LogAndSignState();
}

class _LogAndSignState extends State<LogAndSign>
    with Tools, SingleTickerProviderStateMixin {
// Variable -------------------------------------------------------------------
  //momen salah / momensalah1223@gmail.com / fox122memo.com
  late UserCredential userCredential;
  final GlobalKey<FormState> formState = GlobalKey();
  final CollectionReference users =
      FirebaseFirestore.instance.collection("uesrs");
  double index = 0;
  String name = "", email = "", password = "";

// Log In ---------------------------------------------------------------------
  void logIn(bool isRefresh) async {
    setState(() => index = 0);

    FormState? formData = formState.currentState;

    if (formData!.validate()) {
      try {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await users
            .where("email", isEqualTo: email)
            .limit(1)
            .get()
            .then((value) {
          final User user = FirebaseAuth.instance.currentUser!;
          user.updateDisplayName(value.docs.first["name"]);
          user.updatePhotoURL(value.docs.first["photoURL"]);
        });
        isRefresh ? refresh() : Navigator.of(context).pop();
        goodDisplayVoid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          error("No user found for that email.").show();
        } else if (e.code == 'wrong-password') {
          error("Wrong password provided for that user.").show();
        } else {
          error("${e.message}.").show();
        }
      } catch (e) {
        error("$e.").show();
      }
    }
  }

// Sign Up --------------------------------------------------------------------
  void signUp() async {
    setState(() => index = 0);
    FormState? formData = formState.currentState;
    if (formData!.validate()) {
      formData.save();
      try {
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        users.add({
          "ID":
              "D${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}R${math.Random.secure().nextInt(10000)}",
          "backgroundURL": "",
          "phoneID": "",
          "email": email,
          "name": name,
          "photoURL": "null",
          "time": DateTime.now(),
        });
        final User user = FirebaseAuth.instance.currentUser!;
        user.updateDisplayName(name);
        refresh();
        goodDisplayVoid;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          error("The password provided is too weak.").show();
        } else if (e.code == 'email-already-in-use') {
          error("The account already exists for that email.").show();
        } else {
          error("${e.message}.").show();
        }
      } catch (e) {
        error("$e.").show();
      }
    }
  }

// Google ---------------------------------------------------------------------
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void google() async {
    try {
      userCredential = await signInWithGoogle();
      final User user = FirebaseAuth.instance.currentUser!;
      await users
          .where("email", isEqualTo: user.email)
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isEmpty) {
          users.add({
            "ID":
                "D${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}R${math.Random.secure().nextInt(10000)}",
            "backgroundURL": "",
            "phoneID": "",
            "email": user.email,
            "name": user.displayName,
            "photoURL": user.photoURL,
            "time": DateTime.now(),
          });
        } else {
          user.updateDisplayName(value.docs.first["name"]);
          user.updatePhotoURL(value.docs.first["photoURL"]);
        }
      });
      goodDisplayVoid;
    } catch (e) {
      error("$e").show();
    }
  }

// Refresh --------------------------------------------------------------------
  void refresh() async {
    if (!(userCredential.user!.emailVerified)) {
      User? user = FirebaseAuth.instance.currentUser;
      await user!.sendEmailVerification();
    }
  }

// Is Log In ------------------------------------------------------------------

// Open Home ------------------------------------------------------------------
  void get goodDisplayVoid {
    if (!(userCredential.user!.emailVerified)) {
      dialog(
        context,
        onPressed: () => logIn(false),
        text: "Good",
        cancelOnPressed: refresh,
        cancelText: "Refresh Message",
        title: "Verify your Identity",
        child: const Text(
          "Send a message to your Email, Click on the Url to confirm your identity.",
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const Amber(),
      ));
    }
  }

// validator In log In And Sign Up --------------------------------------------
  String? validatorEmail(String? value) {
    if (value == null || value == "") {
      setState(() => index++);
      return "There is no Email.";
    } else if ((value.contains(" "))) {
      setState(() => index++);
      return "Remove the space from the email.";
    } else if (!(value.contains("@"))) {
      setState(() => index++);
      return "Please enter a valid email.";
    } else {
      return null;
    }
  }

  String? validatorPassword(String? value) {
    if (value == null || value == "") {
      setState(() => index++);
      return "There is no password.";
    } else if (value.length > 32) {
      setState(() => index++);
      return "Your password can't to do larger than 32 letter.";
    } else if (value.length < 5) {
      setState(() => index++);
      return "Your password can't to do less than 5 letter.";
    } else {
      return null;
    }
  }

  String? validatorName(String? value) {
    if (value == null || value == "") {
      setState(() => index++);
      return "There is no name.";
    } else if (value.length > 32) {
      setState(() => index++);
      return "Your name can't to do larger than 32 letter.";
    } else if (value.length < 3) {
      setState(() => index++);
      return "Your name can't to do less than 5 letter.";
    } else {
      return null;
    }
  }
// animation ------------------------------------------------------------------

  late Animation<double> animation;
  late AnimationController controller;
  bool isLogIn = true;
  bool isLogInGood = true;
  void isLogInVoid() {
    controller.reverse();
    setState(() => isLogIn = !isLogIn);
    Timer(const Duration(milliseconds: 230), () async {
      setState(() => isLogInGood = !isLogInGood);
      controller.forward();
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    controller.forward();
    super.initState();
  }

// Widget ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            const SizedBox(height: 80),
            logInAndSignUp(),
            googleButton(),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

// log In And Sign Up ---------------------------------------------------------
  Stack logInAndSignUp() {
    return Stack(alignment: Alignment.center, children: [
// Background Color -----------------------------------------------------------
      Container(
        height: 71 * 3 + 16 + 22.5 * index,
        margin: const EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 66),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
// Is Log In Button -----------------------------------------------------------
      Positioned(
        bottom: 14,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isLogInButton(text: "Log In"),
            const SizedBox(width: 16),
            isLogInButton(text: "Sign Up"),
          ],
        ),
      ),
// Log In Or Sign Up Button ---------------------------------------------------
      AnimatedHome(
        isLogIn: isLogIn,
        child: logInOrSignUp(
          onPressed: isLogIn ? () => logIn(true) : signUp,
          text: isLogInGood ? "Log In" : "Sign Up",
        ),
      ),
// Log In Or Sign Up Button ---------------------------------------------------
      Container(
        height: 71 * 3 + 22.5 * index + 16,
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 66),
        padding: const EdgeInsets.all(8),
        child: Form(
          key: formState,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            textField(
              "Email",
              validator: validatorEmail,
              onChanged: (v) => email = v,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            textField(
              "Password",
              validator: validatorPassword,
              onChanged: (v) => password = v,
              icon: Icons.password_rounded,
              keyboardType: TextInputType.visiblePassword,
            ),
            if (!isLogIn) const SizedBox(height: 8),
            if (!isLogIn)
              textField(
                "Name",
                validator: validatorName,
                onChanged: (v) => name = v,
                icon: Icons.person,
              ),
          ]),
        ),
      ),
    ]);
  }

// Google Button --------------------------------------------------------------
  IconButton googleButton() {
    return IconButton(
      onPressed: google,
      icon: Card(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset("assets/images/Google.png", height: 36),
        ),
      ),
    );
  }

// Widget Text Field ----------------------------------------------------------
  TextFormField textField(
    String hintText, {
    required void Function(String) onChanged,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      obscureText:
          (keyboardType == TextInputType.visiblePassword) ? true : false,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        errorMaxLines: 1,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        labelText: hintText,
        hintText: 'Enter Your $hintText',
      ),
    );
  }

// Is Log In Button -----------------------------------------------------------
  ElevatedButton isLogInButton({
    required String text,
  }) {
    return ElevatedButton(
      onPressed: isLogInVoid,
      style: ButtonStyle(
        elevation: const MaterialStatePropertyAll(0),
        backgroundColor: MaterialStatePropertyAll(Colors.grey.shade200),
      ),
      child: Container(
        width: 50,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

// Log In Or Sign Up ----------------------------------------------------------
  ElevatedButton logInOrSignUp({
    required void Function() onPressed,
    required String text,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        width: 50,
        height: 40,
        alignment: Alignment.center,
        child: SuperText(
          text: text,
          animation: animation,
        ),
      ),
    );
  }

// Error ----------------------------------------------------------------------
  AwesomeDialog error(String e) => AwesomeDialog(
        context: context,
        title: "Error",
        body: Text("$e\n", textAlign: TextAlign.center),
      );
}

class SuperText extends StatelessWidget {
  const SuperText({
    super.key,
    required this.text,
    required this.animation,
  });

  final String text;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromRGBO(129, 115, 67, animation.value / 100),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
