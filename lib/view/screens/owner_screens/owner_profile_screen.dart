import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/core/constants/app_constants.dart';
import 'package:turfix_owner/core/services/auth_services.dart';
import 'package:turfix_owner/view/screens/owner_screens/earning_graph_screen.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          "Owner Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {},
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('owners')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: AppConstants.kHeight(context),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryGreen,
                      ),
                    ),
                  );
                }
                final ownerDetails = asyncSnapshot.data!.data();
                if (ownerDetails == null) {
                  return SizedBox(
                    height: AppConstants.kHeight(context),
                    child: Center(child: Text('No details found')),
                  );
                }
                return Column(
                  children: [
                    const SizedBox(height: 10),

                    /// Profile Image
                    const Center(
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpCLsbe68LGYoFLzWXh2uPqxBXoz3WL8lJF5Lnrwq9hGN765tNG8VSHqP9&s=10",
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: Text(
                        ownerDetails['name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        ownerDetails['phone'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Center(
                      child: Text(
                        ownerDetails['email'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    ProfileMenuTile(
                      icon: Icons.money,
                      title: "Earnings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EarningsGraphScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    ProfileMenuTile(
                      icon: Icons.account_balance_outlined,
                      title: "Bank Details",
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    ProfileMenuTile(
                      icon: Icons.lock_outline,
                      title: "Change Password",
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    ProfileMenuTile(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    ProfileMenuTile(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      onTap: () {},
                    ),

                    const SizedBox(height: 45),

                    OutlinedButton.icon(
                      onPressed: () {
                        AuthServices().logOut(context);
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primary, size: 22),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
