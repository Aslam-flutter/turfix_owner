import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:turfix_owner/core/services/pdf_report_service.dart';
import 'package:turfix_owner/view/screens/owner_screens/add_turf_screen.dart';
import 'package:turfix_owner/view/screens/owner_screens/owner_booking_details.dart';
import 'package:turfix_owner/view_model/common_provider.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // Time filters: 'all', 'today', 'week', 'month', 'custom'
  String _timeFilter = 'all';
  DateTimeRange? _customDateRange;

  // Category filters: 'All', 'Football', 'Cricket', 'Badminton', etc.
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Football',
    'Cricket',
    'Badminton',
    'Volleyball',
    'Tennis',
  ];

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
        _timeFilter = 'custom';
      });
    }
  }

  String _getActiveFilterLabel() {
    String timeLabel;
    switch (_timeFilter) {
      case 'today':
        timeLabel = 'Today';
        break;
      case 'week':
        timeLabel = 'Past 7 Days';
        break;
      case 'month':
        timeLabel = 'This Month';
        break;
      case 'custom':
        if (_customDateRange != null) {
          timeLabel =
              '${DateFormat('dd MMM').format(_customDateRange!.start)} - ${DateFormat('dd MMM').format(_customDateRange!.end)}';
        } else {
          timeLabel = 'Custom Range';
        }
        break;
      case 'all':
      default:
        timeLabel = 'All Time';
    }

    if (_selectedCategory != 'All') {
      return '$timeLabel ($_selectedCategory)';
    }
    return timeLabel;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allBookings,
  ) {
    final now = DateTime.now();
    return allBookings.where((booking) {
      final data = booking.data();

      // 1. Category Filter
      if (_selectedCategory != 'All') {
        final sport = (data['sport'] ?? '').toString().toLowerCase();
        if (sport != _selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // 2. Date / Month Filter
      final ts = data['startAt'] as Timestamp? ??
          data['createdAt'] as Timestamp?;
      if (ts == null) return true;
      final date = ts.toDate();

      switch (_timeFilter) {
        case 'today':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case 'week':
          final weekAgo = now.subtract(const Duration(days: 7));
          return date.isAfter(weekAgo);
        case 'month':
          return date.year == now.year && date.month == now.month;
        case 'custom':
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
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  void _exportBookingsReport(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings,
  ) {
    if (bookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No bookings to export for selected filter'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double totalRevenue = 0.0;
    for (final b in bookings) {
      final data = b.data();
      final status = (data['status']?.toString() ?? '').toLowerCase();
      if (status != 'cancelled') {
        totalRevenue += (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      }
    }

    final activeFilter = _getActiveFilterLabel();

    // Show PDF export bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.red,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Export Bookings as PDF",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${bookings.length} records • Total: ₹${totalRevenue.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Report Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Active Filter",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff16A34A).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              activeFilter,
                              style: const TextStyle(
                                color: Color(0xff16A34A),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "File Type",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.description, size: 16, color: Colors.red),
                              SizedBox(width: 4),
                              Text(
                                "PDF Document (.pdf)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // DOWNLOAD / SHARE PDF
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      PdfReportService.downloadOrSharePdf(
                        context: context,
                        bookings: bookings,
                        filterLabel: activeFilter,
                      );
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: const Text(
                      "Download / Share PDF",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff16A34A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // PREVIEW & PRINT PDF
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      PdfReportService.previewAndPrintPdf(
                        context: context,
                        bookings: bookings,
                        filterLabel: activeFilter,
                      );
                    },
                    icon: const Icon(Icons.print_rounded, color: Color(0xff16A34A)),
                    label: const Text(
                      "Preview & Print PDF",
                      style: TextStyle(
                        color: Color(0xff16A34A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xff16A34A), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommonProvider>();
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
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('turfOwnerId', isEqualTo: ownerId)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              final filtered = _applyFilters(docs);
              return IconButton(
                tooltip: "Download PDF Report",
                onPressed: () => _exportBookingsReport(filtered),
                icon: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: primary,
                  size: 24,
                ),
              );
            },
          ),
        ],
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

          final allBookings = snapshot.data?.docs ?? [];
          final now = DateTime.now();

          // Apply Category and Date/Month filters
          final filteredBookings = allBookings.where((booking) {
            final data = booking.data();

            // 1. Category Filter
            if (_selectedCategory != 'All') {
              final sport = (data['sport'] ?? '').toString().toLowerCase();
              if (sport != _selectedCategory.toLowerCase()) {
                return false;
              }
            }

            // 2. Date / Month Filter
            final ts = data['startAt'] as Timestamp? ??
                data['createdAt'] as Timestamp?;
            if (ts == null) return true;
            final date = ts.toDate();

            switch (_timeFilter) {
              case 'today':
                return date.year == now.year &&
                    date.month == now.month &&
                    date.day == now.day;
              case 'week':
                final weekAgo = now.subtract(const Duration(days: 7));
                return date.isAfter(weekAgo);
              case 'month':
                return date.year == now.year && date.month == now.month;
              case 'custom':
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
              case 'all':
              default:
                return true;
            }
          }).toList();

          // Sort filtered bookings by createdAt descending
          final sortedBookings =
              List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
            filteredBookings,
          )..sort((a, b) {
              final aTime = a.data()['createdAt'] as Timestamp?;
              final bTime = b.data()['createdAt'] as Timestamp?;
              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime);
            });

          double totalAmount = 0.0;
          int upcomingCount = 0;
          int cancelledCount = 0;

          for (final booking in filteredBookings) {
            final data = booking.data();
            final status = (data['status'] ?? '').toString().toLowerCase();
            final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

            if (status == 'cancelled') {
              cancelledCount++;
            } else {
              totalAmount += amount;
              final startAt = (data['startAt'] as Timestamp?)?.toDate();
              if (startAt != null && startAt.isAfter(now)) {
                upcomingCount++;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------
                // FILTER SECTION: DATE & MONTH FILTERS
                // ----------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.filter_list, size: 18, color: primary),
                          const SizedBox(width: 8),
                          const Text(
                            "Filters",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (_timeFilter != 'all' || _selectedCategory != 'All')
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _timeFilter = 'all';
                                  _selectedCategory = 'All';
                                  _customDateRange = null;
                                });
                              },
                              child: Text(
                                "Reset",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Time Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: "All Time",
                              isSelected: _timeFilter == 'all',
                              onSelected: () => setState(() => _timeFilter = 'all'),
                              primary: primary,
                            ),
                            _buildFilterChip(
                              label: "Today",
                              isSelected: _timeFilter == 'today',
                              onSelected: () =>
                                  setState(() => _timeFilter = 'today'),
                              primary: primary,
                            ),
                            _buildFilterChip(
                              label: "This Week",
                              isSelected: _timeFilter == 'week',
                              onSelected: () =>
                                  setState(() => _timeFilter = 'week'),
                              primary: primary,
                            ),
                            _buildFilterChip(
                              label: "This Month",
                              isSelected: _timeFilter == 'month',
                              onSelected: () =>
                                  setState(() => _timeFilter = 'month'),
                              primary: primary,
                            ),
                            _buildFilterChip(
                              label: _customDateRange != null && _timeFilter == 'custom'
                                  ? "${DateFormat('d MMM').format(_customDateRange!.start)} - ${DateFormat('d MMM').format(_customDateRange!.end)}"
                                  : "Custom Date...",
                              isSelected: _timeFilter == 'custom',
                              icon: Icons.date_range,
                              onSelected: _pickCustomDateRange,
                              primary: primary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      // Category (Sports) Filter Chips
                      Row(
                        children: [
                          const Text(
                            "Category:",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _categories.map((cat) {
                                  final isSel = _selectedCategory == cat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(
                                        cat,
                                        style: TextStyle(
                                          color: isSel ? Colors.white : Colors.black87,
                                          fontSize: 12,
                                          fontWeight: isSel
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      selected: isSel,
                                      selectedColor: primary,
                                      backgroundColor: Colors.grey.shade100,
                                      showCheckmark: false,
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      onSelected: (val) {
                                        if (val) {
                                          setState(() => _selectedCategory = cat);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// Statistics Grid
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
                      value: filteredBookings.length.toString(),
                      icon: Icons.calendar_month,
                      color: primary,
                    ),
                    StatCard(
                      title: "Revenue",
                      value: '₹ ${totalAmount.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: "Upcoming",
                      value: upcomingCount.toString(),
                      icon: Icons.schedule,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: "Cancelled",
                      value: cancelledCount.toString(),
                      icon: Icons.cancel_outlined,
                      color: Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // RECENT BOOKINGS HEADER & EXPORT ACTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory == 'All'
                          ? "Recent Bookings"
                          : "$_selectedCategory Bookings",
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sortedBookings.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () => _exportBookingsReport(sortedBookings),
                        icon: const Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 16,
                          color: primary,
                        ),
                        label: const Text(
                          "Export PDF",
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                if (sortedBookings.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No bookings match the selected filters',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedBookings.length < 15
                        ? sortedBookings.length
                        : 15,
                    itemBuilder: (context, index) {
                      final bookingDoc = sortedBookings[index];
                      final booking = bookingDoc.data();

                      final customerName =
                          booking['customerName']?.toString() ?? 'Customer';

                      final sport = booking['sport']?.toString() ?? 'Football';

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
                        case 'Cancelled':
                          statusColor = Colors.red;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      String time = 'Time unavailable';
                      if (booking['startAt'] is Timestamp &&
                          booking['endAt'] is Timestamp) {
                        final startAt =
                            (booking['startAt'] as Timestamp).toDate();
                        final endAt = (booking['endAt'] as Timestamp).toDate();
                        time =
                            '${DateFormat('hh:mm a').format(startAt)} - ${DateFormat('hh:mm a').format(endAt)}';
                      }

                      String bookedAt = '';
                      if (booking['createdAt'] is Timestamp) {
                        final createdAt =
                            (booking['createdAt'] as Timestamp).toDate();
                        bookedAt =
                            DateFormat('d MMM • hh:mm a').format(createdAt);
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OwnerBookingDetailsScreen(
                                bookingDoc: bookingDoc,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
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
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: primary.withValues(alpha: .12),
                                child: const Icon(Icons.person, color: primary),
                              ),
                              const SizedBox(width: 14),
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
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTurfScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Turf", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    IconData? icon,
    required Color primary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: icon != null
            ? Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              )
            : null,
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedColor: primary,
        backgroundColor: Colors.grey.shade100,
        showCheckmark: false,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onSelected: (_) => onSelected(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
