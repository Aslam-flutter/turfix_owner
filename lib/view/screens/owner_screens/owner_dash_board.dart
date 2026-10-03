import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/view/screens/owner_screens/add_turf_screen.dart';
import 'package:turfix_owner/view_model/common_provider.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommonProvider>();
    final now = DateTime.now();

    final todayStart = DateTime(now.year, now.month, now.day);

    final tomorrowStart = todayStart.add(const Duration(days: 1));

    const primary = Color(0xff16A34A);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Owner is not logged in')),
      );
    }

    final ownerId = user.uid;

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
          "Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('bookings')
              .where('turfOwnerId', isEqualTo: ownerId)
              .get(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (asyncSnapshot.hasError) {
              return Center(child: Text('Error: ${asyncSnapshot.error}'));
            }

            if (!asyncSnapshot.hasData) {
              return const Center(child: Text('No booking details'));
            }

            final data = asyncSnapshot.data!.docs;

            double totalAmount = 0.0;

            for (final booking in data) {
              final amount =
                  (booking.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
              totalAmount += amount;
            }

            // if (data.isEmpty) {
            //   return Center(child: Text('No booking details'));
            // }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Statistics
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.35,
                  children: [
                    StatCard(
                      title: "Total Bookings",
                      value: data.length.toString(),
                      icon: Icons.calendar_month,
                      color: Color(0xff16A34A),
                    ),

                    StatCard(
                      title: "Revenue",
                      value: '₹ ${totalAmount.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.orange,
                    ),

                    // StatCard(
                    //   title: "Upcoming Bookings",
                    //   value: "8",
                    //   icon: Icons.schedule,
                    //   color: Colors.blue,
                    // ),

                    // StatCard(
                    //   title: "Cancelled",
                    //   value: "3",
                    //   icon: Icons.cancel,
                    //   color: Colors.red,
                    // ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  "Bookings",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('turfOwnerId', isEqualTo: ownerId)
                      .snapshots(),

                  builder: (context, snapshot) {
                    // Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Error
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // No data
                    if (!snapshot.hasData) {
                      return const Text('No booking details');
                    }

                    final allBookings = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allBookings.length < 10
                          ? allBookings.length
                          : 10,
                      itemBuilder: (context, index) {
                        final booking = allBookings[index].data();

                        // -------------------------
                        // Booking details
                        // -------------------------

                        final customerName =
                            booking['customerName']?.toString() ??
                            'Unknown Customer';

                        final sport =
                            booking['sport']?.toString() ?? 'Unknown Sport';

                        final status = provider.getDisplayStatus(booking);

                        // -------------------------
                        // Status color
                        // -------------------------

                        Color statusColor;

                        switch (status) {
                          case 'Confirmed':
                            statusColor = Colors.orange;
                            break;

                          case 'Playing':
                            statusColor = Colors.green;
                            break;

                          case 'Completed':
                            statusColor = Colors.grey;
                            break;

                          default:
                            statusColor = Colors.grey;
                        }

                        // -------------------------
                        // Booking time
                        // -------------------------

                        String time = 'Time unavailable';

                        if (booking['startAt'] is Timestamp &&
                            booking['endAt'] is Timestamp) {
                          final startAt = (booking['startAt'] as Timestamp)
                              .toDate();

                          final endAt = (booking['endAt'] as Timestamp)
                              .toDate();

                          time =
                              '${DateFormat('hh:mm a').format(startAt)} - '
                              '${DateFormat('hh:mm a').format(endAt)}';
                        }

                        // -------------------------
                        // Booking created time
                        // -------------------------

                        String bookedAt = '';

                        if (booking['createdAt'] is Timestamp) {
                          final createdAt = (booking['createdAt'] as Timestamp)
                              .toDate();

                          bookedAt = DateFormat(
                            'd MMM • hh:mm a',
                          ).format(createdAt);
                        }

                        // -------------------------
                        // UI
                        // -------------------------

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Customer icon
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(
                                  0xff16A34A,
                                ).withValues(alpha: .12),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xff16A34A),
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Booking information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.sports,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          sport,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 5),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (bookedAt.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        'Booked $bookedAt',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Status
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTurfScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Turf", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color, size: 20),
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class BookingTile extends StatelessWidget {
  final String customer;
  final String sport;
  final String time;
  final String status;

  const BookingTile({
    super.key,
    required this.customer,
    required this.sport,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (status) {
      case "Completed":
        statusColor = Colors.green;
        break;
      case "Cancelled":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xff16A34A).withValues(alpha: .12),
            child: const Icon(Icons.person, color: Color(0xff16A34A)),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(sport, style: TextStyle(color: Colors.grey.shade600)),

                const SizedBox(height: 4),

                Text(
                  time,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
