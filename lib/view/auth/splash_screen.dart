import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/view/auth/login_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthGate()),
        (route) => false,
      );
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/turfix image.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        // child: Image.asset("assets/images/turfixImage.jpeg", fit: BoxFit.cover)
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<Widget> authGate() async {
    final owner = FirebaseAuth.instance.currentUser;
    if (owner == null) {
      return LoginScreen();
    }

    final doc = await FirebaseFirestore.instance
        .collection('owners')
        .doc(owner.uid)
        .get();
    if (doc.exists) {
      return OwnerMainScreen();
    }
    await FirebaseAuth.instance.signOut();
    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: authGate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return LoginScreen();
        }
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        return LoginScreen();
      },
    );
  }
}
