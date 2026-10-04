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

    // Not logged in
    if (owner == null) {
      return LoginScreen();
    }

    // Get owner document
    final doc = await FirebaseFirestore.instance
        .collection('owners')
        .doc(owner.uid)
        .get();

    // Owner document doesn't exist
    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();
      return LoginScreen();
    }

    final data = doc.data();

    // Get acceptance status
    final int isAccepted = (data?['isAccepted'] as num?)?.toInt() ?? 0;

    // Accepted
    if (isAccepted == 1) {
      return OwnerMainScreen();
    }

    // Pending
    if (isAccepted == 0) {
      return const OwnerPendingScreen();
    }

    // Rejected
    if (isAccepted == -1) {
      await FirebaseAuth.instance.signOut();
      return const OwnerRejectedScreen();
    }

    // Unknown value
    await FirebaseAuth.instance.signOut();
    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: authGate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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

class OwnerPendingScreen extends StatelessWidget {
  const OwnerPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top_rounded, size: 70, color: Colors.orange),

              const SizedBox(height: 20),

              const Text(
                'Approval Pending',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                'Your owner account has been created successfully. '
                'Please wait until the admin approves your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerRejectedScreen extends StatelessWidget {
  const OwnerRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined, size: 70, color: Colors.red),

              const SizedBox(height: 20),

              const Text(
                'Account Rejected',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                'Unfortunately, your owner account was not approved by the admin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
