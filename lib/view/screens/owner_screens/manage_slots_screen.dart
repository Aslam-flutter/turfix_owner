import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageSlotsPage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> turfDoc;

  const ManageSlotsPage({super.key, required this.turfDoc});

  @override
  State<ManageSlotsPage> createState() => _ManageSlotsPageState();
}

class _ManageSlotsPageState extends State<ManageSlotsPage> {
  late DateTime _selectedDate;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  String _formatDateId(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(' ');
      final timePart = parts[0];
      final period = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
      final timeParts = timePart.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }
      if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 6, minute: 0);
    }
  }

  Future<void> _generateSlotsForDate(
    DateTime date,
    String openingStr,
    String closingStr,
    double price,
  ) async {
    setState(() => _isGenerating = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final dateId = _formatDateId(date);

      final dateRef = firestore
          .collection('turfs')
          .doc(widget.turfDoc.id)
          .collection('slots')
          .doc(dateId);

      await dateRef.set({
        'date': Timestamp.fromDate(date),
      }, SetOptions(merge: true));

      final opening = _parseTime(openingStr);
      final closing = _parseTime(closingStr);

      DateTime start = DateTime(
        date.year,
        date.month,
        date.day,
        opening.hour,
        opening.minute,
      );

      final closingDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        closing.hour,
        closing.minute,
      );

      final batch = firestore.batch();
      int count = 0;

      while (start.isBefore(closingDateTime)) {
        final end = start.add(const Duration(hours: 1));
        if (end.isAfter(closingDateTime)) break;

        final slotId =
            '${start.hour.toString().padLeft(2, '0')}-'
            '${start.minute.toString().padLeft(2, '0')}';

        final slotRef = dateRef.collection('times').doc(slotId);

        batch.set(
          slotRef,
          {
            'startAt': Timestamp.fromDate(start),
            'endAt': Timestamp.fromDate(end),
            'price': price,
            'status': 'available',
            'bookingId': null,
          },
          SetOptions(merge: true),
        );

        count++;
        start = end;
      }

      if (count > 0) {
        await batch.commit();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$count slots initialized successfully'),
            backgroundColor: const Color(0xff16A34A),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize slots: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _toggleSlotStatus(DocumentReference slotRef, bool enable) async {
    try {
      await slotRef.update({
        'status': enable ? 'available' : 'blocked',
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update slot: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);
    final data = widget.turfDoc.data() ?? {};

    final turfName = data['turfName']?.toString() ?? 'Turf';
    final location = data['location']?.toString() ?? '';
    final openingTime = data['openingTime']?.toString() ?? '06:00 AM';
    final closingTime = data['closingTime']?.toString() ?? '11:00 PM';
    final pricePerHour = (data['pricePerHour'] as num?)?.toDouble() ?? 1000.0;

    final List<dynamic> images =
        data['turfImages'] is List ? data['turfImages'] : [];
    final String imageUrl = images.isNotEmpty ? images.first.toString() : '';

    final dateId = _formatDateId(_selectedDate);

    // List of next 14 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysList = List.generate(14, (i) => today.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          "Manage Slots",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Turf Info Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.stadium, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.stadium, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 2),
                      Text(
                        location.isNotEmpty ? location : "₹${pricePerHour.toStringAsFixed(0)} /hour",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date Picker Bar
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: daysList.length,
              itemBuilder: (context, index) {
                final date = daysList[index];
                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? primary : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Slots List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('turfs')
                  .doc(widget.turfDoc.id)
                  .collection('slots')
                  .doc(dateId)
                  .collection('times')
                  .orderBy('startAt')
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

                final slotDocs = snapshot.data?.docs ?? [];

                if (slotDocs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No slots initialized for ${DateFormat('d MMMM yyyy').format(_selectedDate)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _isGenerating
                                ? null
                                : () => _generateSlotsForDate(
                                      _selectedDate,
                                      openingTime,
                                      closingTime,
                                      pricePerHour,
                                    ),
                            icon: _isGenerating
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add, color: Colors.white),
                            label: Text(
                              _isGenerating ? "Generating..." : "Generate Day Slots",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slotDocs.length,
                  itemBuilder: (context, index) {
                    final slotDoc = slotDocs[index];
                    final slot = slotDoc.data();

                    String timeString = slotDoc.id;
                    if (slot['startAt'] is Timestamp &&
                        slot['endAt'] is Timestamp) {
                      final start = (slot['startAt'] as Timestamp).toDate();
                      final end = (slot['endAt'] as Timestamp).toDate();
                      timeString =
                          '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}';
                    }

                    final price = (slot['price'] as num?)?.toDouble() ?? pricePerHour;
                    final status = (slot['status'] ?? 'available').toString().toLowerCase();

                    final isBooked = status == 'booked';
                    final isEnabled = status == 'available';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  timeString,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (isBooked)
                                  const Text(
                                    "Booked by customer",
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else if (!isEnabled)
                                  Text(
                                    "Blocked / Inactive",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "₹${price.toStringAsFixed(0)}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isEnabled ? primary : Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: isBooked
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: .15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        "Booked",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    )
                                  : Switch(
                                      value: isEnabled,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: primary,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.grey.shade300,
                                      onChanged: (val) {
                                        _toggleSlotStatus(slotDoc.reference, val);
                                      },
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
          ),
        ],
      ),
    );
  }
}
