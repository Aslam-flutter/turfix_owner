import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/model/auth_model.dart';
import 'package:turfix_owner/view/auth/login_screen.dart';
import 'package:turfix_owner/widgets/dialog_box.dart';
import 'package:turfix_owner/widgets/scaffold_messanger.dart';

class AuthServices {
  Future<UserCredential?> registerOwner(
    AuthModel authmodel, [
    BuildContext? context,
  ]) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: authmodel.email,
        password: authmodel.password,
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (context != null && context.mounted) {
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'An owner account already exists with this email address.';
            break;
          case 'weak-password':
            message = 'Password is too weak. Please use at least 6 characters.';
            break;
          case 'invalid-email':
            message = 'Please enter a valid email address.';
            break;
          case 'network-request-failed':
            message = 'Network error. Please check your internet connection.';
            break;
          default:
            message = e.message ?? 'Registration failed. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      log(e.toString());
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  Future<UserCredential?> loginOwner(
    AuthModel authmodel,
    BuildContext context,
  ) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: authmodel.email,
        password: authmodel.password,
      );
      return cred;
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection.';
          break;

        default:
          message = 'Unable to sign in. Please try again.';
      }

      AppMessenger.customScaffoldMessenger(context, message: message);
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<void> logOut(BuildContext context) async {
    AppDialogs.customAlertBox(
      context,
      title: 'Log Out',
      message: 'Are you sure about to log out',
      buttonText: 'Logout',
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
        AppMessenger.customScaffoldMessenger(
          context,
          message: 'Logged out successfully',
          backgroundColor: Colors.green,
        );
      },
    );
  }
}
