import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/view/screens/owner_screens/add_turf_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  "Today's Bookings",
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

                    // Today's date
                    final now = DateTime.now();

                    final todayStart = DateTime(now.year, now.month, now.day);

                    final tomorrowStart = todayStart.add(
                      const Duration(days: 1),
                    );

                    // Filter today's bookings
                    final todayBookings = allBookings.where((booking) {
                      final data = booking.data();

                      final timestamp = data['date'];

                      if (timestamp == null || timestamp is! Timestamp) {
                        return false;
                      }

                      final bookingDate = timestamp.toDate();

                      return bookingDate.isAfter(
                            todayStart.subtract(
                              const Duration(milliseconds: 1),
                            ),
                          ) &&
                          bookingDate.isBefore(tomorrowStart);
                    }).toList();

                    // No bookings today
                    if (todayBookings.isEmpty) {
                      return const Text("No today's bookings available");
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayBookings.length,
                      itemBuilder: (context, index) {
                        final data = todayBookings[index].data();
                        Color statusColor;

                        switch ('Completed') {
                          case "Completed":
                            statusColor = Colors.green;
                            break;
                          case "Cancelled":
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.orange;
                        }
                        final booking = data[index].data();
                        if (booking.isEmpty) {
                          return Text('No booking details');
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
                                backgroundColor: const Color(
                                  0xff16A34A,
                                ).withValues(alpha: .12),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xff16A34A),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'aslam',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      'sport',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      '10-12',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'upcoming',
                                  style: TextStyle(
                                    color: statusColor,
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
