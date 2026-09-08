import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/core/constants/app_constants.dart';
import 'package:turfix_owner/core/services/firestore_services.dart';
import 'package:turfix_owner/view/screens/owner_screens/add_turf_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_turf_details_screen.dart';
import 'package:turfix_owner/widgets/dialog_box.dart';

class MyTurfsScreen extends StatelessWidget {
  const MyTurfsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);
    final uid = FirebaseAuth.instance.currentUser!.uid;
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
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {},
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('turfs')
              .where('ownerId', isEqualTo: uid)
              .get(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: AppConstants.kHeight(context),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final turfDatas = asyncSnapshot.data!.docs;

            if (turfDatas.isEmpty) {
              return SizedBox(
                height: AppConstants.kHeight(context),
                child: Center(child: Text('No turf details')),
              );
            }
            return ListView.builder(
              itemCount: turfDatas.length,
              itemBuilder: (context, index) {
                final turfDetails = turfDatas[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OwnerTurfDetailsScreen(turfDetail: turfDetails),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
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
                    child: Row(
                      children: [
                        /// Turf Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 14),

                        /// Turf Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                turfDetails['turfName'],
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 15,
                                    color: Colors.grey.shade600,
                                  ),

                                  const SizedBox(width: 4),

                                  Expanded(
                                    child: Text(
                                      turfDetails['location'],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    turfDetails['pricePerHour'].toString(),
                                    style: const TextStyle(
                                      color: primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const Text(
                                    " /hour",
                                    style: TextStyle(color: Colors.grey),
                                  ),

                                  const Spacer(),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: turfDetails['isTurfActive']
                                          ? primary.withValues(alpha: .12)
                                          : Colors.red.withValues(alpha: .12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      turfDetails['isTurfActive']
                                          ? "Active"
                                          : "Inactive",
                                      style: TextStyle(
                                        color: turfDetails['isTurfActive']
                                            ? primary
                                            : Colors.red,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${turfDetails['bookingCount']} bookings',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: primary,
                                      ),
                                      label: const Text(
                                        "Edit",
                                        style: TextStyle(color: primary),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: primary),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        AppDialogs.customAlertBox(
                                          context,
                                          title: 'Delete Turf',
                                          message:
                                              'Are you sure you want to delete this turf? This action cannot be undone.',
                                          buttonText: 'Delete',
                                          onTap: () {
                                            FirestoreServices().deleteTurf(
                                              turfDetails.id,
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
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
                );
              },
            );

            // SizedBox(height: 16),

            // TurfCard(
            //   image:
            //       "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

            //   name: "Kick Off Turf",
            //   location: "Kozhikode, Kerala",
            //   price: "₹1000",
            //   bookings: "25 Bookings This Week",
            //   isActive: true,
            // ),

            // SizedBox(height: 16),

            // TurfCard(
            //   image:
            //       "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10",

            //   name: "Sports Hub Turf",
            //   location: "Kozhikode, Kerala",
            //   price: "₹1400",
            //   bookings: "18 Bookings This Week",
            //   isActive: false,
            // ),

            // SizedBox(height: 100),
            //   ],
            // );
          },
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTurfScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// class TurfCard extends StatelessWidget {
//   final String image;
//   final String name;
//   final String location;
//   final String price;
//   final String bookings;
//   final bool isActive;

//   const TurfCard({
//     super.key,
//     required this.image,
//     required this.name,
//     required this.location,
//     required this.price,
//     required this.bookings,
//     required this.isActive,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const primary = Color(0xff16A34A);

//     return
//   }
// }
