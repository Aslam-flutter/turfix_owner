import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turfix_owner/model/earning_model.dart';
import 'package:turfix_owner/view/screens/owner_screens/earnings_chart_screen.dart';

class EarningsGraphScreen extends StatefulWidget {
  const EarningsGraphScreen({super.key});

  @override
  State<EarningsGraphScreen> createState() => _EarningsGraphScreenState();
}

class _EarningsGraphScreenState extends State<EarningsGraphScreen> {
  String _selectedPeriod = "This Week";
  DateTimeRange? _customDateRange;

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff16A34A),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = "Custom Range";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        title: const Text(
          "Earnings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('turfOwnerId', isEqualTo: ownerId)
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

          final allDocs = snapshot.data?.docs ?? [];
          final now = DateTime.now();

          // Filter out cancelled bookings
          final validBookings = allDocs.where((doc) {
            final data = doc.data();
            final status = (data['status'] ?? '').toString().toLowerCase();
            return status != 'cancelled';
          }).toList();

          // Filter by period
          final filteredBookings = validBookings.where((doc) {
            final data = doc.data();
            final ts = data['startAt'] as Timestamp? ??
                data['createdAt'] as Timestamp?;
            if (ts == null) return false;
            final date = ts.toDate();

            switch (_selectedPeriod) {
              case "Today":
                return date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
              case "This Week":
                final weekAgo = now.subtract(const Duration(days: 7));
                return date.isAfter(weekAgo);
              case "This Month":
                return date.year == now.year && date.month == now.month;
              case "This Year":
                return date.year == now.year;
              case "Custom Range":
                if (_customDateRange == null) return true;
                final start = DateTime(
                  _customDateRange!.start.year,
                  _customDateRange!.start.month,
                  _customDateRange!.start.day,
                );
                final end = DateTime(
                  _customDateRange!.end.year,
                  _customDateRange!.end.month,
                  _customDateRange!.end.day,
                  23,
                  59,
                  59,
                );
                return date
                        .isAfter(start.subtract(const Duration(seconds: 1))) &&
                    date.isBefore(end.add(const Duration(seconds: 1)));
              default:
                return true;
            }
          }).toList();

          double totalRevenue = 0.0;
          for (final b in filteredBookings) {
            final amount =
                (b.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
            totalRevenue += amount;
          }

          final int totalCount = filteredBookings.length;
          final double avgPerBooking =
              totalCount > 0 ? totalRevenue / totalCount : 0.0;

          // Prepare chart data
          List<EarningsModel> chartData = [];

          if (_selectedPeriod == "Custom Range" && _customDateRange != null) {
            final daysCount = _customDateRange!.duration.inDays + 1;
            if (daysCount <= 14) {
              final Map<String, double> dayAmounts = {};
              final List<String> labels = [];
              for (int i = 0; i < daysCount; i++) {
                final d = _customDateRange!.start.add(Duration(days: i));
                final label = DateFormat('d MMM').format(d);
                labels.add(label);
                dayAmounts[label] = 0.0;
              }
              for (final b in filteredBookings) {
                final ts = b.data()['startAt'] as Timestamp? ??
                    b.data()['createdAt'] as Timestamp?;
                if (ts != null) {
                  final label = DateFormat('d MMM').format(ts.toDate());
                  if (dayAmounts.containsKey(label)) {
                    dayAmounts[label] = (dayAmounts[label] ?? 0.0) +
                        ((b.data()['totalAmount'] as num?)?.toDouble() ?? 0.0);
                  }
                }
              }
              chartData = labels
                  .map((l) =>
                      EarningsModel(day: l, amount: dayAmounts[l] ?? 0.0))
                  .toList();
            } else {
              final bucketDays = (daysCount / 7).ceil();
              for (int i = 0; i < 7; i++) {
                final bStart = _customDateRange!.start
                    .add(Duration(days: i * bucketDays));
                final bEnd = bStart.add(Duration(days: bucketDays));
                final label = DateFormat('d MMM').format(bStart);
                double bTotal = 0.0;
                for (final b in filteredBookings) {
                  final ts = b.data()['startAt'] as Timestamp? ??
                      b.data()['createdAt'] as Timestamp?;
                  if (ts != null) {
                    final d = ts.toDate();
                    if (d.isAfter(bStart.subtract(const Duration(seconds: 1))) &&
                        d.isBefore(bEnd)) {
                      bTotal +=
                          (b.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
                    }
                  }
                }
                chartData.add(EarningsModel(day: label, amount: bTotal));
              }
            }
          } else {
            final List<String> dayNames = [
              "Mon",
              "Tue",
              "Wed",
              "Thu",
              "Fri",
              "Sat",
              "Sun"
            ];
            final Map<String, double> dayAmounts = {
              for (var d in dayNames) d: 0.0,
            };

            for (final b in filteredBookings) {
              final ts = b.data()['startAt'] as Timestamp? ??
                  b.data()['createdAt'] as Timestamp?;
              if (ts != null) {
                final dName = DateFormat('E').format(ts.toDate());
                if (dayAmounts.containsKey(dName)) {
                  dayAmounts[dName] = (dayAmounts[dName] ?? 0.0) +
                      ((b.data()['totalAmount'] as num?)?.toDouble() ?? 0.0);
                }
              }
            }

            chartData = dayNames
                .map((d) =>
                    EarningsModel(day: d, amount: dayAmounts[d] ?? 0.0))
                .toList();
          }

          final highestAmount = chartData.isNotEmpty
              ? chartData.map((e) => e.amount).reduce(max)
              : 0.0;
          final lowestAmount = chartData.isNotEmpty
              ? chartData.map((e) => e.amount).reduce(min)
              : 0.0;

          final periodLabel = _selectedPeriod == "Custom Range" &&
                  _customDateRange != null
              ? "${DateFormat('d MMM').format(_customDateRange!.start)} – ${DateFormat('d MMM yyyy').format(_customDateRange!.end)}"
              : _selectedPeriod;

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              /// Filter dropdown & Custom Date Trigger
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: "Today", child: Text("Today")),
                      DropdownMenuItem(
                          value: "This Week", child: Text("This Week")),
                      DropdownMenuItem(
                          value: "This Month", child: Text("This Month")),
                      DropdownMenuItem(
                          value: "This Year", child: Text("This Year")),
                      DropdownMenuItem(
                        value: "Custom Range",
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month,
                                size: 18, color: Color(0xff16A34A)),
                            SizedBox(width: 8),
                            Text("Custom Date Range..."),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        if (value == "Custom Range") {
                          _pickCustomDateRange();
                        } else {
                          setState(() {
                            _selectedPeriod = value;
                          });
                        }
                      }
                    },
                  ),
                ),
              ),

              if (_selectedPeriod == "Custom Range") ...[
                InkWell(
                  onTap: _pickCustomDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.date_range,
                                color: primary, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _customDateRange != null
                                  ? "${DateFormat('d MMM yyyy').format(_customDateRange!.start)}  –  ${DateFormat('d MMM yyyy').format(_customDateRange!.end)}"
                                  : "Tap to pick date range",
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.edit_calendar,
                            size: 16, color: primary),
                      ],
                    ),
                  ),
                ),
              ],

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
                      "Total Revenue ($periodLabel)",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹${totalRevenue.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    /// Graph
                    SizedBox(
                      height: 220,
                      child: EarningsChart(earnings: chartData),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: statsCard(
                      title: "Bookings",
                      value: totalCount.toString(),
                      icon: Icons.calendar_month,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: statsCard(
                      title: "Avg / Booking",
                      value: "₹${avgPerBooking.toStringAsFixed(0)}",
                      icon: Icons.currency_rupee,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: statsCard(
                      title: "Peak Day",
                      value: "₹${highestAmount.toStringAsFixed(0)}",
                      icon: Icons.trending_up,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: statsCard(
                      title: "Lowest Day",
                      value: "₹${lowestAmount.toStringAsFixed(0)}",
                      icon: Icons.trending_down,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
