import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/core/services/firestore_services.dart';
import 'package:turfix_owner/view/screens/owner_screens/add_turf_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/edit_turf_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_turf_details_screen.dart';
import 'package:turfix_owner/widgets/dialog_box.dart';

class MyTurfsScreen extends StatelessWidget {
  const MyTurfsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Owner is not logged in')),
      );
    }

    final uid = user.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Turfs",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('turfs')
            .where('ownerId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final turfDatas = snapshot.data?.docs ?? [];

          if (turfDatas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stadium_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No turfs added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your turf ground',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: turfDatas.length,
            itemBuilder: (context, index) {
              final turfDetails = turfDatas[index];
              final data = turfDetails.data();

              final int isVerified =
                  (data['isVerified'] as num?)?.toInt() ?? 0;
              final bool isTurfActive = data['isTurfActive'] ?? false;
              final turfName = data['turfName']?.toString() ?? 'Turf';
              final location = data['location']?.toString() ?? '';
              final pricePerHour = (data['pricePerHour'] as num?)?.toDouble() ?? 0.0;
              final bookingCount = (data['bookingCount'] as num?)?.toInt() ?? 0;

              final List<dynamic> images = data['turfImages'] is List
                  ? data['turfImages']
                  : [];
              final String imageUrl =
                  images.isNotEmpty ? images.first.toString() : '';

              String statusText;
              Color statusColor;

              if (isVerified == 0) {
                statusText = 'Not Verified';
                statusColor = Colors.orange;
              } else if (isVerified == -1) {
                statusText = 'Rejected';
                statusColor = Colors.red;
              } else if (isVerified == 1) {
                if (isTurfActive) {
                  statusText = 'Active';
                  statusColor = primary;
                } else {
                  statusText = 'Inactive';
                  statusColor = Colors.red;
                }
              } else {
                statusText = 'Unknown';
                statusColor = Colors.grey;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OwnerTurfDetailsScreen(turfDetail: turfDetails),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Turf Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _imageFallback(),
                                )
                              : _imageFallback(),
                        ),
                        const SizedBox(width: 14),

                        /// Turf Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                turfName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    "₹${pricePerHour.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    " /hour",
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: .15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '$bookingCount bookings',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditTurfScreen(turfDoc: turfDetails),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: primary,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () {
                                      AppDialogs.customAlertBox(
                                        context,
                                        title: 'Delete Turf',
                                        message:
                                            'Are you sure you want to delete this turf? This action cannot be undone.',
                                        buttonText: 'Delete',
                                        onTap: () async {
                                          Navigator.pop(context);
                                          try {
                                            await FirestoreServices()
                                                .deleteTurf(turfDetails.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Turf deleted successfully'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to delete turf: $e'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTurfScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade200,
      child: const Icon(Icons.stadium, color: Colors.grey, size: 36),
    );
  }
}
