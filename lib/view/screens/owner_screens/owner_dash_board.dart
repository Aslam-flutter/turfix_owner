import 'package:flutter/material.dart';
import 'package:turfix_owner/view/screens/owner_screens/add_turf_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "20 May - 26 May",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 22),

            /// Statistics
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.35,
              children: const [
                StatCard(
                  title: "Total Bookings",
                  value: "32",
                  icon: Icons.calendar_month,
                  color: Color(0xff16A34A),
                ),

                StatCard(
                  title: "Revenue",
                  value: "₹38,400",
                  icon: Icons.currency_rupee,
                  color: Colors.orange,
                ),

                StatCard(
                  title: "Upcoming Bookings",
                  value: "8",
                  icon: Icons.schedule,
                  color: Colors.blue,
                ),

                StatCard(
                  title: "Cancelled",
                  value: "3",
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Today's Bookings",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            const BookingTile(
              customer: "Aslam Muhammed",
              sport: "Football",
              time: "06:00 PM - 07:00 PM",
              status: "Upcoming",
            ),

            const SizedBox(height: 14),

            const BookingTile(
              customer: "Zaid Khan",
              sport: "Cricket",
              time: "08:00 PM - 09:00 PM",
              status: "Upcoming",
            ),

            const SizedBox(height: 14),

            const BookingTile(
              customer: "Ameen Ali",
              sport: "Football",
              time: "09:00 PM - 10:00 PM",
              status: "Completed",
            ),

            const SizedBox(height: 14),

            const BookingTile(
              customer: "Rahul Das",
              sport: "Badminton",
              time: "10:00 PM - 11:00 PM",
              status: "Cancelled",
            ),

            const SizedBox(height: 30),
          ],
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
            color: Colors.black.withOpacity(.03),
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
            backgroundColor: color.withOpacity(.12),
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
            color: Colors.black.withOpacity(.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xff16A34A).withOpacity(.12),
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
              color: statusColor.withOpacity(.12),
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
