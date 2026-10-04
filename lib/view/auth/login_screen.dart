import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/core/constants/app_constants.dart';
import 'package:turfix_owner/core/services/auth_services.dart';
import 'package:turfix_owner/model/auth_model.dart';
import 'package:turfix_owner/view/auth/register_screen.dart';
import 'package:turfix_owner/view/auth/splash_screen.dart';
import 'package:turfix_owner/view_model/common_provider.dart';
import 'package:turfix_owner/widgets/custom_sized_box.dart';
import 'package:turfix_owner/widgets/scaffold_messanger.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final nameCtr = TextEditingController();
  final numberCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final confirmPasswordCtr = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommonProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Login to continue',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              sh(30),
              Text(
                "Email",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // color: Colors.black54,
                ),
              ),
              sh(6),
              TextFormField(
                controller: emailCtr,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }

                  final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

                  if (!regex.hasMatch(value)) {
                    return 'Enter a valid email';
                  }

                  return null;
                },
              ),
              sh(10),
              Text(
                "Password",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // color: Colors.black54,
                ),
              ),
              sh(6),
              TextFormField(
                controller: passwordCtr,
                obscureText: provider.isObscure,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      provider.obscurePassword();
                    },
                    icon: Icon(
                      provider.isObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }

                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }

                  return null;
                },
              ),
              sh(26),
              MaterialButton(
                height: 60,
                minWidth: double.infinity,
                color: AppConstants.darkGreen,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    provider.load(true);
                    AuthModel authModel = AuthModel(
                      uid: '',
                      name: '',
                      email: emailCtr.text.trim(),
                      phone: '',
                      password: passwordCtr.text.trim(),
                      role: '',
                    );

                    final cred = await AuthServices().loginOwner(
                      authModel,
                      context,
                    );

                    if (cred != null && cred.user != null) {
                      final uid = cred.user!.uid;
                      final doc = await FirebaseFirestore.instance
                          .collection('owners')
                          .doc(uid)
                          .get();

                      if (doc.exists) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthGate(),
                          ),
                          (route) => false,
                        );
                        AppMessenger.customScaffoldMessenger(
                          context,
                          message: 'Login successfull',
                          backgroundColor: Colors.green,
                        );
                      } else {
                        AppMessenger.customScaffoldMessenger(
                          context,
                          message:
                              'Access denied. This account is not registered as a turf owner.',
                        );
                        log('Account is not registered as an owner');
                      }
                    }
                  }
                  provider.load(false);
                },
                child: provider.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              sh(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppConstants.darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
