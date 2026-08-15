import 'package:flutter/material.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_booking_details.dart';

class OwnerBookingScreen extends StatelessWidget {
  const OwnerBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // const primary = Color(0xff16A34A);

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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OwnerBookingDetailsScreen(),
                      ),
                    );
                  },
                  child: BookingCard(
                    day: "20",
                    month: "May",
                    year: "2026",
                    customer: "Aslam Muhammed",
                    time: "20 May • 06:00 PM",
                    sport: "Football",
                    duration: "1 Hour",
                    status: "Upcoming",
                  ),
                ),

                SizedBox(height: 16),

                BookingCard(
                  day: "20",
                  month: "May",
                  year: "2026",
                  customer: "Zaid Khan",
                  time: "20 May • 08:00 PM",
                  sport: "Cricket",
                  duration: "2 Hours",
                  status: "Upcoming",
                ),

                SizedBox(height: 16),

                BookingCard(
                  day: "19",
                  month: "May",
                  year: "2026",
                  customer: "Ayaan Ali",
                  time: "19 May • 07:00 PM",
                  sport: "Football",
                  duration: "1 Hour",
                  status: "Completed",
                ),

                SizedBox(height: 16),

                BookingCard(
                  day: "18",
                  month: "May",
                  year: "2026",
                  customer: "Rahul Das",
                  time: "18 May • 05:00 PM",
                  sport: "Badminton",
                  duration: "1 Hour",
                  status: "Cancelled",
                ),

                SizedBox(height: 30),
              ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Date Card
          Container(
            width: 65,
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

                Text(
                  month,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
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
              color: statusColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
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
