import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_booking_details.dart';
import 'package:turfix_owner/view_model/common_provider.dart';

class OwnerBookingScreen extends StatelessWidget {
  const OwnerBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // const primary = Color(0xff16A34A);
    final ownerId = FirebaseAuth.instance.currentUser!.uid;
    final provider = context.read<CommonProvider>();

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
          "Bookings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          /// Filter Chips
          Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  bookingFilterChip(title: "All", selected: true),

                  const SizedBox(width: 10),

                  bookingFilterChip(title: "Upcoming", selected: false),

                  const SizedBox(width: 10),

                  bookingFilterChip(title: "Completed", selected: false),

                  const SizedBox(width: 10),

                  bookingFilterChip(title: "Cancelled", selected: false),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('turfOwnerId', isEqualTo: ownerId)
                  .snapshots(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (asyncSnapshot.hasError) {
                  return Center(child: Text('Error: ${asyncSnapshot.error}'));
                }

                if (!asyncSnapshot.hasData) {
                  return const Center(child: Text('No data available'));
                }

                final bookingDetails = asyncSnapshot.data!.docs;

                if (bookingDetails.isEmpty) {
                  return const Center(child: Text('No bookings found'));
                }

                return ListView.builder(
                  itemCount: bookingDetails.length,
                  itemBuilder: (context, index) {
                    final booking = bookingDetails[index].data();

                    final Timestamp createdAt = booking['createdAt'];

                    final DateTime dateTime = createdAt.toDate();

                    final String formattedDate = DateFormat(
                      'd MMM • hh:mm a',
                    ).format(dateTime);

                    final int date = dateTime.day;
                    final String month = DateFormat('MMMM').format(dateTime);
                    final int year = dateTime.year;

                    final customer = booking['customerName'];
                    final sport = booking['sport'];

                    final List<String> slotIds = List<String>.from(
                      booking['slotIds'],
                    );

                    final firstSlot = slotIds.first.split('-');
                    final lastSlot = slotIds.last.split('-');

                    final firstTime = DateTime(
                      2026,
                      1,
                      1,
                      int.parse(firstSlot[0]),
                      int.parse(firstSlot[1]),
                    );

                    final lastTime = DateTime(
                      2026,
                      1,
                      1,
                      int.parse(lastSlot[0]),
                      int.parse(lastSlot[1]),
                    );

                    final duration = lastTime.difference(firstTime).inHours;

                    final status = provider.getDisplayStatus(booking);

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

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OwnerBookingDetailsScreen(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          BookingCard(
                            day: date.toString(),
                            month: month,
                            year: year.toString(),
                            customer: customer,
                            time: formattedDate,
                            sport: sport,
                            duration: "$duration Hour",
                            status: status,
                            color: statusColor,
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget bookingFilterChip({required String title, required bool selected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xff16A34A) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? const Color(0xff16A34A) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String day;
  final String month;
  final String year;
  final String customer;
  final String time;
  final String sport;
  final String duration;
  final String status;
  final Color color;

  const BookingCard({
    super.key,
    required this.day,
    required this.month,
    required this.year,
    required this.customer,
    required this.time,
    required this.sport,
    required this.duration,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          /// Date Card
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Center(
                  child: Text(
                    month,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  year,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          /// Booking Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 6),

                Text(
                  "$sport • $duration",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),

          /// Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
