import 'package:flutter/material.dart';

class ManageSlotsPage extends StatelessWidget {
  const ManageSlotsPage({super.key});

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
          "Manage Slots",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add Slot",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          /// Turf Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTwq1O-qC-iZVN_4hkTobZRzKrsWYBbmqrrgls7NwcKUSzQuwJLvMC3xcU&s=10', // Your Image

                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 14),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Green Field Arena",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "20 May 2026",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SlotTile(
            startTime: "06:00 AM",
            endTime: "07:00 AM",
            price: "₹1200",
            isEnabled: false,
            onChanged: (value) {},
          ),

          SlotTile(
            startTime: "07:00 AM",
            endTime: "08:00 AM",
            price: "₹1200",
            isEnabled: true,
            onChanged: (value) {},
          ),

          SlotTile(
            startTime: "08:00 AM",
            endTime: "09:00 AM",
            price: "₹1200",
            isEnabled: false,
            onChanged: (value) {},
          ),

          SlotTile(
            startTime: "09:00 AM",
            endTime: "10:00 AM",
            price: "₹1200",
            isEnabled: true,
            onChanged: (value) {},
          ),

          SlotTile(
            startTime: "10:00 AM",
            endTime: "11:00 AM",
            price: "₹1200",
            isEnabled: true,
            onChanged: (value) {},
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class SlotTile extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String price;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const SlotTile({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            flex: 5,
            child: Text(
              "$startTime - $endTime",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              price,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Switch(
                value: isEnabled,
                activeColor: Colors.white,
                activeTrackColor: primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
