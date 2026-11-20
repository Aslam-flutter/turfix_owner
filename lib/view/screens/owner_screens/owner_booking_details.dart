import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turfix_owner/core/services/pdf_report_service.dart';

class OwnerBookingDetailsScreen extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> bookingDoc;

  const OwnerBookingDetailsScreen({super.key, required this.bookingDoc});

  @override
  State<OwnerBookingDetailsScreen> createState() =>
      _OwnerBookingDetailsScreenState();
}

class _OwnerBookingDetailsScreenState extends State<OwnerBookingDetailsScreen> {
  bool _isCancelling = false;

  Future<void> _cancelBooking(BuildContext context, Map<String, dynamic> data) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This will free the slot for other customers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Update booking status
      batch.update(widget.bookingDoc.reference, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': 'owner',
      });

      // Free the slots if slot info is present
      final turfId = data['turfId']?.toString();
      final date = data['date']?.toString();
      final List<dynamic> slotIds = data['slotIds'] ?? [];

      if (turfId != null && turfId.isNotEmpty && date != null && date.isNotEmpty) {
        for (final slotId in slotIds) {
          final slotRef = firestore
              .collection('turfs')
              .doc(turfId)
              .collection('slots')
              .doc(date)
              .collection('times')
              .doc(slotId.toString());

          batch.update(slotRef, {
            'status': 'available',
            'bookingId': null,
          });
        }
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.bookingDoc.reference.snapshots(),
      builder: (context, snapshot) {
        final doc = snapshot.data ?? widget.bookingDoc;
        final data = doc.data() ?? {};

        final customerName = data['customerName']?.toString() ?? 'Customer';
        final customerPhone = data['customerPhone']?.toString() ??
            data['phone']?.toString() ??
            data['userPhone']?.toString() ??
            'Not provided';
        final turfName = data['turfName']?.toString() ?? 'Turf';
        final location = data['turfLocation']?.toString() ??
            data['location']?.toString() ??
            '';
        final sport = data['sport']?.toString() ?? 'Football';
        final totalAmount =
            (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final status = data['status']?.toString() ?? 'Confirmed';
        final paymentStatus =
            data['paymentStatus']?.toString() ?? 'Paid';

        // Format dates
        String formattedDate = data['date']?.toString() ?? 'Date unavailable';
        String formattedTime = 'Time unavailable';

        if (data['startAt'] is Timestamp) {
          final startAt = (data['startAt'] as Timestamp).toDate();
          formattedDate = DateFormat('d MMMM yyyy').format(startAt);

          if (data['endAt'] is Timestamp) {
            final endAt = (data['endAt'] as Timestamp).toDate();
            formattedTime =
                '${DateFormat('hh:mm a').format(startAt)} - ${DateFormat('hh:mm a').format(endAt)}';
          } else {
            formattedTime = DateFormat('hh:mm a').format(startAt);
          }
        }

        final isCancelled = status.toLowerCase() == 'cancelled';

        Color statusColor;
        switch (status.toLowerCase()) {
          case 'confirmed':
            statusColor = Colors.orange;
            break;
          case 'playing':
            statusColor = primary;
            break;
          case 'completed':
            statusColor = Colors.grey;
            break;
          case 'cancelled':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.grey;
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            ),
            title: const Text(
              "Booking Details",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            actions: [
              IconButton(
                tooltip: "Download PDF Receipt",
                icon: const Icon(Icons.picture_as_pdf_outlined, color: primary),
                onPressed: () {
                  PdfReportService.downloadSingleBookingReceipt(
                    context: context,
                    bookingDoc: doc,
                  );
                },
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Contact Customer'),
                              content: Text('Phone number: $customerPhone'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.call, color: Colors.white, size: 20),
                        label: const Text(
                          "Call",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          minimumSize: const Size.fromHeight(50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Customer WhatsApp: $customerPhone'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                        label: const Text(
                          "WhatsApp",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff25D366),
                          minimumSize: const Size.fromHeight(50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (!isCancelled)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isCancelling ? null : () => _cancelBooking(context, data),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isCancelling
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Text(
                              "Cancel Booking",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "This booking has been cancelled",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Customer info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primary.withValues(alpha: .1),
                        child: const Icon(Icons.person, color: primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customerPhone,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Booking details grid
                Row(
                  children: [
                    Expanded(
                      child: DetailItem(title: "Date", value: formattedDate),
                    ),
                    Expanded(
                      child: DetailItem(title: "Time", value: formattedTime),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DetailItem(title: "Sport", value: sport),
                    ),
                    Expanded(
                      child: DetailItem(
                        title: "Amount",
                        value: "₹${totalAmount.toStringAsFixed(0)}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Turf section
                SectionTile(
                  icon: Icons.stadium,
                  title: turfName,
                  subtitle: location.isNotEmpty ? location : "Turf Location",
                ),
                const SizedBox(height: 16),

                // Payment section
                SectionTile(
                  icon: Icons.payment,
                  title: "Payment Status",
                  subtitle: paymentStatus,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      paymentStatus,
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DetailItem extends StatelessWidget {
  final String title;
  final String value;

  const DetailItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const SectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff16A34A);

    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
