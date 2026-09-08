import 'package:flutter/material.dart';
import 'package:turfix_owner/view/screens/owner_screens/earnings_chart_screen.dart';

class EarningsGraphScreen extends StatelessWidget {
  const EarningsGraphScreen({super.key});

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
          "Earnings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          /// Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: "This Week",
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "Today", child: Text("Today")),
                  DropdownMenuItem(
                    value: "This Week",
                    child: Text("This Week"),
                  ),
                  DropdownMenuItem(
                    value: "This Month",
                    child: Text("This Month"),
                  ),
                  DropdownMenuItem(
                    value: "This Year",
                    child: Text("This Year"),
                  ),
                ],
                onChanged: (value) {},
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// Revenue Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Revenue",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),

                const SizedBox(height: 8),

                const Text(
                  "₹30,800",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                /// Graph
                const SizedBox(height: 220, child: EarningsChart()),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: statsCard(
                  title: "Bookings",
                  value: "32",
                  icon: Icons.calendar_month,
                  color: primary,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: statsCard(
                  title: "Avg / Booking",
                  value: "₹1200",
                  icon: Icons.currency_rupee,
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: statsCard(
                  title: "Highest Day",
                  value: "₹7600",
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: statsCard(
                  title: "Lowest Day",
                  value: "₹1800",
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget statsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
